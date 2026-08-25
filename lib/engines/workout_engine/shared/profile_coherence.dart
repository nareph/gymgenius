import 'package:gymgenius/domain/enums/activity_level.dart';
import 'package:gymgenius/domain/enums/exercise_difficulty.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// Profile-aware helpers used by generation and exercise selection.
///
/// Responsibilities:
///
/// • Resolve explicit user focus areas.
/// • Provide goal-based defaults only when no focus was selected.
/// • Resolve avoided muscles.
/// • Apply activity/recovery adjustments.
/// • Validate exercise difficulty against experience.
///
/// Focus areas are treated as strict user intent by the split-planning
/// layer:
///
///     "I want to work only these muscles."
///
/// Therefore this class NEVER adds unrelated muscles to an explicitly
/// provided focus list.
class ProfileCoherence {
  ProfileCoherence._();

  // ============================================================
  // Focus Areas
  // ============================================================

  /// Sensible default focus muscles when the user did not select any.
  ///
  /// These defaults are used only when [userFocusAreas] is empty.
  static List<MuscleGroup> defaultFocusAreas(
    FitnessGoal goal,
  ) {
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

  /// Resolves the final focus areas for the workout engine.
  ///
  /// Explicit user selections always win.
  ///
  /// When the user selected one or more muscles:
  ///
  ///     return exactly those muscles
  ///
  /// When the user selected nothing:
  ///
  ///     use goal-based defaults.
  ///
  /// No unrelated muscle is silently added to an explicit selection.
  static List<MuscleGroup> resolveFocusAreas({
    required FitnessGoal goal,
    required List<MuscleGroup> userFocusAreas,
  }) {
    if (userFocusAreas.isNotEmpty) {
      return _deduplicateMuscles(userFocusAreas);
    }

    return _deduplicateMuscles(
      defaultFocusAreas(goal),
    );
  }

  /// Whether the user explicitly selected focus muscles.
  ///
  /// Useful when a caller needs to distinguish:
  ///
  ///     "no preference"
  ///
  /// from:
  ///
  ///     "user explicitly selected these muscles."
  static bool hasExplicitFocusAreas(
    List<MuscleGroup> userFocusAreas,
  ) {
    return userFocusAreas.isNotEmpty;
  }

  /// Returns true when exactly one muscle was explicitly selected.
  ///
  /// This is useful for strict specialized programs such as:
  ///
  ///     [absCore] → Abs/Core-only program
  ///     [glutes]  → Glutes-only program
  static bool isSingleFocus(
    List<MuscleGroup> focusMuscles,
  ) {
    return _deduplicateMuscles(focusMuscles).length == 1;
  }

  static bool isBroadFocus(
    List<MuscleGroup> focusMuscles,
  ) {
    final normalized = _deduplicateMuscles(focusMuscles);

    if (normalized.isEmpty) {
      return false;
    }

    // A broad explicit selection means the user selected enough major
    // muscle groups to request a balanced program.
    //
    // 7+ muscles is always considered broad.
    if (normalized.length >= 7) {
      return true;
    }

    // Three or more major muscle regions also represent a balanced request.
    final regions = normalized.map(_muscleRegion).toSet();

    if (regions.length >= 3) {
      return true;
    }

    // Standard hypertrophy/default focus:
    // Chest + Back + Shoulders must keep the predefined split structure.
    //
    // This prevents the default build-muscle focus from being interpreted
    // as a narrow specialized program.
    const standardUpperHypertrophyFocus = {
      MuscleGroup.chest,
      MuscleGroup.back,
      MuscleGroup.shoulders,
    };

    if (normalized.length == standardUpperHypertrophyFocus.length &&
        normalized.toSet().containsAll(standardUpperHypertrophyFocus)) {
      return true;
    }

    return false;
  }

  /// Returns true when the focus should be treated as a specialized
  /// program rather than merely a priority within a predefined split.
  ///
  /// Current deterministic policy:
  ///
  /// • one focus muscle → specialized
  /// • two focus muscles from the same region → specialized
  /// • narrow multi-muscle focus → specialized
  /// • broad focus → normal predefined split
  static bool isSpecializedFocus(
    List<MuscleGroup> focusMuscles,
  ) {
    final normalized = _deduplicateMuscles(focusMuscles);

    if (normalized.isEmpty) {
      return false;
    }

    if (normalized.length == 1) {
      return true;
    }

    if (isBroadFocus(normalized)) {
      return false;
    }

    final regions = normalized.map(_muscleRegion).toSet();

    return normalized.length <= 3 && regions.length <= 2;
  }

  // ============================================================
  // Avoided Muscles
  // ============================================================

  /// Merges profile-level avoided muscles with a one-off extra list
  /// (e.g. regeneration options).
  ///
  /// Profile remains the source of truth.
  static List<MuscleGroup> resolveAvoidedMuscles({
    required List<MuscleGroup> profileAvoided,
    List<MuscleGroup>? extra,
  }) {
    final merged = <MuscleGroup>{
      ...profileAvoided,
      ...?extra,
    };

    return List<MuscleGroup>.unmodifiable(
      merged,
    );
  }

  static bool exerciseTargetsAvoided({
    required List<MuscleGroup> primaryMuscles,
    required List<MuscleGroup> avoidedMuscles,
  }) {
    if (avoidedMuscles.isEmpty) {
      return false;
    }

    return primaryMuscles.any(
      avoidedMuscles.contains,
    );
  }

  // ============================================================
  // Recovery / Activity
  // ============================================================

  /// Softens a daily recovery volume cut so very/extra-active users are not
  /// penalized twice.
  ///
  /// Example:
  ///
  /// 0.70 → 0.85 for very active users.
  static double dampenRecoveryVolumeMultiplier({
    required double volumeMultiplier,
    required ActivityLevel activityLevel,
  }) {
    if (volumeMultiplier >= 1.0) {
      return volumeMultiplier;
    }

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

  /// Session exercise-count offset from daily activity.
  static int activityVolumeOffset(
    ActivityLevel activityLevel,
  ) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return -1;

      case ActivityLevel.lightlyActive:
      case ActivityLevel.moderatelyActive:
        return 0;

      case ActivityLevel.veryActive:
      case ActivityLevel.extraActive:
        return 1;
    }
  }

