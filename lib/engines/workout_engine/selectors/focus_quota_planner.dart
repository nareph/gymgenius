// lib/engines/workout_engine/selectors/focus_quota_planner.dart

import 'dart:math';

import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/focus_plan.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';

/// Computes focus quotas for a single workout session.
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

    if (desiredExerciseCount <= 0) {
      return FocusPlan(
        quotas: const {},
        reservedExercises: 0,
        secondaryFocusMuscles: secondaryFocusMuscles,
      );
    }

    final reserved = min(
      _reservedFocusExercises(desiredExerciseCount),
      desiredExerciseCount,
    );

    final quotas = <MuscleGroup, int>{};

    // -----------------------------------------------------------------------
    // Strict split:
    //
    // The split itself contains only the user's selected focus muscles.
    // In that situation every exercise slot is allowed to contribute to
    // those selected muscles. The quota is distributed across the whole
    // split instead of privileging only the first muscle.
    // -----------------------------------------------------------------------

    final nativeFocus =
        normalizedFocus.where(split.targets).toList(growable: false);

    final strictFocus = nativeFocus.length == normalizedFocus.length &&
        split.muscles.every(normalizedFocus.contains);

    if (strictFocus) {
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
    // One focus:
    // keep the explicit focus concentrated.
    // -----------------------------------------------------------------------

    if (normalizedFocus.length == 1) {
      final muscle = normalizedFocus.first;

      if (split.targets(muscle)) {
        quotas[muscle] = reserved;
      }

      return FocusPlan(
        quotas: quotas,
        reservedExercises: _totalQuota(quotas),
        secondaryFocusMuscles: secondaryFocusMuscles,
      );
    }

    // -----------------------------------------------------------------------
    // Two focuses:
    // distribute the reserved quota between the native muscles.
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
    // Broad focus:
    // only the focus muscles that actually belong to the split receive
    // mandatory quotas.
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

  int _reservedFocusExercises(int desiredExerciseCount) {
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

    if (native.length == 1) {
      quotas[native.first] = reserved;
      return quotas;
    }

    final first = (reserved + 1) ~/ 2;
    final second = reserved ~/ 2;

    quotas[native.first] = first;
    quotas[native.last] = second;

    return quotas;
  }

  //===========================================================================
  // Multiple focuses
  //===========================================================================

  Map<MuscleGroup, int> _quotaForMultipleFocusesWithinSplit({
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

    final native = muscles.where(split.targets).toList(growable: false);

    if (native.isEmpty) {
      return quotas;
    }

    var remaining = reserved;

    // First pass: guarantee one exercise for every native focus muscle.
    for (final muscle in native) {
      if (remaining == 0) {
        break;
      }

      quotas[muscle] = 1;
      remaining--;
    }

    // Second pass: distribute remaining quota cyclically across the native
    // focus muscles. This keeps multi-muscle splits balanced.
    //
    // Example:
    // Arms + 8 exercises
    //   Biceps    -> 3
    //   Triceps   -> 3
    //   Forearms  -> 2
    //
    // Legs + 8 exercises
    //   Quadriceps -> 2
    //   Hamstrings -> 2
    //   Glutes     -> 2
    //   Calves     -> 2
    //
    var index = 0;

    while (remaining > 0) {
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
