import 'package:gymgenius/domain/enums/recommended_intensity.dart';
import 'package:gymgenius/engines/recovery_engine/recovery_thresholds.dart';

/// Computes readiness score and recommended intensity from sleep + fatigue scores.
///
/// Formula:
///   readiness = (sleepWeight * sleepScore) + (fatigueWeight * (100 - fatigueScore)) + (moodBonus * mood)
///
/// Weights:
///   sleep score    → 50 %
///   fatigue (inv.) → 40 %
///   mood bonus     → 10 %  (mood 1–5 mapped to 0–100)
///
/// Volume / intensity tiers are owned by [RecoveryThresholds].
class ReadinessCalculator {
  const ReadinessCalculator();

  static const double _sleepWeight = 0.50;
  static const double _fatigueWeight = 0.40;
  static const double _moodWeight = 0.10;

  /// Returns readiness score in [0, 100].
  int readiness({
    required int sleepScore,
    required int fatigueScore,
    required int mood,
  }) {
    final moodNormalized = ((mood.clamp(1, 5) - 1) / 4.0 * 100);
    final raw = (_sleepWeight * sleepScore) +
        (_fatigueWeight * (100 - fatigueScore)) +
        (_moodWeight * moodNormalized);
    return raw.round().clamp(0, 100);
  }

  /// Returns recovery score: simplified weighted average of sleep and fatigue.
  int recoveryScore({required int sleepScore, required int fatigueScore}) {
    final raw = (0.6 * sleepScore) + (0.4 * (100 - fatigueScore));
    return raw.round().clamp(0, 100);
  }

  /// Maps a readiness score to a recommended training intensity tier.
  RecommendedIntensity intensity(int readinessScore) {
    return RecoveryThresholds.intensity(readinessScore);
  }

  /// Maps a readiness score to a volume multiplier.
  double volumeMultiplier(int readinessScore) {
    return RecoveryThresholds.volumeMultiplier(readinessScore);
  }
}
