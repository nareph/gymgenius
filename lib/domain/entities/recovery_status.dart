// lib/domain/entities/recovery_status.dart

import 'package:gymgenius/domain/enums/recommended_intensity.dart';

/// Domain Entity representing the computed recovery status for a given day.
///
/// Produced by [RecoveryEngine] from a [DailyCheckIn].
/// Persisted via [RecoveryRepository] and consumed by [RecoveryRule].
class RecoveryStatus {
  final String userId;
  final DateTime date;

  /// Global recovery score (0–100). Weighted average of sleep + fatigue.
  final int recoveryScore;

  /// Fatigue score (0–100). Higher = more fatigued.
  final int fatigueScore;

  /// Readiness score (0–100). Overall workout readiness.
  final int readinessScore;

  /// Intensity tier recommended by the Recovery Engine.
  final RecommendedIntensity recommendedIntensity;

  /// Volume multiplier derived from readiness (0.5–1.0).
  final double volumeMultiplier;

  /// Human-readable reasons for the recommendation.
  final List<String> reasons;

  /// Engine version tag for audit trail.
  final String generatedBy;

  const RecoveryStatus({
    required this.userId,
    required this.date,
    required this.recoveryScore,
    required this.fatigueScore,
    required this.readinessScore,
    required this.recommendedIntensity,
    required this.volumeMultiplier,
    required this.reasons,
    this.generatedBy = 'recovery_engine_v1',
  });

  bool get isWellRecovered => recoveryScore >= 80;
  bool get isModeratelyRecovered => recoveryScore >= 60 && recoveryScore < 80;
  bool get isPoorlyRecovered => recoveryScore < 60;

  bool get isReadyToTrain => readinessScore >= 70;

  /// True when the engine recommends reducing training load.
  bool get requiresVolumeReduction => volumeMultiplier < 1.0;

  @override
  String toString() =>
      'RecoveryStatus(recovery: $recoveryScore, readiness: $readinessScore, intensity: ${recommendedIntensity.name}, volume: $volumeMultiplier)';
}
