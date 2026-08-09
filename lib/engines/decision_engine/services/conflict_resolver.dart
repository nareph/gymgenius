import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';

/// Resolves multiple WorkoutDecision objects into a single final decision.
///
/// Every DecisionRule is independent.
/// Therefore several rules may trigger simultaneously.
///
/// Example:
///
/// InjuryRule
///     ↓
/// Rest Day
///
/// RecoveryRule
///     ↓
/// Reduce Volume
///
/// ProgressionRule
///     ↓
/// Increase Intensity
///
/// The ConflictResolver determines which decision wins.
///
/// Priority (highest → lowest)
///
/// 1. Rest Day
/// 2. Skip Workout
/// 3. Recovery Session
/// 4. Deload
/// 5. Replace Exercise
/// 6. Reduce Volume
/// 7. Reduce Intensity
/// 8. Increase Volume
/// 9. Increase Intensity
/// 10. None
///
/// Future versions may become much more sophisticated
/// (weighted scores, AI ranking, multi-action merging, etc.).
class ConflictResolver {
  const ConflictResolver();

  WorkoutDecision resolve(
    List<WorkoutDecision> decisions,
  ) {
    if (decisions.isEmpty) {
      return WorkoutDecision.keepPlannedWorkout();
    }

    if (decisions.length == 1) {
      return decisions.first;
    }

    final ordered = [...decisions]..sort(
        (a, b) => _priority(b.adjustment).compareTo(
          _priority(a.adjustment),
        ),
      );

    final winner = ordered.first;

    return winner.copyWith(
      reasons: ordered.expand((d) => d.reasons).toSet().toList(),
      confidence:
          ordered.map((d) => d.confidence).reduce((a, b) => a > b ? a : b),
    );
  }

  int _priority(WorkoutAdjustment adjustment) {
    switch (adjustment) {
      case WorkoutAdjustment.restDay:
        return 100;

      case WorkoutAdjustment.skipWorkout:
        return 90;

      case WorkoutAdjustment.recoverySession:
        return 80;

      case WorkoutAdjustment.deload:
        return 70;

      case WorkoutAdjustment.replaceExercise:
        return 60;

      case WorkoutAdjustment.reduceVolume:
        return 50;

      case WorkoutAdjustment.reduceIntensity:
        return 40;

      case WorkoutAdjustment.increaseVolume:
        return 30;

      case WorkoutAdjustment.increaseIntensity:
        return 20;

      case WorkoutAdjustment.none:
        return 0;
    }
  }
}
