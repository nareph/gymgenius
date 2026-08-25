// lib/engines/decision_engine/rules/recovery_rule.dart

import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/recovery_engine/recovery_thresholds.dart';
import 'package:gymgenius/engines/workout_engine/shared/profile_coherence.dart';

import '../models/decision_context.dart';
import 'decision_rule.dart';

/// Decision Engine rule for recovery.
///
/// No DailyCheckIn:
///     keep planned workout unchanged.
///
/// DailyCheckIn available:
///     use the computed RecoveryStatus volume multiplier.
///
/// Recovery never forces a rest day in Phase 4.
/// It only reduces workout volume.
class RecoveryRule implements DecisionRule {
  const RecoveryRule();

  @override
  WorkoutDecision evaluate(
    DecisionContext context,
  ) {
    final recovery = context.recoveryStatus;

    // No real recovery data.
    if (recovery == null) {
      return WorkoutDecision.keepPlannedWorkout(
        confidence: 1.0,
      );
    }

    final readiness = recovery.readinessScore;

    final rawMultiplier = recovery.volumeMultiplier > 0 &&
            recovery.volumeMultiplier <= RecoveryThresholds.fullVolume
        ? recovery.volumeMultiplier
        : RecoveryThresholds.volumeMultiplier(
            readiness,
          );

    final dampedMultiplier = ProfileCoherence.dampenRecoveryVolumeMultiplier(
      volumeMultiplier: rawMultiplier,
      activityLevel: context.healthProfile.training.activityLevel,
    );

    if (dampedMultiplier >= RecoveryThresholds.fullVolume) {
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
      volumeMultiplier: dampedMultiplier,
    );
  }

  double _confidence(
    int readiness,
  ) {
    return (readiness / 100.0).clamp(
      0.4,
      1.0,
    );
  }
}
