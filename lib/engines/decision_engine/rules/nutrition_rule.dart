import 'package:gymgenius/domain/entities/workout_decision.dart';

import '../models/decision_context.dart';
import 'decision_rule.dart';

class NutritionRule implements DecisionRule {
  const NutritionRule();

  @override
  WorkoutDecision evaluate(
    DecisionContext context,
  ) {
    // Nutrition Engine arrives in Phase 3.

    return WorkoutDecision.keepPlannedWorkout();
  }
}
