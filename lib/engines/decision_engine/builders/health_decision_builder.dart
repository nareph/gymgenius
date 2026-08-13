import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/decision_engine/models/health_decision.dart';
import 'package:gymgenius/engines/recovery_engine/recovery_thresholds.dart';
import 'package:gymgenius/engines/decision_engine/policies/program_refresh_policy.dart';

/// Builds a deterministic [HealthDecision] from today's decision outputs.
///
/// No natural language AI — structured actions only for Phase 6.
class HealthDecisionBuilder {
  const HealthDecisionBuilder();

  HealthDecision build({
    required DateTime generatedAt,
    required WorkoutDecision finalDecision,
    RecoveryStatus? recoveryStatus,
    ProgressSnapshot? progressSnapshot,
    ProgramRefreshDecision? programRefresh,
  }) {
    if (finalDecision.adjustment == WorkoutAdjustment.restDay ||
        finalDecision.adjustment == WorkoutAdjustment.skipWorkout) {
      return HealthDecision(
        primaryAction: 'rest_and_recover',
        reason:
            'Today\'s plan prioritizes rest based on safety or recovery signals.',
        confidence: finalDecision.confidence.clamp(0.0, 1.0),
        generatedAt: generatedAt,
        reasons: finalDecision.reasons,
      );
    }

    if (finalDecision.adjustment == WorkoutAdjustment.recoverySession) {
      return HealthDecision(
        primaryAction: 'recovery_session',
        reason: 'A lighter recovery-focused session is recommended today.',
        confidence: finalDecision.confidence.clamp(0.0, 1.0),
        generatedAt: generatedAt,
        reasons: finalDecision.reasons,
      );
    }

    if (programRefresh?.shouldRegenerate ?? false) {
      return HealthDecision(
        primaryAction: 'refresh_program',
        reason: programRefresh!.message,
        confidence: 0.85,
        generatedAt: generatedAt,
        reasons: [
          ...finalDecision.reasons,
          if (programRefresh.reason == ProgramRefreshReason.plateau)
            DecisionReason.plateauDetected,
        ],
      );
    }

    final readiness = recoveryStatus?.readinessScore;
    if (readiness != null && readiness < RecoveryThresholds.mildReductionMin) {
      return HealthDecision(
        primaryAction: 'train_with_reduced_volume',
        reason:
            'Readiness is low ($readiness). Follow the adapted workout and prioritize sleep.',
        confidence: (readiness / 100.0).clamp(0.4, 1.0),
        generatedAt: generatedAt,
        reasons: [
          ...finalDecision.reasons,
          DecisionReason.lowRecovery,
        ],
      );
    }

    if (progressSnapshot?.anyPlateauDetected ?? false) {
      return HealthDecision(
        primaryAction: 'monitor_plateau',
        reason:
            'A plateau was detected. Keep training consistently; a program refresh is considered after two weeks of data.',
        confidence: 0.7,
        generatedAt: generatedAt,
        reasons: [
          ...finalDecision.reasons,
          DecisionReason.plateauDetected,
        ],
      );
    }

    if (finalDecision.requiresAdaptation) {
      return HealthDecision(
        primaryAction: 'follow_adapted_workout',
        reason:
            'Today\'s workout was adapted (${finalDecision.adjustment.value}). Follow the recommended session.',
        confidence: finalDecision.confidence.clamp(0.0, 1.0),
        generatedAt: generatedAt,
        reasons: finalDecision.reasons,
      );
    }

    if (readiness != null && readiness >= RecoveryThresholds.fullVolumeMin) {
      return HealthDecision(
        primaryAction: 'complete_scheduled_workout',
        reason: 'Readiness is good ($readiness). Complete the planned workout.',
        confidence: (readiness / 100.0).clamp(0.5, 1.0),
        generatedAt: generatedAt,
        reasons: const [DecisionReason.goodRecovery],
      );
    }

    return HealthDecision(
      primaryAction: 'complete_scheduled_workout',
      reason: recoveryStatus == null
          ? 'No check-in yet — follow the planned workout unless you feel unwell.'
          : 'Proceed with today\'s planned workout.',
      confidence: recoveryStatus == null
          ? 0.5
          : finalDecision.confidence.clamp(0.0, 1.0),
      generatedAt: generatedAt,
      reasons: finalDecision.reasons.isEmpty
          ? const [DecisionReason.scheduledWorkout]
          : finalDecision.reasons,
    );
  }
}
