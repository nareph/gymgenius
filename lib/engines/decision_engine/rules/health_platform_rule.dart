import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/engines/decision_engine/models/decision_context.dart';
import 'package:gymgenius/engines/decision_engine/rules/decision_rule.dart';

/// Health Platform rule (Phase 8).
///
/// **Observe-only** — never modifies the workout plan.
/// Snapshot signals are carried on [DecisionContext.healthPlatformSnapshot]
/// for UI, HealthDecision context, and AI Coach safe labels.
class HealthPlatformRule implements DecisionRule {
  const HealthPlatformRule();

  @override
  WorkoutDecision evaluate(DecisionContext context) {
    return WorkoutDecision.keepPlannedWorkout();
  }
}
