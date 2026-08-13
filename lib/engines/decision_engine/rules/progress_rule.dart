import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/engines/decision_engine/models/decision_context.dart';
import 'package:gymgenius/engines/decision_engine/rules/decision_rule.dart';

/// Decision Engine rule for the progress domain.
///
/// **Observe-only for today's session** — never modifies [TodayWorkout].
/// Plateau / consistency can still trigger a **program** refresh via
/// [ProgramRefreshPolicy] on [DailyPlan], which is a separate Decision Engine
/// output from this rule.
class ProgressRule implements DecisionRule {
  const ProgressRule();

  @override
  WorkoutDecision evaluate(DecisionContext context) {
    // Progress intelligence does not alter workouts in Phase 5.
    return WorkoutDecision.keepPlannedWorkout();
  }
}
