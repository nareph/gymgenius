import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';

/// Builds specialized workout-day splits from the user's selected
/// focus muscles.
///
/// This factory is intentionally independent from:
///
/// • SplitCatalog
/// • SplitPlanner
/// • ExerciseSelector
/// • ExerciseScorer
///
/// Its only responsibility is to create valid [MuscleSplit] instances
/// for strict-focus programs.
///
/// Example:
///
/// focus = [absCore]
/// workoutDays = 3
///
/// Produces:
///
/// Focused: Abs / Core Day 1
/// Focused: Abs / Core Day 2
/// Focused: Abs / Core Day 3
///
/// focus = [glutes, absCore]
/// workoutDays = 3
///
/// Produces:
///
/// Focused: Glutes & Abs / Core Day 1
/// Focused: Glutes & Abs / Core Day 2
/// Focused: Glutes & Abs / Core Day 3
class FocusSplitFactory {
  const FocusSplitFactory();

  /// Creates a specialized split for one workout day.
  MuscleSplit create({
    required List<MuscleGroup> focusMuscles,
    required int dayNumber,
  }) {
    final muscles = _normalizeMuscles(focusMuscles);

    if (muscles.isEmpty) {
      throw ArgumentError(
        'FocusSplitFactory requires at least one focus muscle.',
      );
    }

    if (dayNumber <= 0) {
      throw ArgumentError.value(
        dayNumber,
        'dayNumber',
        'must be greater than zero.',
      );
    }

    return MuscleSplit(
      name: _name(
        muscles: muscles,
        dayNumber: dayNumber,
      ),
      theme: _theme(muscles),
      muscles: List<MuscleGroup>.unmodifiable(muscles),
      recoveryCost: _recoveryCost(muscles),
      isUpperBody: _isUpperBodyOnly(muscles),
      isLowerBody: _isLowerBodyOnly(muscles),
      isFullBody: _isFullBodyLike(muscles),
    );
  }

  /// Creates a complete specialized weekly split.
  List<MuscleSplit> createWeek({
    required List<MuscleGroup> focusMuscles,
    required int workoutDays,
  }) {
    final normalizedMuscles = _normalizeMuscles(focusMuscles);

    if (normalizedMuscles.isEmpty || workoutDays <= 0) {
      return const [];
    }

    return List<MuscleSplit>.generate(
      workoutDays,
      (index) => create(
        focusMuscles: normalizedMuscles,
        dayNumber: index + 1,
      ),
      growable: false,
    );
  }

  /// Returns true when the supplied focus can be represented as a single
  /// specialized muscle scope without introducing unrelated regions.
  bool canCreateSpecializedSplit(
    List<MuscleGroup> focusMuscles,
  ) {
    return _normalizeMuscles(focusMuscles).isNotEmpty;
  }

  /// Returns the normalized, unique focus muscles used by the factory.
  List<MuscleGroup> normalizeFocusMuscles(
    List<MuscleGroup> focusMuscles,
  ) {
    return List<MuscleGroup>.unmodifiable(
      _normalizeMuscles(focusMuscles),
    );
  }

  // ============================================================
  // Identity
  // ============================================================

  String _name({
    required List<MuscleGroup> muscles,
    required int dayNumber,
  }) {
    final label = muscles.map((muscle) => muscle.displayName).join(' & ');

    return 'Focused: $label Day $dayNumber';
  }

  String _theme(
    List<MuscleGroup> muscles,
  ) {
    final label = muscles.map((muscle) => muscle.displayName).join(' • ');

    return 'Focused Training • $label';
  }

  // ============================================================
  // Recovery
  // ============================================================

  int _recoveryCost(
    List<MuscleGroup> muscles,
  ) {
    if (muscles.length == 1) {
      return 1;
    }

    if (muscles.length == 2) {
      return 2;
    }

    return 3;
  }

  // ============================================================
  // Body classification
  // ============================================================

  bool _isUpperBodyOnly(
    List<MuscleGroup> muscles,
  ) {
    if (muscles.isEmpty) {
      return false;
    }

    return muscles.every(_isUpperBodyMuscle);
  }

  bool _isLowerBodyOnly(
    List<MuscleGroup> muscles,
  ) {
    if (muscles.isEmpty) {
      return false;
    }

    return muscles.every(_isLowerBodyMuscle);
  }

  bool _isFullBodyLike(
    List<MuscleGroup> muscles,
  ) {
    final regions = muscles.map(_regionOf).toSet();

    return regions.length >= 3;
  }

  bool _isUpperBodyMuscle(
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
        return true;

      case MuscleGroup.quadriceps:
      case MuscleGroup.hamstrings:
      case MuscleGroup.glutes:
      case MuscleGroup.calves:
      case MuscleGroup.adductors:
      case MuscleGroup.absCore:
        return false;
    }
  }

  bool _isLowerBodyMuscle(
    MuscleGroup muscle,
  ) {
    switch (muscle) {
      case MuscleGroup.quadriceps:
      case MuscleGroup.hamstrings:
      case MuscleGroup.glutes:
      case MuscleGroup.calves:
      case MuscleGroup.adductors:
        return true;

      case MuscleGroup.chest:
      case MuscleGroup.back:
      case MuscleGroup.shoulders:
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
      case MuscleGroup.forearms:
      case MuscleGroup.traps:
      case MuscleGroup.absCore:
        return false;
    }
  }

  String _regionOf(
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

  // ============================================================
  // Normalization
  // ============================================================

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
}
