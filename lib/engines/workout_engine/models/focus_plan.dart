// lib/engines/workout_engine/models/focus_plan.dart

import 'package:gymgenius/domain/enums/muscle_group.dart';

/// Immutable planning result returned by FocusQuotaPlanner.
///
/// Contains:
///
/// • minimum quota per primary focus muscle
/// • total number of reserved focus exercises
/// • secondary focus muscles belonging to the current split
class FocusPlan {
  final Map<MuscleGroup, int> quotas;

  final int reservedExercises;

  /// Muscles that belong to the split but were not explicitly selected
  /// as primary focus muscles.
  ///
  /// These muscles are NOT mandatory quotas.
  /// They are secondary priorities used when filling remaining slots.
  final List<MuscleGroup> secondaryFocusMuscles;

  const FocusPlan({
    required this.quotas,
    required this.reservedExercises,
    this.secondaryFocusMuscles = const [],
  });

  bool get hasFocus => quotas.isNotEmpty;

  bool get hasSecondaryFocus => secondaryFocusMuscles.isNotEmpty;

  int quotaFor(MuscleGroup muscle) {
    return quotas[muscle] ?? 0;
  }

  bool contains(MuscleGroup muscle) {
    return quotas.containsKey(muscle);
  }

  bool isSecondaryFocus(MuscleGroup muscle) {
    return secondaryFocusMuscles.contains(muscle);
  }

  @override
  String toString() {
    return 'FocusPlan('
        'reservedExercises: $reservedExercises, '
        'quotas: $quotas, '
        'secondaryFocusMuscles: $secondaryFocusMuscles'
        ')';
  }
}
