import 'package:gymgenius/domain/enums/soreness_level.dart';

/// Converts raw sleep hours into a 0–100 sleep score.
///
/// Reference thresholds (evidence-based):
/// • < 5 h  → severely sleep-deprived  → score 0–25
/// • 5–6 h  → sleep-restricted         → score 26–50
/// • 6–7 h  → sub-optimal              → score 51–70
/// • 7–9 h  → optimal window           → score 71–100
/// • > 9 h  → oversleep (minor penalty) → score 80–90
class SleepScorer {
  const SleepScorer();

  /// Returns a sleep score in [0, 100].
  int score(double sleepHours) {
    if (sleepHours <= 0) return 0;
    if (sleepHours < 5.0) {
      return (sleepHours / 5.0 * 25).round().clamp(0, 25);
    }
    if (sleepHours < 6.0) {
      return (25 + (sleepHours - 5.0) * 25).round().clamp(26, 50);
    }
    if (sleepHours < 7.0) {
      return (50 + (sleepHours - 6.0) * 20).round().clamp(51, 70);
    }
    if (sleepHours <= 9.0) {
      return (70 + (sleepHours - 7.0) / 2.0 * 30).round().clamp(71, 100);
    }
    // > 9 h: minor penalty for oversleeping
    return (100 - (sleepHours - 9.0) * 5).round().clamp(80, 100);
  }
}

/// Converts a [SorenessLevel] into a 0–100 soreness penalty score.
/// Higher value = more soreness = higher fatigue contribution.
class SorenessScorer {
  const SorenessScorer();

  int score(SorenessLevel level) {
    switch (level) {
      case SorenessLevel.none:
        return 0;
      case SorenessLevel.mild:
        return 25;
      case SorenessLevel.moderate:
        return 55;
      case SorenessLevel.severe:
        return 90;
    }
  }
}