  // ============================================================
  // Experience / Exercise suitability
  // ============================================================

  /// Beginners skip advanced-only movements; intermediate/advanced users
  /// retain the full appropriate pool.
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

  // ============================================================
  // Goal helpers
  // ============================================================

  /// Legacy goal/split compatibility helper retained for callers that still
  /// need to inspect the suitability of a predefined split.
  ///
  /// This method no longer drives weekly split selection.
  /// The predefined split is selected first; focus validation is responsible
  /// for adapting it afterwards.
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
        if (split.isFullBody && workoutDays <= 3) {
          return 8;
        }

        if ((split.isUpperBody || split.isLowerBody) && workoutDays <= 4) {
          return 5;
        }

        if (split.name == 'Legs') {
          return 3;
        }

        return 0;

      case FitnessGoal.loseFat:
        if (split.isFullBody) {
          return 7;
        }

        if (split.isUpperBody || split.isLowerBody) {
          return 4;
        }

        return 0;

      case FitnessGoal.improveEndurance:
        if (split.isFullBody) {
          return 8;
        }

        if (split.name == 'Legs' || split.name == 'Lower Body') {
          return 4;
        }

        return 0;

      case FitnessGoal.generalFitness:
        if (split.isFullBody) {
          return 6;
        }

        if (split.isUpperBody || split.isLowerBody) {
          return 5;
        }

        return 0;
    }
  }

  // ============================================================
  // Focus / Muscle Utilities
  // ============================================================

  static List<MuscleGroup> _deduplicateMuscles(
    Iterable<MuscleGroup> muscles,
  ) {
    return List<MuscleGroup>.unmodifiable(
      <MuscleGroup>{
        ...muscles,
      },
    );
  }

  static String _muscleRegion(
    MuscleGroup muscle,
  ) {
    switch (muscle) {
      case MuscleGroup.chest:
      case MuscleGroup.back:
      case MuscleGroup.shoulders:
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
      case MuscleGroup.forearms:
      case MuscleGroup.traps:
        return 'upper';

      case MuscleGroup.quadriceps:
      case MuscleGroup.hamstrings:
      case MuscleGroup.glutes:
      case MuscleGroup.calves:
      case MuscleGroup.adductors:
        return 'lower';

      case MuscleGroup.absCore:
        return 'core';
    }
  }
}
