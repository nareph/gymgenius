// lib/engines/recovery_engine/recovery_engine.dart

import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/repositories/recovery_repository.dart';
import 'package:gymgenius/engines/recovery_engine/recovery_thresholds.dart';
import 'package:gymgenius/engines/recovery_engine/scorers/fatigue_estimator.dart';
import 'package:gymgenius/engines/recovery_engine/scorers/readiness_calculator.dart';
import 'package:gymgenius/engines/recovery_engine/scorers/sleep_scorer.dart';

/// Public facade for the Recovery Engine.
///
/// A RecoveryStatus can only be produced from an actual DailyCheckIn.
///
/// There is intentionally no fallback/default recovery state.
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

  /// Computes recovery from a real DailyCheckIn.
  ///
  /// This method must never be called with synthetic/default UI values.
  RecoveryStatus compute(
    DailyCheckIn checkIn,
  ) {
    final sleepScore = _sleepScorer.score(
      checkIn.sleepHours,
    );

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

    final intensity = RecoveryThresholds.intensity(
      readiness,
    );

    final volumeMultiplier = RecoveryThresholds.volumeMultiplier(readiness);

    return RecoveryStatus(
      userId: checkIn.userId,
      date: checkIn.date,
      recoveryScore: recovery,
      fatigueScore: fatigueScore,
      readinessScore: readiness,
      recommendedIntensity: intensity,
      volumeMultiplier: volumeMultiplier,
      reasons: _buildReasons(
        sleepScore: sleepScore,
        fatigueScore: fatigueScore,
        readiness: readiness,
        sleepHours: checkIn.sleepHours,
      ),
    );
  }

  Future<RecoveryStatus> computeAndPersist(
    DailyCheckIn checkIn,
  ) async {
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
        'Insufficient sleep '
        '(${sleepHours.toStringAsFixed(1)} h < 6 h recommended)',
      );
    } else if (sleepHours >= 7) {
      reasons.add(
        'Good sleep (${sleepHours.toStringAsFixed(1)} h)',
      );
    } else {
      reasons.add(
        'Sleep could be improved '
        '(${sleepHours.toStringAsFixed(1)} h)',
      );
    }

    if (fatigueScore >= 70) {
      reasons.add(
        'High fatigue detected',
      );
    } else if (fatigueScore <= 25) {
      reasons.add(
        'Low fatigue — full training load available',
      );
    } else {
      reasons.add(
        'Moderate fatigue detected',
      );
    }

    if (readiness >= RecoveryThresholds.fullVolumeMin) {
      reasons.add(
        'Excellent readiness — full training volume available',
      );
    } else if (readiness >= RecoveryThresholds.mildReductionMin) {
      reasons.add(
        'Good readiness — volume reduced by 15 %',
      );
    } else if (readiness >= RecoveryThresholds.moderateReductionMin) {
      reasons.add(
        'Moderate readiness — volume reduced by 30 %',
      );
    } else {
      reasons.add(
        'Low readiness — volume reduced by 45 %',
      );
    }

    return reasons;
  }
}
