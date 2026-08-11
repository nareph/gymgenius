import 'package:gymgenius/domain/enums/recommended_intensity.dart';

/// Single source of truth for Phase 4 recovery decision thresholds.
///
/// Used by both [ReadinessCalculator] (engine output) and [RecoveryRule]
/// (decision wiring) so multiplicateurs never diverge.
///
/// Phase 4 policy:
/// • Never forces a rest day — only volume reduction.
/// • [RecommendedIntensity.rest] remains informational for the UI.
/// • Volume grid: full / –15 % / –30 % / –45 %.
class RecoveryThresholds {
  const RecoveryThresholds._();

  /// Full training load cleared.
  static const int fullVolumeMin = 80;

  /// Mild reduction (–15 %).
  static const int mildReductionMin = 60;

  /// Moderate reduction (–30 %).
  static const int moderateReductionMin = 40;

  /// Below [moderateReductionMin] → significant reduction (–45 %).

  static const double fullVolume = 1.00;
  static const double mildReduction = 0.85;
  static const double moderateReduction = 0.70;
  static const double significantReduction = 0.55;

  /// Minimum sets kept after volume reduction (never drop to 0).
  static const int minSetsPerExercise = 1;

  static double volumeMultiplier(int readinessScore) {
    if (readinessScore >= fullVolumeMin) return fullVolume;
    if (readinessScore >= mildReductionMin) return mildReduction;
    if (readinessScore >= moderateReductionMin) return moderateReduction;
    return significantReduction;
  }

  /// Intensity is informational; Phase 4 never maps this to forced rest.
  static RecommendedIntensity intensity(int readinessScore) {
    if (readinessScore >= fullVolumeMin) return RecommendedIntensity.max;
    if (readinessScore >= 65) return RecommendedIntensity.high;
    if (readinessScore >= 50) return RecommendedIntensity.moderate;
    if (readinessScore >= 35) return RecommendedIntensity.light;
    return RecommendedIntensity.rest;
  }

  static bool requiresVolumeReduction(int readinessScore) {
    return readinessScore < mildReductionMin;
  }
}
