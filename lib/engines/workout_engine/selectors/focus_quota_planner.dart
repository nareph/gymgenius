// lib/engines/workout_engine/selectors/focus_quota_planner.dart

import 'dart:math';

import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/focus_plan.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';

/// Computes intelligent focus quotas.
///
/// The planner considers:
///
/// • workout size
/// • number of primary focus muscles
/// • split composition
/// • muscles naturally belonging to the split
///
/// It also exposes [secondaryFocusMuscles].
///
/// Secondary focus muscles are NOT given mandatory quotas.
/// They simply tell the selector which other muscles should remain
/// relevant when filling the remaining workout slots.
///
/// Example:
///
/// Push + focus [chest]
///
/// quotas:
///   chest -> 2
///
/// secondaryFocusMuscles:
///   shoulders
///   triceps
///   absCore
///
/// The selector therefore guarantees the chest quota while still
/// favoring the natural Push muscles for the remaining exercises.
class FocusQuotaPlanner {
  const FocusQuotaPlanner();

  //===========================================================================
  // Public API
  //===========================================================================

  FocusPlan buildPlan({
    required MuscleSplit split,
    required List<MuscleGroup> focusMuscles,
    required int desiredExerciseCount,
  }) {
    if (focusMuscles.isEmpty) {
      return FocusPlan(
        quotas: const {},
        reservedExercises: 0,
        secondaryFocusMuscles: _buildSecondaryFocusMuscles(
          split: split,
          primaryFocusMuscles: const [],
        ),
      );
    }

    final reserved = min(
      _reservedFocusExercises(desiredExerciseCount),
      desiredExerciseCount,
    );

    final quotas = <MuscleGroup, int>{};

    //-----------------------------------------------------------------------
    // One primary focus
    //-----------------------------------------------------------------------

    if (focusMuscles.length == 1) {
      quotas.addAll(
        _quotaForSingleFocus(
          split: split,
          muscle: focusMuscles.first,
          reserved: reserved,
        ),
      );

      return FocusPlan(
        quotas: quotas,
        reservedExercises: _totalQuota(quotas),
        secondaryFocusMuscles: _buildSecondaryFocusMuscles(
          split: split,
          primaryFocusMuscles: focusMuscles,
        ),
      );
    }

    //-----------------------------------------------------------------------
    // Two primary focuses
    //-----------------------------------------------------------------------

    if (focusMuscles.length == 2) {
      quotas.addAll(
        _quotaForTwoFocuses(
          split: split,
          muscles: focusMuscles,
          reserved: reserved,
        ),
      );

      return FocusPlan(
        quotas: quotas,
        reservedExercises: min(
          reserved,
          _totalQuota(quotas),
        ),
        secondaryFocusMuscles: _buildSecondaryFocusMuscles(
          split: split,
          primaryFocusMuscles: focusMuscles,
        ),
      );
    }

    //-----------------------------------------------------------------------
    // Three or more primary focuses
    //-----------------------------------------------------------------------

    quotas.addAll(
      _quotaForMultipleFocuses(
        split: split,
        muscles: focusMuscles,
        reserved: reserved,
      ),
    );

    return FocusPlan(
      quotas: quotas,
      reservedExercises: min(
        reserved,
        _totalQuota(quotas),
      ),
      secondaryFocusMuscles: _buildSecondaryFocusMuscles(
        split: split,
        primaryFocusMuscles: focusMuscles,
      ),
    );
  }

  //===========================================================================
  // Reserved exercises
  //===========================================================================

  /// Determines how many exercises are reserved for primary focus muscles.
  ///
  /// desired = 1-4 -> 1
  /// desired = 5-6 -> 2
  /// desired >= 7 -> 3
  ///
  /// The planner deliberately does not reserve the whole workout.
  int _reservedFocusExercises(
    int desiredExerciseCount,
  ) {
    if (desiredExerciseCount <= 0) {
      return 0;
    }

    if (desiredExerciseCount <= 4) {
      return 1;
    }

    if (desiredExerciseCount <= 6) {
      return 2;
    }

    return 3;
  }

  //===========================================================================
  // Single primary focus
  //===========================================================================

  Map<MuscleGroup, int> _quotaForSingleFocus({
    required MuscleSplit split,
    required MuscleGroup muscle,
    required int reserved,
  }) {
    if (reserved <= 0) {
      return {
        muscle: 0,
      };
    }

    return {
      muscle: reserved,
    };
  }

