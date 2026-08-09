import 'package:gymgenius/domain/entities/workout_decision.dart';

import '../models/decision_context.dart';
import 'decision_rule.dart';

class DeloadRule implements DecisionRule {
  const DeloadRule();

  @override
  WorkoutDecision evaluate(
    DecisionContext context,
  ) {
    final deloadPlan = context.programProgress.deloadPlan;

    if (!deloadPlan.isDeload) {
      return WorkoutDecision.keepPlannedWorkout();
    }

    // Uses WorkoutDecision.deload() specifically (not the raw
    // constructor with WorkoutAdjustment.reduceVolume) so the real
    // per-phase multipliers from DeloadPlan reach WorkoutAdaptationService
    // -> applyDeload() -> DeloadService, instead of silently falling
    // through to the generic reduceVolume path (fixed 0.7 ratio,
    // ignoring which phase the deload falls in).
    return WorkoutDecision.deload(
      volumeMultiplier: deloadPlan.volumeMultiplier,
      intensityMultiplier: deloadPlan.intensityMultiplier,
      confidence: 0.95,
    );
  }
}
