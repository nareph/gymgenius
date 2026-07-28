// lib/domain/value_objects/recovery_data.dart

/// Immutable value object representing recovery metrics for a given day.
class RecoveryData {
  final int sleepHours;
  final int recoveryScore; // 0-100
  final int fatigueScore; // 0-100
  final int readinessScore; // 0-100
  final int soreness; // 0-10

  const RecoveryData({
    required this.sleepHours,
    required this.recoveryScore,
    required this.fatigueScore,
    required this.readinessScore,
    required this.soreness,
  });

  bool get isWellRecovered => recoveryScore >= 80;
  bool get isModeratelyRecovered => recoveryScore >= 60 && recoveryScore < 80;
  bool get isPoorlyRecovered => recoveryScore < 60;

  bool get isFatigued => fatigueScore > 70;
  bool get isReadyToTrain => readinessScore >= 70;

  @override
  String toString() =>
      'RecoveryData(score: $recoveryScore, readiness: $readinessScore)';
}
