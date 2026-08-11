import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/engines/decision_engine/models/decision_context.dart';
import 'package:gymgenius/engines/decision_engine/rules/decision_rule.dart';

/// Decision Engine rule for the progress domain (Phase 5).
///
/// **Observe-only** — never modifies the workout plan.
/// Plateau and regression signals are exposed via [DecisionContext.progressSnapshot]
/// for UI, analytics, and future AI Coach integration.
class ProgressRule implements DecisionRule {
  const ProgressRule();

  @override
  WorkoutDecision evaluate(DecisionContext context) {
    // Progress intelligence does not alter workouts in Phase 5.
    return WorkoutDecision.keepPlannedWorkout();
  }
}
