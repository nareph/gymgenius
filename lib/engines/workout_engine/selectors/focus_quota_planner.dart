// lib/engines/workout_engine/selectors/focus_quota_planner.dart

import 'dart:math';

import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/focus_plan.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';

/// Computes focus quotas for a single workout session.
///
/// Focus muscles are treated as primary user intent.
/// Secondary focus muscles are derived from the current split and are
/// available to the selector when filling non-reserved exercise slots.
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
    final normalizedFocus = _normalizeMuscles(focusMuscles);

    final secondaryFocusMuscles = _buildSecondaryFocusMuscles(
      split: split,
      primaryFocusMuscles: normalizedFocus,
    );

    if (normalizedFocus.isEmpty) {
      return FocusPlan(
        quotas: const {},
        reservedExercises: 0,
        secondaryFocusMuscles: secondaryFocusMuscles,
      );
    }

    final reserved = min(
      _reservedFocusExercises(desiredExerciseCount),
      max(0, desiredExerciseCount),
    );

    final quotas = <MuscleGroup, int>{};

    // -----------------------------------------------------------------------
    // Strict/specialized split
    //
    // When the split itself contains only the selected focus muscles,
    // those muscles can receive the complete reserved quota.
    // -----------------------------------------------------------------------

    final nativeFocus =
        normalizedFocus.where(split.targets).toList(growable: false);

    if (nativeFocus.length == normalizedFocus.length &&
        split.muscles.every(normalizedFocus.contains)) {
      quotas.addAll(
        _quotaForMultipleFocusesWithinSplit(
          split: split,
          muscles: nativeFocus,
          reserved: reserved,
        ),
      );

      return FocusPlan(
        quotas: quotas,
        reservedExercises: _totalQuota(quotas),
        secondaryFocusMuscles: secondaryFocusMuscles,
      );
    }

    // -----------------------------------------------------------------------
    // One primary focus
    // -----------------------------------------------------------------------

    if (normalizedFocus.length == 1) {
      final muscle = normalizedFocus.first;

      if (split.targets(muscle)) {
        quotas.addAll(
          _quotaForSingleFocus(
            muscle: muscle,
            reserved: reserved,
          ),
        );
      }

      return FocusPlan(
        quotas: quotas,
        reservedExercises: _totalQuota(quotas),
        secondaryFocusMuscles: secondaryFocusMuscles,
      );
    }

    // -----------------------------------------------------------------------
    // Two primary focuses
    // -----------------------------------------------------------------------

    if (normalizedFocus.length == 2) {
      quotas.addAll(
        _quotaForTwoFocuses(
          split: split,
          muscles: normalizedFocus,
          reserved: reserved,
        ),
      );

      return FocusPlan(
        quotas: quotas,
        reservedExercises: _totalQuota(quotas),
        secondaryFocusMuscles: secondaryFocusMuscles,
      );
    }

    // -----------------------------------------------------------------------
    // Three or more primary focuses
    // -----------------------------------------------------------------------

    quotas.addAll(
      _quotaForMultipleFocusesWithinSplit(
        split: split,
        muscles: normalizedFocus,
        reserved: reserved,
      ),
    );

    return FocusPlan(
      quotas: quotas,
      reservedExercises: _totalQuota(quotas),
      secondaryFocusMuscles: secondaryFocusMuscles,
    );
  }

  //===========================================================================
  // Reserved exercises
  //===========================================================================

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
  // One focus
  //===========================================================================

  Map<MuscleGroup, int> _quotaForSingleFocus({
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
  // Two focuses
  //===========================================================================

  Map<MuscleGroup, int> _quotaForTwoFocuses({
    required MuscleSplit split,
    required List<MuscleGroup> muscles,
    required int reserved,
  }) {
    final quotas = <MuscleGroup, int>{
      for (final muscle in muscles) muscle: 0,
    };

    final native = muscles.where(split.targets).toList(growable: false);

    if (native.isEmpty || reserved <= 0) {
      return quotas;
    }

    if (reserved == 1) {
      quotas[native.first] = 1;
      return quotas;
    }

    if (reserved == 2) {
      if (native.length >= 2) {
        quotas[native[0]] = 1;
        quotas[native[1]] = 1;
      } else {
        quotas[native.first] = 2;
      }

      return quotas;
    }

    if (native.length >= 2) {
      quotas[native[0]] = 2;
      quotas[native[1]] = 1;
    } else {
      quotas[native.first] = reserved;
    }

    return quotas;
  }

  //===========================================================================
  // Three or more focuses
  //===========================================================================

  Map<MuscleGroup, int> _quotaForMultipleFocusesWithinSplit({
    required MuscleSplit split,
    required List<MuscleGroup> muscles,
    required int reserved,
  }) {
    final quotas = <MuscleGroup, int>{
      for (final muscle in muscles) muscle: 0,
    };

    final native = muscles.where(split.targets).toList(growable: false);

    if (native.isEmpty || reserved <= 0) {
      return quotas;
    }

    var remaining = reserved;

    // First give one quota to each native focus muscle.
    for (final muscle in native) {
      if (remaining == 0) {
        break;
      }

      quotas[muscle] = 1;
      remaining--;
    }

    // Then distribute remaining quota among native focus muscles.
    var index = 0;

    while (remaining > 0 && native.isNotEmpty) {
      final muscle = native[index % native.length];
      quotas[muscle] = quotas[muscle]! + 1;
      remaining--;
      index++;
    }

    return quotas;
  }

  //===========================================================================
  // Secondary focus
  //===========================================================================

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

    return List<MuscleGroup>.unmodifiable(secondary);
  }

  //===========================================================================
  // Helpers
  //===========================================================================

  List<MuscleGroup> _normalizeMuscles(
    Iterable<MuscleGroup> muscles,
  ) {
    final seen = <MuscleGroup>{};
    final result = <MuscleGroup>[];

    for (final muscle in muscles) {
      if (seen.add(muscle)) {
        result.add(muscle);
      }
    }

    return result;
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
