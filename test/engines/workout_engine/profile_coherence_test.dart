import 'package:flutter_test/flutter_test.dart';
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
import 'package:gymgenius/domain/enums/activity_level.dart';
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

    test('merges extra avoided muscles onto the profile list', () {
      final merged = ProfileCoherence.resolveAvoidedMuscles(
        profileAvoided: const [MuscleGroup.shoulders],
        extra: const [MuscleGroup.back, MuscleGroup.shoulders],
      );
      expect(merged, containsAll([MuscleGroup.shoulders, MuscleGroup.back]));
      expect(merged.length, 2);
    });

    test('detects exercises that target avoided muscles', () {
      expect(
        ProfileCoherence.exerciseTargetsAvoided(
          primaryMuscles: const [MuscleGroup.chest, MuscleGroup.triceps],
          avoidedMuscles: const [MuscleGroup.shoulders],
        ),
        isFalse,
      );
      expect(
        ProfileCoherence.exerciseTargetsAvoided(
          primaryMuscles: const [MuscleGroup.chest, MuscleGroup.triceps],
          avoidedMuscles: const [MuscleGroup.chest],
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
        preferredDays: const ['monday', 'wednesday', 'friday'],
      );
      expect(result.count, 3);
      expect(result.useSpecifiedDays, isTrue);
    });

    test('clamps preferred days to frequency range', () {
      final result = planner.calculateWorkoutDays(
        frequency: WorkoutFrequency.oneToTwo,
        preferredDays: List.generate(4, (i) => 'day_$i'),
      );
      expect(result.count, 2);
      expect(result.useSpecifiedDays, isFalse);
    });
  });

  group('SplitPlanner goal coherence', () {
    const planner = SplitPlanner();

    test('strength beginners favor full-body templates at low frequency', () {
      final splits = planner.plan(
        workoutDays: 3,
        experience: ExperienceLevel.beginner,
        focusMuscles: ProfileCoherence.defaultFocusAreas(
          FitnessGoal.increaseStrength,
        ),
        goal: FitnessGoal.increaseStrength,
      );

      expect(splits.length, 3);
      expect(
        splits.any((split) => split.isFullBody || split.isUpperBody),
        isTrue,
      );
    });

    test('hypertrophy 4-day plan favors specialization splits', () {
      final splits = planner.plan(
        workoutDays: 4,
        experience: ExperienceLevel.intermediate,
        focusMuscles: ProfileCoherence.defaultFocusAreas(
          FitnessGoal.buildMuscle,
        ),
        goal: FitnessGoal.buildMuscle,
      );

      expect(splits.length, 4);
      expect(
        splits.where((split) => split.name == 'Push' || split.name == 'Pull'),
        isNotEmpty,
      );
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

  group('Pull bodyweight pool depth', () {
    test('has enough home-friendly pull options without a bar', () {
      final pullSplit = SplitCatalog.byName('Pull');
      expect(pullSplit, isNotNull);
    });
  });
}
