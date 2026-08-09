// lib/engines/workout_engine/selectors/selection_state.dart

import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// Mutable state used during the selection of ONE workout.
///
/// This object is intentionally the single source of truth for everything
/// accumulated while the selector builds the workout.
///
/// It currently tracks:
///
/// • selected exercises
/// • used exercise names
/// • used movement patterns
/// • primary muscle coverage
/// • secondary muscle coverage (future scoring)
///
/// Future versions can also store:
///
/// • accumulated volume
/// • fatigue
/// • push/pull balance
/// • unilateral balance
/// • equipment usage
class SelectionState {
  SelectionState();

  //==============================================================
  // Selected exercises
  //==============================================================

  final List<ExercisePoolEntry> selected = [];

  int get exerciseCount => selected.length;

  bool isComplete(int desiredCount) => selected.length >= desiredCount;

  //==============================================================
  // Duplicate protection
  //==============================================================

  final Set<String> _exerciseNames = {};

  bool containsExercise(String name) {
    return _exerciseNames.contains(name);
  }

  //==============================================================
  // Movement diversity
  //==============================================================

  final Set<String> _movementPatterns = {};

  bool containsPattern(String pattern) {
    return _movementPatterns.contains(pattern);
  }

  //==============================================================
  // Muscle coverage
  //==============================================================

  /// Primary muscles receive full credit.
  final Map<MuscleGroup, int> _primaryCoverage = {};

  /// Secondary muscles are tracked independently.
  ///
  /// They are NOT yet used by ExerciseScorer, but having this information
  /// available makes future improvements much easier.
  final Map<MuscleGroup, int> _secondaryCoverage = {};

  /// Number of exercises primarily targeting [muscle].
  int coverageCount(MuscleGroup muscle) {
    return _primaryCoverage[muscle] ?? 0;
  }

  /// Number of exercises secondarily targeting [muscle].
  int secondaryCoverageCount(MuscleGroup muscle) {
    return _secondaryCoverage[muscle] ?? 0;
  }

  /// Combined coverage.
  ///
  /// Secondary muscles count as half an exercise.
  double totalCoverage(MuscleGroup muscle) {
    return coverageCount(muscle) + secondaryCoverageCount(muscle) * 0.5;
  }

  bool coversMuscle(MuscleGroup muscle) {
    return totalCoverage(muscle) > 0;
  }

  //==============================================================
  // Registration
  //==============================================================

  void add(ExercisePoolEntry entry) {
    selected.add(entry);

    _exerciseNames.add(entry.name);

    _movementPatterns.add(entry.movementPattern.name);

    //------------------------------------------------------------
    // Primary muscles
    //------------------------------------------------------------

    for (final muscle in entry.targetMuscles) {
      _primaryCoverage.update(
        muscle,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    //------------------------------------------------------------
    // Secondary muscles
    //------------------------------------------------------------

    for (final muscle in entry.secondaryMuscles) {
      _secondaryCoverage.update(
        muscle,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
  }

  //==============================================================
  // Focus helpers
  //==============================================================

  bool hasCoveredAllFocusMuscles(
    List<MuscleGroup> focusMuscles,
  ) {
    if (focusMuscles.isEmpty) {
      return true;
    }

    return focusMuscles.every(coversMuscle);
  }

  int missingFocusMusclesCount(
    List<MuscleGroup> focusMuscles,
  ) {
    return focusMuscles
        .where(
          (muscle) => !coversMuscle(muscle),
        )
        .length;
  }

  //==============================================================
  // Reset
  //==============================================================

  void clear() {
    selected.clear();

    _exerciseNames.clear();

    _movementPatterns.clear();

    _primaryCoverage.clear();

    _secondaryCoverage.clear();
  }
}
