import 'package:gymgenius/domain/entities/workout_decision.dart';

import '../models/decision_context.dart';
import 'decision_rule.dart';

class SafetyRule implements DecisionRule {
  const SafetyRule();

  @override
  WorkoutDecision evaluate(
    DecisionContext context,
  ) {
    // Future:
    //
    // • injuries
    // • medical restrictions
    // • contraindications
    // • pain detection

    return WorkoutDecision.keepPlannedWorkout();
  }
}
