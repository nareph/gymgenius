import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/recovery_engine/recovery_thresholds.dart';

import '../models/decision_context.dart';
import 'decision_rule.dart';

/// Decision Engine rule for the recovery domain.
///
/// Phase 4 responsibilities:
/// • Consume [DecisionContext.recoveryStatus] produced by RecoveryEngine.
/// • Propose volume reduction using the **same** multiplier as the engine
///   ([RecoveryStatus.volumeMultiplier] backed by [RecoveryThresholds]).
/// • Never overrides safety or injury rules (lower priority via ConflictResolver).
/// • Never forces a rest day in Phase 4 — only volume reduction.
class RecoveryRule implements DecisionRule {
  const RecoveryRule();

  @override
  WorkoutDecision evaluate(DecisionContext context) {
    final recovery = context.recoveryStatus;

    if (recovery == null) {
      return WorkoutDecision.keepPlannedWorkout();
    }

    final readiness = recovery.readinessScore;
    final volumeMult = recovery.volumeMultiplier > 0 &&
            recovery.volumeMultiplier <= RecoveryThresholds.fullVolume
        ? recovery.volumeMultiplier
        : RecoveryThresholds.volumeMultiplier(readiness);

    if (volumeMult >= RecoveryThresholds.fullVolume) {
      return WorkoutDecision.keepPlannedWorkout(
        confidence: _confidence(readiness),
      );
    }

    return WorkoutDecision(
      requiresAdaptation: true,
      adjustment: WorkoutAdjustment.reduceVolume,
      confidence: _confidence(readiness),
      reasons: const [
        DecisionReason.lowRecovery,
        DecisionReason.scheduledWorkout,
      ],
      volumeMultiplier: volumeMult,
    );
  }

  double _confidence(int readiness) {
    return (readiness / 100.0).clamp(0.4, 1.0);
  }
}
