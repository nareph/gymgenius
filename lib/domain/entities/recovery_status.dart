// lib/domain/entities/recovery_status.dart

/// Domain Entity representing the current recovery status.
class RecoveryStatus {
  final String userId;
  final DateTime date;
  final int recoveryScore; // 0-100
  final int fatigueScore; // 0-100
  final int readinessScore; // 0-100
  final String
      recommendedIntensity; // 'rest', 'light', 'moderate', 'high', 'max'
  final String generatedBy; // 'recovery_engine_v1' | 'gemini' | etc.

  const RecoveryStatus({
    required this.userId,
    required this.date,
    required this.recoveryScore,
    required this.fatigueScore,
    required this.readinessScore,
    required this.recommendedIntensity,
    required this.generatedBy,
  });

  bool get isWellRecovered => recoveryScore >= 80;
  bool get isModeratelyRecovered => recoveryScore >= 60 && recoveryScore < 80;
  bool get isPoorlyRecovered => recoveryScore < 60;

  bool get isReadyToTrain => readinessScore >= 70;

  @override
  String toString() =>
      'RecoveryStatus(score: $recoveryScore, readiness: $readinessScore)';
}
