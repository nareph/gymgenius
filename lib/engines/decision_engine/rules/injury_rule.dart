import 'package:gymgenius/domain/entities/workout_decision.dart';

import '../models/decision_context.dart';
import 'decision_rule.dart';

/// Handles injury and medical risk evaluation.
///
/// This rule has the highest priority in the decision pipeline.
///
/// Future inputs:
///
/// • InjuryRisk
/// • Pain reports
/// • Medical restrictions
/// • Joint status
/// • Movement screening
///
/// Possible future decisions:
///
/// • Rest day
/// • Recovery session
/// • Replace exercises
/// • Reduce intensity
class InjuryRule implements DecisionRule {
  const InjuryRule();

  @override
  WorkoutDecision evaluate(
    DecisionContext context,
  ) {
    // Injury Engine not integrated yet.

    return WorkoutDecision.keepPlannedWorkout();
  }
}
