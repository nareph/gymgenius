import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/activity_level.dart';
import 'package:gymgenius/domain/enums/budget_level.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/gender.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/session_duration.dart';
import 'package:gymgenius/domain/enums/workout_day.dart';
import 'package:gymgenius/domain/enums/workout_frequency.dart';
import 'package:gymgenius/domain/value_objects/body_measurements.dart';
import 'package:gymgenius/domain/value_objects/workout_preferences.dart';
import 'package:gymgenius/domain/value_objects/lifestyle_preferences.dart';
import 'package:gymgenius/engines/workout_engine/program_generator.dart';
import 'package:gymgenius/engines/workout_engine/generators/split_generator.dart';
import 'package:gymgenius/engines/workout_engine/generators/workout_day_generator.dart';
import 'package:gymgenius/engines/workout_engine/services/generation_service.dart';
import 'package:gymgenius/engines/workout_engine/services/regeneration_service.dart';

/// NOTE: These tests target [GenerationService] / [RegenerationService]
/// directly rather than the [WorkoutEngine] facade. The facade's
/// `generateProgram()` / `regenerateProgram()` also persist via
/// `PersistenceService` (Hive), which needs mocking/fakes to unit-test
/// cleanly and isn't covered here — see the bottom of this file for what
/// that would need. `GenerationService`/`RegenerationService` are the
/// actual deterministic core the Workout Engine spec cares about, with
/// zero side effects, which is what these tests exercise.
HealthProfile _createTestProfile({
  List<EquipmentType>? equipment,
  List<MuscleGroup>? focusAreas,
}) {
  final now = DateTime.now();
  return HealthProfile(
    userId: 'test-user',
    body: BodyMeasurements(
      age: 25,
      heightCm: 175,
      currentWeightKg: 75,
      targetWeightKg: 70,
      gender: Gender.male,
    ),
    training: WorkoutPreferences(
      goal: FitnessGoal.buildMuscle,
      experience: ExperienceLevel.beginner,
      activityLevel: ActivityLevel.moderatelyActive,
      frequency: WorkoutFrequency.threeToFour,
      sessionDuration: SessionDuration.standard60,
      preferredDays: const [
        WorkoutDay.monday,
        WorkoutDay.wednesday,
        WorkoutDay.friday,
      ],
      equipment: equipment ?? const [EquipmentType.bodyweight],
      focusAreas: focusAreas ?? const [],
    ),
    lifestyle: const LifestylePreferences(
      country: 'Test',
      budget: BudgetLevel.medium,
    ),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('SplitGenerator', () {
    test('returns 3-day PPL split for 3 workout days', () {
      final split = SplitGenerator.determineMuscleSplit(3, 'beginner');
      expect(split.length, 3);
      expect(split.map((s) => s.name).toList(), ['Push', 'Pull', 'Legs']);
    });

    test('caps beginners at 4-day split for 5+ days', () {
      final split = SplitGenerator.determineMuscleSplit(5, 'beginner');
      expect(split.length, 4);
      expect(split.first.name, 'Chest & Triceps');
    });

    test('allows 5-day split for intermediate users', () {
      final split = SplitGenerator.determineMuscleSplit(5, 'intermediate');
      expect(split.length, 5);
      expect(split.map((s) => s.name).toList(), [
        'Chest',
        'Back',
        'Legs',
        'Arms',
        'Shoulders & Core',
      ]);
    });

    test('calculateWorkoutDays respects preferred days within frequency', () {
      final result = SplitGenerator.calculateWorkoutDays(
        frequency: '3-5',
        preferredDays: ['monday', 'wednesday', 'friday'],
      );
      expect(result.count, 3);
      expect(result.useSpecifiedDays, isTrue);
    });

    test('calculateWorkoutDays defaults to 3 when no frequency given', () {
      final result = SplitGenerator.calculateWorkoutDays();
      expect(result.count, 3);
      expect(result.useSpecifiedDays, isFalse);
    });
  });

  group('GenerationService (deterministic local generation)', () {
    test('produces a valid program structure', () async {
      final service =
          GenerationService(generator: ProgramGenerator(random: Random(42)));
      final profile = _createTestProfile();

      final program = await service.generate(profile: profile);

      expect(program, isA<TrainingProgram>());
      expect(program.name, isNotEmpty);
      expect(program.durationWeeks, greaterThan(0));

      final mondayExercises = program.weeklySchedule['monday'];
      expect(mondayExercises, isNotEmpty);

      final firstExercise = mondayExercises!.first;
      expect(firstExercise.name, isNotEmpty);
      expect(firstExercise.sets, greaterThan(0));
      expect(firstExercise.reps, isNotEmpty);
      expect(firstExercise.isBodyweight, isA<bool>());
      expect(firstExercise.isTimed, isA<bool>());
    });

    test('is deterministic given the same seed', () async {
      final profile = _createTestProfile();

      final programA = await GenerationService(
        generator: ProgramGenerator(random: Random(7)),
      ).generate(profile: profile);

      final programB = await GenerationService(
        generator: ProgramGenerator(random: Random(7)),
      ).generate(profile: profile);

      expect(programA.weeklySchedule.keys, programB.weeklySchedule.keys);
      for (final day in programA.weeklySchedule.keys) {
        final namesA =
            programA.weeklySchedule[day]!.map((e) => e.name).toList();
        final namesB =
            programB.weeklySchedule[day]!.map((e) => e.name).toList();
        expect(namesA, namesB,
            reason:
                'Exercise selection for $day should be identical with the same seed');
      }
    });

    test('never selects the same exercise twice within a single day', () async {
      final service =
          GenerationService(generator: ProgramGenerator(random: Random(1)));
      final profile = _createTestProfile(equipment: const [
        EquipmentType.bodyweight,
        EquipmentType.dumbbells,
        EquipmentType.barbellAndPlates,
        EquipmentType.cableMachinePulley,
      ]);

      final program = await service.generate(profile: profile);

      for (final entry in program.weeklySchedule.entries) {
        final names = entry.value.map((e) => e.name).toList();
        expect(names.toSet().length, names.length,
            reason: '${entry.key} should have no duplicate exercise names');
      }
    });

    test('respects a bodyweight-only equipment constraint', () async {
      final service =
          GenerationService(generator: ProgramGenerator(random: Random(3)));
      final profile =
          _createTestProfile(equipment: const [EquipmentType.bodyweight]);

      final program = await service.generate(profile: profile);

      for (final exercises in program.weeklySchedule.values) {
        for (final exercise in exercises) {
          expect(exercise.equipment, EquipmentType.bodyweight,
              reason: '${exercise.name} should only use bodyweight equipment');
        }
      }
    });

    test('avoidMuscles excludes any exercise targeting that muscle', () async {
      final service =
          GenerationService(generator: ProgramGenerator(random: Random(5)));
      final profile = _createTestProfile(equipment: const [
        EquipmentType.bodyweight,
        EquipmentType.dumbbells,
        EquipmentType.barbellAndPlates,
        EquipmentType.cableMachinePulley,
      ]);

      final program = await service.generate(
        profile: profile,
        options: const {
          'avoidMuscles': ['triceps'],
        },
      );

      for (final exercises in program.weeklySchedule.values) {
        for (final exercise in exercises) {
          expect(exercise.primaryMuscles.contains(MuscleGroup.triceps), isFalse,
              reason: '${exercise.name} should not target triceps');
        }
      }
    });

    test(
        'picks different exercises when regenerated against a previous program',
        () async {
      // Well-equipped profile so the pool is large enough that avoiding
      // repeats doesn't immediately exhaust it and force a fallback repeat.
      final profile = _createTestProfile(equipment: const [
        EquipmentType.bodyweight,
        EquipmentType.dumbbells,
        EquipmentType.barbellAndPlates,
        EquipmentType.cableMachinePulley,
        EquipmentType.gymMachinesSelectorized,
        EquipmentType.pullUpBarAccessible,
      ]);
      final service =
          GenerationService(generator: ProgramGenerator(random: Random(9)));

      final firstProgram = await service.generate(profile: profile);
      final secondProgram = await service.generate(
        profile: profile,
        previousProgram: firstProgram,
      );

      var anyDifference = false;
      for (final day in firstProgram.weeklySchedule.keys) {
        final before =
            firstProgram.weeklySchedule[day]!.map((e) => e.name).join(',');
        final after =
            secondProgram.weeklySchedule[day]!.map((e) => e.name).join(',');
        if (before != after) anyDifference = true;
      }
      expect(anyDifference, isTrue,
          reason:
              'Regenerating with a previousProgram should select at least some different exercises');
    });
  });

  group('RegenerationService', () {
    test('type=specificDay only changes the targeted day', () async {
      final profile = _createTestProfile();
      final generationService =
          GenerationService(generator: ProgramGenerator(random: Random(11)));
      final regenerationService = RegenerationService(
        generationService: generationService,
        dayGenerator: WorkoutDayGenerator(random: Random(11)),
      );

      final original = await generationService.generate(profile: profile);
      final regenerated = await regenerationService.regenerate(
        profile: profile,
        previousProgram: original,
        options: const {'type': 'specificDay', 'targetDay': 'monday'},
      );

      expect(regenerated.weeklySchedule['wednesday'],
          original.weeklySchedule['wednesday']);
      expect(regenerated.weeklySchedule['friday'],
          original.weeklySchedule['friday']);
    });

    test('type=singleExercise only changes the targeted exercise', () async {
      final profile = _createTestProfile();
      final generationService =
          GenerationService(generator: ProgramGenerator(random: Random(15)));
      final regenerationService = RegenerationService(
        generationService: generationService,
        dayGenerator: WorkoutDayGenerator(random: Random(15)),
      );

      final original = await generationService.generate(profile: profile);
      final mondayExercises = original.weeklySchedule['monday']!;
      expect(mondayExercises, isNotEmpty);

      final targetId = mondayExercises.first.id.isNotEmpty
          ? mondayExercises.first.id
          : 'exercise_0';

      final regenerated = await regenerationService.regenerate(
        profile: profile,
        previousProgram: original,
        options: {
          'type': 'singleExercise',
          'targetDay': 'monday',
          'targetExerciseId': targetId,
        },
      );

      final regeneratedMonday = regenerated.weeklySchedule['monday']!;
      expect(regeneratedMonday.length, mondayExercises.length,
          reason: 'Exercise count for the day must stay identical');

      // Every OTHER exercise on Monday should be untouched.
      for (var i = 1; i < mondayExercises.length; i++) {
        expect(regeneratedMonday[i], mondayExercises[i]);
      }

      expect(regenerated.weeklySchedule['wednesday'],
          original.weeklySchedule['wednesday']);
    });

    test('keepStructure preserves day list and per-day exercise count',
        () async {
      final profile = _createTestProfile();
      final generationService =
          GenerationService(generator: ProgramGenerator(random: Random(13)));
      final regenerationService = RegenerationService(
        generationService: generationService,
        dayGenerator: WorkoutDayGenerator(random: Random(13)),
      );

      final original = await generationService.generate(profile: profile);
      final regenerated = await regenerationService.regenerate(
        profile: profile,
        previousProgram: original,
        options: const {'type': 'fullProgram', 'keepStructure': true},
      );

      final originalDays = original.weeklySchedule.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) => e.key)
          .toSet();
      final regeneratedDays = regenerated.weeklySchedule.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) => e.key)
          .toSet();

      expect(regeneratedDays, originalDays,
          reason: 'keepStructure must not change which days train');

      for (final day in originalDays) {
        expect(regenerated.weeklySchedule[day]!.length,
            original.weeklySchedule[day]!.length,
            reason: 'keepStructure must not change exercise count for $day');
      }
    });
  });
}
