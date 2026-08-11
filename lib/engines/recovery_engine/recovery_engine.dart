import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/repositories/recovery_repository.dart';
import 'package:gymgenius/engines/recovery_engine/scorers/fatigue_estimator.dart';
import 'package:gymgenius/engines/recovery_engine/scorers/readiness_calculator.dart';
import 'package:gymgenius/engines/recovery_engine/scorers/sleep_scorer.dart';

/// Public façade for the Recovery Engine.
///
/// Responsibilities:
/// • Compute a [RecoveryStatus] from a [DailyCheckIn] (deterministic, no IO).
/// • Persist the status via [RecoveryRepository] when requested.
///
/// All scoring logic is delegated to focused scorer classes so each
/// algorithm can be tested and evolved independently.
class RecoveryEngine {
  final SleepScorer _sleepScorer;
  final FatigueEstimator _fatigueEstimator;
  final ReadinessCalculator _readinessCalculator;
  final RecoveryRepository? _repository;

  const RecoveryEngine({
    SleepScorer sleepScorer = const SleepScorer(),
    FatigueEstimator fatigueEstimator = const FatigueEstimator(),
    ReadinessCalculator readinessCalculator = const ReadinessCalculator(),
    RecoveryRepository? repository,
  })  : _sleepScorer = sleepScorer,
        _fatigueEstimator = fatigueEstimator,
        _readinessCalculator = readinessCalculator,
        _repository = repository;

  /// Computes a [RecoveryStatus] synchronously from a [DailyCheckIn].
  ///
  /// Pure function — no persistence, no side effects.
  RecoveryStatus compute(DailyCheckIn checkIn) {
    final sleepScore = _sleepScorer.score(checkIn.sleepHours);

    final fatigueScore = _fatigueEstimator.estimate(
      sorenessLevel: checkIn.sorenessLevel,
      energyLevel: checkIn.energyLevel,
    );

    final readiness = _readinessCalculator.readiness(
      sleepScore: sleepScore,
      fatigueScore: fatigueScore,
      mood: checkIn.mood,
    );

    final recovery = _readinessCalculator.recoveryScore(
      sleepScore: sleepScore,
      fatigueScore: fatigueScore,
    );

    final intensity = _readinessCalculator.intensity(readiness);
    final volumeMult = _readinessCalculator.volumeMultiplier(readiness);

    final reasons = _buildReasons(
      sleepScore: sleepScore,
      fatigueScore: fatigueScore,
      readiness: readiness,
      sleepHours: checkIn.sleepHours,
    );

    return RecoveryStatus(
      userId: checkIn.userId,
      date: checkIn.date,
      recoveryScore: recovery,
      fatigueScore: fatigueScore,
      readinessScore: readiness,
      recommendedIntensity: intensity,
      volumeMultiplier: volumeMult,
      reasons: reasons,
    );
  }

  /// Computes and persists the [RecoveryStatus] for today's check-in.
  Future<RecoveryStatus> computeAndPersist(DailyCheckIn checkIn) async {
    final status = compute(checkIn);
    await _repository?.saveRecoveryStatus(status);
    await _repository?.saveDailyCheckIn(checkIn);
    return status;
  }

  List<String> _buildReasons({
    required int sleepScore,
    required int fatigueScore,
    required int readiness,
    required double sleepHours,
  }) {
    final reasons = <String>[];

    if (sleepHours < 6) {
      reasons.add(
          'Insufficient sleep (${sleepHours.toStringAsFixed(1)} h < 6 h recommended)');
    } else if (sleepHours >= 7) {
      reasons.add('Good sleep (${sleepHours.toStringAsFixed(1)} h)');
    }

    if (fatigueScore >= 70) {
      reasons.add('High fatigue detected — volume reduced');
    } else if (fatigueScore <= 25) {
      reasons.add('Low fatigue — full training load available');
    }

    if (readiness >= 80) {
      reasons.add('Excellent readiness — maximum intensity cleared');
    } else if (readiness >= 60) {
      reasons.add('Good readiness — volume reduced by 15 %');
    } else if (readiness >= 40) {
      reasons.add('Moderate readiness — volume reduced by 30 %');
    } else {
      reasons.add('Low readiness — volume reduced by 45 %');
    }

    return reasons;
  }
}
