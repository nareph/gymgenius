import 'package:gymgenius/domain/enums/activity_level.dart';
import 'package:gymgenius/domain/enums/exercise_difficulty.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// Profile-aware helpers used by generation and exercise selection.
class ProfileCoherence {
  ProfileCoherence._();

  /// Sensible default focus muscles when the user did not pick any.
  static List<MuscleGroup> defaultFocusAreas(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.buildMuscle:
        return [
          MuscleGroup.chest,
          MuscleGroup.back,
          MuscleGroup.shoulders,
        ];
      case FitnessGoal.increaseStrength:
        return [
          MuscleGroup.back,
          MuscleGroup.quadriceps,
          MuscleGroup.chest,
        ];
      case FitnessGoal.loseFat:
        return [
          MuscleGroup.absCore,
          MuscleGroup.quadriceps,
          MuscleGroup.glutes,
        ];
      case FitnessGoal.improveEndurance:
        return [
          MuscleGroup.quadriceps,
          MuscleGroup.absCore,
          MuscleGroup.calves,
        ];
      case FitnessGoal.generalFitness:
        return [
          MuscleGroup.chest,
          MuscleGroup.back,
          MuscleGroup.quadriceps,
        ];
    }
  }

  static List<MuscleGroup> resolveFocusAreas({
    required FitnessGoal goal,
    required List<MuscleGroup> userFocusAreas,
  }) {
    if (userFocusAreas.isNotEmpty) {
      return userFocusAreas;
    }
    return defaultFocusAreas(goal);
  }

  /// Merges profile-level avoided muscles with a one-off extra list
  /// (e.g. regeneration options). Profile remains the source of truth.
  static List<MuscleGroup> resolveAvoidedMuscles({
    required List<MuscleGroup> profileAvoided,
    List<MuscleGroup>? extra,
  }) {
    if (extra == null || extra.isEmpty) {
      return List<MuscleGroup>.from(profileAvoided);
    }
    return {...profileAvoided, ...extra}.toList();
  }

  static bool exerciseTargetsAvoided({
    required List<MuscleGroup> primaryMuscles,
    required List<MuscleGroup> avoidedMuscles,
  }) {
    if (avoidedMuscles.isEmpty) return false;
    return primaryMuscles.any(avoidedMuscles.contains);
  }

  /// Softens a daily recovery volume cut so very/extra-active users are not
  /// penalized twice (generation already adds exercises via
  /// [activityVolumeOffset]; Nutrition already raises TDEE).
  ///
  /// Example: a 30% cut (0.70) on a very-active profile becomes 15% (0.85).
  static double dampenRecoveryVolumeMultiplier({
    required double volumeMultiplier,
    required ActivityLevel activityLevel,
  }) {
    if (volumeMultiplier >= 1.0) return volumeMultiplier;
    final reduction = 1.0 - volumeMultiplier;
    final factor = switch (activityLevel) {
      ActivityLevel.sedentary => 1.0,
      ActivityLevel.lightlyActive => 1.0,
      ActivityLevel.moderatelyActive => 1.0,
      ActivityLevel.veryActive => 0.5,
      ActivityLevel.extraActive => 0.4,
    };
    return (1.0 - reduction * factor).clamp(0.55, 1.0);
  }

  /// Session exercise-count offset from daily activity (not training days).
  /// Sedentary users get a slightly smaller session; very active a slightly
  /// larger one — Nutrition already uses the same field for TDEE.
  static int activityVolumeOffset(ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return -1;
      case ActivityLevel.lightlyActive:
        return 0;
      case ActivityLevel.moderatelyActive:
        return 0;
      case ActivityLevel.veryActive:
        return 1;
      case ActivityLevel.extraActive:
        return 1;
    }
  }

  /// Beginners skip advanced-only movements; advanced users keep full pool.
  static bool isExerciseAppropriateForExperience({
    required ExercisePoolEntry exercise,
    required ExperienceLevel experience,
  }) {
    switch (experience) {
      case ExperienceLevel.beginner:
        return exercise.difficulty != ExerciseDifficulty.advanced;
      case ExperienceLevel.intermediate:
      case ExperienceLevel.advanced:
        return true;
    }
  }

  /// Bonus applied during split scoring so structure matches the user's goal.
  static double goalSplitBonus({
    required FitnessGoal goal,
    required MuscleSplit split,
    required int workoutDays,
  }) {
    switch (goal) {
      case FitnessGoal.buildMuscle:
        if (workoutDays >= 4 &&
            (split.name == 'Push' ||
                split.name == 'Pull' ||
                split.name == 'Legs' ||
                split.name == 'Chest & Triceps' ||
                split.name == 'Back & Biceps')) {
          return 6;
        }
        if (workoutDays == 3 &&
            (split.name == 'Push' ||
                split.name == 'Pull' ||
                split.name == 'Legs')) {
          return 5;
        }
        return 0;

      case FitnessGoal.increaseStrength:
        if (split.isFullBody && workoutDays <= 3) return 8;
        if ((split.isUpperBody || split.isLowerBody) && workoutDays <= 4) {
          return 5;
        }
        if (split.name == 'Legs') return 3;
        return 0;

      case FitnessGoal.loseFat:
        if (split.isFullBody) return 7;
        if (split.isUpperBody || split.isLowerBody) return 4;
        return 0;

      case FitnessGoal.improveEndurance:
        if (split.isFullBody) return 8;
        if (split.name == 'Legs' || split.name == 'Lower Body') return 4;
        return 0;

      case FitnessGoal.generalFitness:
        if (split.isFullBody) return 6;
        if (split.isUpperBody || split.isLowerBody) return 5;
        return 0;
    }
  }
}
