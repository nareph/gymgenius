// test/engines/workout_engine/profile_coherence_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/enums/activity_level.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/exercise_difficulty.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/force_type.dart';
import 'package:gymgenius/domain/enums/laterality.dart';
import 'package:gymgenius/domain/enums/mechanics.dart';
import 'package:gymgenius/domain/enums/movement_pattern.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/plane_of_motion.dart';
import 'package:gymgenius/domain/enums/workout_frequency.dart';
import 'package:gymgenius/engines/workout_engine/planner/split_catalog.dart';
import 'package:gymgenius/engines/workout_engine/planner/split_planner.dart';
import 'package:gymgenius/engines/workout_engine/planner/workout_frequency_planner.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';
import 'package:gymgenius/engines/workout_engine/shared/profile_coherence.dart';
import 'package:gymgenius/engines/workout_engine/volume_calculator.dart';

void main() {
  group('ProfileCoherence', () {
    test('provides default focus areas when user selected none', () {
      final focus = ProfileCoherence.resolveFocusAreas(
        goal: FitnessGoal.buildMuscle,
        userFocusAreas: const [],
      );

      expect(focus, isNotEmpty);
      expect(focus, contains(MuscleGroup.chest));
    });

    test('preserves explicit user focus areas exactly', () {
      final focus = ProfileCoherence.resolveFocusAreas(
        goal: FitnessGoal.buildMuscle,
        userFocusAreas: const [
          MuscleGroup.glutes,
          MuscleGroup.absCore,
        ],
      );

      expect(
        focus,
        equals(
          const [
            MuscleGroup.glutes,
            MuscleGroup.absCore,
          ],
        ),
      );
    });

    test('deduplicates explicit user focus areas', () {
      final focus = ProfileCoherence.resolveFocusAreas(
        goal: FitnessGoal.buildMuscle,
        userFocusAreas: const [
          MuscleGroup.glutes,
          MuscleGroup.glutes,
          MuscleGroup.absCore,
        ],
      );

      expect(
        focus,
        equals(
          const [
            MuscleGroup.glutes,
            MuscleGroup.absCore,
          ],
        ),
      );
    });

    test('detects specialized single-muscle focus', () {
      expect(
        ProfileCoherence.isSpecializedFocus(
          const [MuscleGroup.absCore],
        ),
        isTrue,
      );

      expect(
        ProfileCoherence.isSingleFocus(
          const [MuscleGroup.glutes],
        ),
        isTrue,
      );
    });

    test('does not classify broad focus as specialized', () {
      expect(
        ProfileCoherence.isSpecializedFocus(
          const [
            MuscleGroup.chest,
            MuscleGroup.back,
            MuscleGroup.shoulders,
            MuscleGroup.biceps,
            MuscleGroup.triceps,
            MuscleGroup.quadriceps,
            MuscleGroup.hamstrings,
            MuscleGroup.glutes,
          ],
        ),
        isFalse,
      );
    });

    test('merges extra avoided muscles onto the profile list', () {
      final merged = ProfileCoherence.resolveAvoidedMuscles(
        profileAvoided: const [MuscleGroup.shoulders],
        extra: const [
          MuscleGroup.back,
          MuscleGroup.shoulders,
        ],
      );

      expect(
        merged,
        containsAll(
          [
            MuscleGroup.shoulders,
            MuscleGroup.back,
          ],
        ),
      );

      expect(merged.length, 2);
    });

    test('detects exercises that target avoided muscles', () {
      expect(
        ProfileCoherence.exerciseTargetsAvoided(
          primaryMuscles: const [
            MuscleGroup.chest,
            MuscleGroup.triceps,
          ],
          avoidedMuscles: const [
            MuscleGroup.shoulders,
          ],
        ),
        isFalse,
      );

      expect(
        ProfileCoherence.exerciseTargetsAvoided(
          primaryMuscles: const [
            MuscleGroup.chest,
            MuscleGroup.triceps,
          ],
          avoidedMuscles: const [
            MuscleGroup.chest,
          ],
        ),
        isTrue,
      );
    });

    test('filters advanced exercises for beginners', () {
      const advanced = ExercisePoolEntry(
        id: 'x',
        name: 'Advanced Move',
        category: ExerciseCategory.compound,
        difficulty: ExerciseDifficulty.advanced,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: [MuscleGroup.back],
        usesWeight: false,
        movementPattern: MovementPattern.pull,
        mechanics: Mechanics.openChain,
        forceType: ForceType.pull,
        laterality: Laterality.bilateral,
        planeOfMotion: PlaneOfMotion.sagittal,
        description: 'test',
      );

      const beginner = ExercisePoolEntry(
        id: 'y',
        name: 'Beginner Move',
        category: ExerciseCategory.compound,
        difficulty: ExerciseDifficulty.beginner,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: [MuscleGroup.back],
        usesWeight: false,
        movementPattern: MovementPattern.pull,
        mechanics: Mechanics.openChain,
        forceType: ForceType.pull,
        laterality: Laterality.bilateral,
        planeOfMotion: PlaneOfMotion.sagittal,
        description: 'test',
      );

      expect(
        ProfileCoherence.isExerciseAppropriateForExperience(
          exercise: advanced,
          experience: ExperienceLevel.beginner,
        ),
        isFalse,
      );

      expect(
        ProfileCoherence.isExerciseAppropriateForExperience(
          exercise: beginner,
          experience: ExperienceLevel.beginner,
        ),
        isTrue,
      );
    });

    test('dampens recovery volume cuts for very-active profiles', () {
      expect(
        ProfileCoherence.dampenRecoveryVolumeMultiplier(
          volumeMultiplier: 0.70,
          activityLevel: ActivityLevel.moderatelyActive,
        ),
        0.70,
      );

      expect(
        ProfileCoherence.dampenRecoveryVolumeMultiplier(
          volumeMultiplier: 0.70,
          activityLevel: ActivityLevel.veryActive,
        ),
        0.85,
      );
    });
  });

  group('WorkoutFrequencyPlanner', () {
    const planner = WorkoutFrequencyPlanner();

    test('respects preferred day count inside frequency range', () {
      final result = planner.calculateWorkoutDays(
        frequency: WorkoutFrequency.threeToFour,
        preferredDays: const [
          'monday',
          'wednesday',
          'friday',
        ],
      );

      expect(result.count, 3);
      expect(result.useSpecifiedDays, isTrue);
    });

    test('clamps preferred days to frequency range', () {
      final result = planner.calculateWorkoutDays(
        frequency: WorkoutFrequency.oneToTwo,
        preferredDays: List.generate(
          4,
          (i) => 'day_$i',
        ),
      );

      expect(result.count, 2);
      expect(result.useSpecifiedDays, isFalse);
    });
  });

  group('SplitPlanner predefined split coherence', () {
    const planner = SplitPlanner();

    test('keeps the stable 2-day upper/lower template', () {
      final splits = planner.plan(
        workoutDays: 2,
        experience: ExperienceLevel.intermediate,
        focusMuscles: const [],
      );

      expect(
        splits.map((split) => split.name).toList(),
        equals(
          const [
            'Upper Body',
            'Lower Body',
          ],
        ),
      );
    });

    test('keeps the stable 3-day push pull legs template without focus', () {
      final splits = planner.plan(
        workoutDays: 3,
        experience: ExperienceLevel.intermediate,
        focusMuscles: const [],
      );

      expect(
        splits.map((split) => split.name).toList(),
        equals(
          const [
            'Push',
            'Pull',
            'Legs',
          ],
        ),
      );
    });

    test('keeps the stable 4-day template without focus', () {
      final splits = planner.plan(
        workoutDays: 4,
        experience: ExperienceLevel.intermediate,
        focusMuscles: const [],
      );

      expect(
        splits.map((split) => split.name).toList(),
        equals(
          const [
            'Chest & Triceps',
            'Back & Biceps',
            'Legs',
            'Shoulders & Core',
          ],
        ),
      );
    });

    test('keeps the stable 5-day template without focus', () {
      final splits = planner.plan(
        workoutDays: 5,
        experience: ExperienceLevel.intermediate,
        focusMuscles: const [],
      );

      expect(
        splits.map((split) => split.name).toList(),
        equals(
          const [
            'Chest',
            'Back',
            'Legs',
            'Arms',
            'Shoulders & Core',
          ],
        ),
      );
    });

    test('broad hypertrophy focus keeps the predefined 4-day structure', () {
      final splits = planner.plan(
        workoutDays: 4,
        experience: ExperienceLevel.intermediate,
        focusMuscles: ProfileCoherence.defaultFocusAreas(
          FitnessGoal.buildMuscle,
        ),
      );

      expect(splits.length, 4);

      expect(
        splits.map((split) => split.name).toList(),
        equals(
          const [
            'Chest & Triceps',
            'Back & Biceps',
            'Legs',
            'Shoulders & Core',
          ],
        ),
      );
    });

    test('single abs/core focus creates a specialized 3-day split', () {
      final splits = planner.plan(
        workoutDays: 3,
        experience: ExperienceLevel.intermediate,
        focusMuscles: const [
          MuscleGroup.absCore,
        ],
      );

      expect(splits.length, 3);

      expect(
        splits.every(
          (split) =>
              split.muscles.length == 1 &&
              split.muscles.contains(MuscleGroup.absCore),
        ),
        isTrue,
      );
    });

    test('single glutes focus creates a specialized 3-day split', () {
      final splits = planner.plan(
        workoutDays: 3,
        experience: ExperienceLevel.intermediate,
        focusMuscles: const [
          MuscleGroup.glutes,
        ],
      );

      expect(splits.length, 3);

      expect(
        splits.every(
          (split) =>
              split.muscles.length == 1 &&
              split.muscles.contains(MuscleGroup.glutes),
        ),
        isTrue,
      );
    });

    test('glutes and abs/core focus stays restricted to selected muscles', () {
      final splits = planner.plan(
        workoutDays: 3,
        experience: ExperienceLevel.intermediate,
        focusMuscles: const [
          MuscleGroup.glutes,
          MuscleGroup.absCore,
        ],
      );

      expect(splits.length, 3);

      for (final split in splits) {
        expect(
          split.muscles.toSet(),
          equals(
            const {
              MuscleGroup.glutes,
              MuscleGroup.absCore,
            },
          ),
        );
      }
    });
  });

  group('VolumeCalculator activity coherence', () {
    test('sedentary sessions are smaller than very-active ones', () {
      final sedentary = VolumeCalculator.exerciseCountForSession(
        'standard_60',
        0,
        activityLevel: ActivityLevel.sedentary,
      );

      final veryActive = VolumeCalculator.exerciseCountForSession(
        'standard_60',
        0,
        activityLevel: ActivityLevel.veryActive,
      );

      expect(sedentary, lessThan(veryActive));
      expect(sedentary, greaterThanOrEqualTo(3));
      expect(veryActive, lessThanOrEqualTo(9));
    });
  });

  group('SplitCatalog', () {
    test('contains the historical five-day chest/back/legs/arms structure', () {
      final template = SplitCatalog.templateForDays(5);

      expect(
        template.map((split) => split.name).toList(),
        equals(
          const [
            'Chest',
            'Back',
            'Legs',
            'Arms',
            'Shoulders & Core',
          ],
        ),
      );
    });

    test('finds the Pull split by name', () {
      final pullSplit = SplitCatalog.byName('Pull');

      expect(pullSplit, isNotNull);
      expect(pullSplit!.name, 'Pull');
    });
  });
}
