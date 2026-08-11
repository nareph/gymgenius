import 'package:gymgenius/domain/entities/workout_decision.dart';

import '../models/decision_context.dart';
import 'decision_rule.dart';

/// Nutrition-domain rule for workout adaptation.
///
/// Phase 3: nutrition targets are attached to [DailyPlan] by the Decision
/// Engine via NutritionEngine. This rule does not force workout changes yet
/// (Recovery / Progress cross-domain adjustments come later).
class NutritionRule implements DecisionRule {
  const NutritionRule();

  @override
  WorkoutDecision evaluate(
    DecisionContext context,
  ) {
    return WorkoutDecision.keepPlannedWorkout();
  }
}