  //===========================================================================
  // Two primary focuses
  //===========================================================================

  Map<MuscleGroup, int> _quotaForTwoFocuses({
    required MuscleSplit split,
    required List<MuscleGroup> muscles,
    required int reserved,
  }) {
    final quotas = <MuscleGroup, int>{
      for (final muscle in muscles) muscle: 0,
    };

    if (reserved <= 0) {
      return quotas;
    }

    //-----------------------------------------------------------------------
    // One reserved exercise:
    // prioritize the first requested focus.
    //-----------------------------------------------------------------------

    if (reserved == 1) {
      quotas[muscles.first] = 1;
      return quotas;
    }

    //-----------------------------------------------------------------------
    // Two reserved exercises:
    // one for each focus.
    //-----------------------------------------------------------------------

    if (reserved == 2) {
      quotas[muscles.first] = 1;
      quotas[muscles.last] = 1;
      return quotas;
    }

    //-----------------------------------------------------------------------
    // Three reserved exercises:
    // favor the first focus while still covering the second.
    //-----------------------------------------------------------------------

    quotas[muscles.first] = 2;
    quotas[muscles.last] = 1;

    return quotas;
  }

  //===========================================================================
  // Three or more primary focuses
  //===========================================================================

  Map<MuscleGroup, int> _quotaForMultipleFocuses({
    required MuscleSplit split,
    required List<MuscleGroup> muscles,
    required int reserved,
  }) {
    final quotas = <MuscleGroup, int>{
      for (final muscle in muscles) muscle: 0,
    };

    var remaining = reserved;

    if (remaining <= 0) {
      return quotas;
    }

    //-----------------------------------------------------------------------
    // First pass:
    // native split muscles receive priority.
    //-----------------------------------------------------------------------

    for (final muscle in muscles) {
      if (remaining == 0) {
        break;
      }

      if (_isNativeToSplit(split, muscle)) {
        quotas[muscle] = quotas[muscle]! + 1;
        remaining--;
      }
    }

    //-----------------------------------------------------------------------
    // Second pass:
    // if quota remains, cover non-native primary focuses.
    //-----------------------------------------------------------------------

    for (final muscle in muscles) {
      if (remaining == 0) {
        break;
      }

      if (quotas[muscle] == 0) {
        quotas[muscle] = 1;
        remaining--;
      }
    }

    //-----------------------------------------------------------------------
    // Third pass:
    // distribute remaining quota to native split muscles.
    //-----------------------------------------------------------------------

    while (remaining > 0) {
      var allocated = false;

      for (final muscle in muscles) {
        if (remaining == 0) {
          break;
        }

        if (_isNativeToSplit(split, muscle)) {
          quotas[muscle] = quotas[muscle]! + 1;
          remaining--;
          allocated = true;
        }
      }

      if (!allocated) {
        break;
      }
    }

    return quotas;
  }

  //===========================================================================
  // Secondary focus muscles
  //===========================================================================

  /// Builds secondary focus muscles from the current split.
  ///
  /// Rules:
  ///
  /// 1. Only muscles belonging to the split are eligible.
  /// 2. Primary focus muscles are removed.
  /// 3. Order is preserved from [split.muscles].
  ///
  /// Example:
  ///
  /// Push:
  /// [chest, shoulders, triceps, absCore]
  ///
  /// Primary:
  /// [chest]
  ///
  /// Result:
  /// [shoulders, triceps, absCore]
  List<MuscleGroup> _buildSecondaryFocusMuscles({
    required MuscleSplit split,
    required List<MuscleGroup> primaryFocusMuscles,
  }) {
    final primary = primaryFocusMuscles.toSet();

    final secondary = <MuscleGroup>[];

    for (final muscle in split.muscles) {
      if (primary.contains(muscle)) {
        continue;
      }

      if (secondary.contains(muscle)) {
        continue;
      }

      secondary.add(muscle);
    }

    return List.unmodifiable(secondary);
  }

  //===========================================================================
  // Helpers
  //===========================================================================

  bool _isNativeToSplit(
    MuscleSplit split,
    MuscleGroup muscle,
  ) {
    return split.muscles.contains(muscle);
  }

  int _totalQuota(
    Map<MuscleGroup, int> quotas,
  ) {
    return quotas.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
  }
}
