import 'package:gymgenius/domain/entities/workout_decision.dart';

import '../models/decision_context.dart';
import 'decision_rule.dart';

class RecoveryRule implements DecisionRule {
  const RecoveryRule();

  @override
  WorkoutDecision evaluate(
    DecisionContext context,
  ) {
    // Phase 2:
    // Recovery Engine not integrated yet.

    return WorkoutDecision.keepPlannedWorkout();
  }
}
