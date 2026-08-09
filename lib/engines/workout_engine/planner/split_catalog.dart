import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';

/// Repository of every split known by the Workout Engine.
///
/// Unlike the previous implementation, splits are no longer grouped
/// into rigid "3_day", "4_day", etc. templates.
///
/// Instead, the SplitPlanner dynamically selects the most appropriate
/// combination according to:
///
/// • workout frequency
/// • focus muscles
/// • experience
/// • recovery balance
///
/// New split types can be added here without changing the planner.
class SplitCatalog {
  SplitCatalog._();

  /// Every available split.
  static const List<MuscleSplit> all = [
    // ============================================================
    // Upper / Lower
    // ============================================================

    MuscleSplit(
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
    ),

    MuscleSplit(
      name: 'Lower Body',
      theme: 'Full Lower Body',
      muscles: [
        MuscleGroup.quadriceps,
        MuscleGroup.hamstrings,
        MuscleGroup.glutes,
        MuscleGroup.calves,
        MuscleGroup.absCore,
      ],
      recoveryCost: 3,
      isLowerBody: true,
    ),

    // ============================================================
    // Push / Pull / Legs
    // ============================================================

    MuscleSplit(
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
    ),

    MuscleSplit(
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
    ),

    MuscleSplit(
      name: 'Legs',
      theme: 'Legs • Glutes',
      muscles: [
        MuscleGroup.quadriceps,
        MuscleGroup.hamstrings,
        MuscleGroup.glutes,
        MuscleGroup.calves,
        MuscleGroup.absCore,
      ],
      recoveryCost: 3,
      isLowerBody: true,
    ),

    // ============================================================
    // Specializations
    // ============================================================

    MuscleSplit(
      name: 'Chest',
      theme: 'Chest Focus',
      muscles: [
        MuscleGroup.chest,
        MuscleGroup.shoulders,
      ],
      recoveryCost: 2,
      isUpperBody: true,
    ),

    MuscleSplit(
      name: 'Back',
      theme: 'Back Focus',
      muscles: [
        MuscleGroup.back,
        MuscleGroup.shoulders,
      ],
      recoveryCost: 2,
      isUpperBody: true,
    ),

    MuscleSplit(
      name: 'Arms',
      theme: 'Arms Focus',
      muscles: [
        MuscleGroup.biceps,
        MuscleGroup.triceps,
        MuscleGroup.forearms,
      ],
      recoveryCost: 1,
      isUpperBody: true,
    ),

    MuscleSplit(
      name: 'Chest & Triceps',
      theme: 'Chest & Triceps',
      muscles: [
        MuscleGroup.chest,
        MuscleGroup.triceps,
        MuscleGroup.shoulders,
      ],
      recoveryCost: 2,
      isUpperBody: true,
    ),

    MuscleSplit(
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
    ),

    MuscleSplit(
      name: 'Shoulders & Core',
      theme: 'Shoulders & Core',
      muscles: [
        MuscleGroup.shoulders,
        MuscleGroup.traps,
        MuscleGroup.absCore,
      ],
      recoveryCost: 1,
      isUpperBody: true,
    ),

    // ============================================================
    // Full Body
    // ============================================================

    MuscleSplit(
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
        MuscleGroup.calves,
        MuscleGroup.absCore,
      ],
      recoveryCost: 4,
      isFullBody: true,
    ),
  ];

  /// Finds a split by name.
  static MuscleSplit? byName(String name) {
    for (final split in all) {
      if (split.name == name) {
        return split;
      }
    }
    return null;
  }
}
