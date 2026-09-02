import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';

/// Repository of every split known by the Workout Engine.
///
/// The catalog keeps two concepts together:
///
/// 1. Individual [MuscleSplit] definitions used by the generator.
/// 2. Predefined weekly templates inherited from the stable v1/v2 logic.
///
/// The weekly templates are selected by workout-day count.
/// Focus-area validation/adaptation is handled outside this catalog.
class SplitCatalog {
  SplitCatalog._();

  // ============================================================
  // Individual split definitions
  // ============================================================

  static const MuscleSplit upperBody = MuscleSplit(
    name: 'Upper Body',
    theme: 'Full Upper Body',
    muscles: [
      MuscleGroup.chest,
      MuscleGroup.back,
      MuscleGroup.shoulders,
      MuscleGroup.biceps,
      MuscleGroup.triceps,
      MuscleGroup.absCore,
    ],
    recoveryCost: 3,
    isUpperBody: true,
  );

  static const MuscleSplit lowerBody = MuscleSplit(
    name: 'Lower Body',
    theme: 'Full Lower Body',
    muscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.hamstrings,
      MuscleGroup.glutes,
      MuscleGroup.adductors,
      MuscleGroup.calves,
      MuscleGroup.absCore,
    ],
    recoveryCost: 3,
    isLowerBody: true,
  );

  static const MuscleSplit push = MuscleSplit(
    name: 'Push',
    theme: 'Chest • Shoulders • Triceps',
    muscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
      MuscleGroup.absCore,
    ],
    recoveryCost: 2,
    isUpperBody: true,
  );

  static const MuscleSplit pull = MuscleSplit(
    name: 'Pull',
    theme: 'Back • Biceps',
    muscles: [
      MuscleGroup.back,
      MuscleGroup.biceps,
      MuscleGroup.forearms,
      MuscleGroup.shoulders,
    ],
    recoveryCost: 2,
    isUpperBody: true,
  );

  static const MuscleSplit legs = MuscleSplit(
    name: 'Legs',
    theme: 'Legs • Glutes • Adductors',
    muscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.hamstrings,
      MuscleGroup.glutes,
      MuscleGroup.adductors,
      MuscleGroup.calves,
    ],
    recoveryCost: 3,
    isLowerBody: true,
  );

  static const MuscleSplit chest = MuscleSplit(
    name: 'Chest',
    theme: 'Chest Focus',
    muscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
    ],
    recoveryCost: 2,
    isUpperBody: true,
  );

  static const MuscleSplit back = MuscleSplit(
    name: 'Back',
    theme: 'Back Focus',
    muscles: [
      MuscleGroup.back,
      MuscleGroup.shoulders,
    ],
    recoveryCost: 2,
    isUpperBody: true,
  );

  static const MuscleSplit arms = MuscleSplit(
    name: 'Arms',
    theme: 'Arms Focus',
    muscles: [
      MuscleGroup.biceps,
      MuscleGroup.triceps,
      MuscleGroup.forearms,
    ],
    recoveryCost: 1,
    isUpperBody: true,
  );

  static const MuscleSplit chestTriceps = MuscleSplit(
    name: 'Chest & Triceps',
    theme: 'Chest & Triceps',
    muscles: [
      MuscleGroup.chest,
      MuscleGroup.triceps,
      MuscleGroup.shoulders,
    ],
    recoveryCost: 2,
    isUpperBody: true,
  );

  static const MuscleSplit backBiceps = MuscleSplit(
    name: 'Back & Biceps',
    theme: 'Back & Biceps',
    muscles: [
      MuscleGroup.back,
      MuscleGroup.biceps,
      MuscleGroup.forearms,
      MuscleGroup.shoulders,
    ],
    recoveryCost: 2,
    isUpperBody: true,
  );

  static const MuscleSplit shouldersAndCore = MuscleSplit(
    name: 'Shoulders & Core',
    theme: 'Shoulders & Core',
    muscles: [
      MuscleGroup.shoulders,
      MuscleGroup.traps,
      MuscleGroup.absCore,
    ],
    recoveryCost: 1,
    isUpperBody: true,
  );

  static const MuscleSplit fullBody = MuscleSplit(
    name: 'Full Body',
    theme: 'Complete Body',
    muscles: [
      MuscleGroup.chest,
      MuscleGroup.back,
      MuscleGroup.shoulders,
      MuscleGroup.biceps,
      MuscleGroup.triceps,
      MuscleGroup.quadriceps,
      MuscleGroup.hamstrings,
      MuscleGroup.glutes,
      MuscleGroup.adductors,
      MuscleGroup.calves,
      MuscleGroup.absCore,
    ],
    recoveryCost: 4,
    isFullBody: true,
  );

  // ============================================================
  // Complete individual split catalog
  // ============================================================

  static const List<MuscleSplit> all = [
    upperBody,
    lowerBody,
    push,
    pull,
    legs,
    chest,
    back,
    arms,
    chestTriceps,
    backBiceps,
    shouldersAndCore,
    fullBody,
  ];

  // ============================================================
  // Stable v1/v2 weekly templates
  // ============================================================

  /// 1-day fallback.
  ///
  /// Full Body is used when only one workout is available.
  static const List<MuscleSplit> oneDayTemplate = [
    fullBody,
  ];

  /// 2-day Upper / Lower.
  static const List<MuscleSplit> twoDayTemplate = [
    upperBody,
    lowerBody,
  ];

  /// 3-day Push / Pull / Legs.
  static const List<MuscleSplit> threeDayTemplate = [
    push,
    pull,
    legs,
  ];

  /// 4-day Chest & Triceps / Back & Biceps / Legs / Shoulders & Core.
  static const List<MuscleSplit> fourDayTemplate = [
    chestTriceps,
    backBiceps,
    legs,
    shouldersAndCore,
  ];

  /// 5-day Chest / Back / Legs / Arms / Shoulders & Core.
  static const List<MuscleSplit> fiveDayTemplate = [
    chest,
    back,
    legs,
    arms,
    shouldersAndCore,
  ];

  /// 6-day template.
  ///
  /// Reuses the stable 3-day Push / Pull / Legs structure twice.
  ///
  /// The selector and previous-program variety logic are responsible
  /// for exercise variation between repeated split types.
  static const List<MuscleSplit> sixDayTemplate = [
    push,
    pull,
    legs,
    push,
    pull,
    legs,
  ];

  /// 7-day template.
  ///
  /// Six training days follow Push / Pull / Legs twice, with the final
  /// day represented as Full Body for callers that explicitly request
  /// seven training days.
  ///
  /// Higher-level recovery logic may still decide to avoid generating
  /// seven consecutive training sessions.
  static const List<MuscleSplit> sevenDayTemplate = [
    push,
    pull,
    legs,
    push,
    pull,
    legs,
    fullBody,
  ];

  /// Returns the stable predefined weekly template for [workoutDays].
  ///
  /// This method intentionally does not inspect focus areas.
  /// Focus-based validation/adaptation belongs to SplitPlanner and
  /// SplitFocusValidator.
  static List<MuscleSplit> templateForDays(int workoutDays) {
    switch (workoutDays) {
      case 1:
        return oneDayTemplate;

      case 2:
        return twoDayTemplate;

      case 3:
        return threeDayTemplate;

      case 4:
        return fourDayTemplate;

      case 5:
        return fiveDayTemplate;

      case 6:
        return sixDayTemplate;

      case 7:
        return sevenDayTemplate;

      default:
        if (workoutDays <= 0) {
          return const [];
        }

        return workoutDays < 2
            ? oneDayTemplate
            : workoutDays < 3
                ? twoDayTemplate
                : workoutDays < 4
                    ? threeDayTemplate
                    : workoutDays < 5
                        ? fourDayTemplate
                        : fiveDayTemplate;
    }
  }

  /// Returns a copy of the predefined template.
  ///
  /// The returned list can safely be modified by the caller without
  /// mutating the static catalog.
  static List<MuscleSplit> templateCopyForDays(int workoutDays) {
    return List<MuscleSplit>.from(
      templateForDays(workoutDays),
    );
  }

  /// Finds a split by its exact name.
  static MuscleSplit? byName(String name) {
    final normalized = name.trim().toLowerCase();

    if (normalized.isEmpty) {
      return null;
    }

    for (final split in all) {
      if (split.name.toLowerCase() == normalized) {
        return split;
      }
    }

    return null;
  }

  /// Returns all split definitions whose primary classification matches
  /// the requested body-region flags.
  static List<MuscleSplit> where({
    bool? upperBody,
    bool? lowerBody,
    bool? fullBody,
  }) {
    return all.where((split) {
      if (upperBody != null && split.isUpperBody != upperBody) {
        return false;
      }

      if (lowerBody != null && split.isLowerBody != lowerBody) {
        return false;
      }

      if (fullBody != null && split.isFullBody != fullBody) {
        return false;
      }

      return true;
    }).toList();
  }
}
