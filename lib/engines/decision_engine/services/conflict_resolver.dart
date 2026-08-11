import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/decision_engine/decision_priorities.dart';

/// Resolves multiple WorkoutDecision objects into a single final decision.
///
/// Every DecisionRule is independent.
/// Therefore several rules may trigger simultaneously.
///
/// Priority is defined by [DecisionPriorities.adjustmentRanks]
/// (highest → lowest):
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
/// Domain evaluation order (Injury/Safety > Recovery > …) is documented
/// in [DecisionPriorities.domainEvaluationOrder] and mirrored in DI.
class ConflictResolver {
  const ConflictResolver();

  WorkoutDecision resolve(
    List<WorkoutDecision> decisions,
  ) {
    if (decisions.isEmpty) {
      return WorkoutDecision.keepPlannedWorkout();
    }

    if (decisions.length == 1) {
      return decisions.first.copyWith(
        confidence: decisions.first.confidence.clamp(0.0, 1.0),
      );
    }

    final ordered = [...decisions]..sort(
        (a, b) => _priority(b.adjustment).compareTo(
          _priority(a.adjustment),
        ),
      );

    final winner = ordered.first;

    return winner.copyWith(
      reasons: ordered.expand((d) => d.reasons).toSet().toList(),
      confidence: ordered
          .map((d) => d.confidence)
          .reduce((a, b) => a > b ? a : b)
          .clamp(0.0, 1.0),
    );
  }

  int _priority(WorkoutAdjustment adjustment) {
    return DecisionPriorities.adjustmentRanks[adjustment.name] ?? 0;
  }
}
