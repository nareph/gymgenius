import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/soreness_level.dart';

/// Estimates a fatigue score (0–100) from soreness and energy inputs.
///
/// Higher score = more fatigued.
///
/// Formula:
///   fatigue = (sorenessWeight * sorenessScore) + (energyWeight * energyPenalty)
///
/// Weights:
///   soreness → 60 %
///   energy   → 40 %
class FatigueEstimator {
  const FatigueEstimator();

  static const double _sorenessWeight = 0.60;
  static const double _energyWeight = 0.40;

  /// Returns a fatigue score in [0, 100].
  int estimate({
    required SorenessLevel sorenessLevel,
    required EnergyLevel energyLevel,
  }) {
    final soreness = _sorenessScore(sorenessLevel);
    final energyPenalty = _energyPenalty(energyLevel);
    final raw = (_sorenessWeight * soreness) + (_energyWeight * energyPenalty);
    return raw.round().clamp(0, 100);
  }

  int _sorenessScore(SorenessLevel level) {
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

  /// Converts energy level into a fatigue penalty (high energy = low penalty).
  int _energyPenalty(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.veryHigh:
        return 0;
      case EnergyLevel.high:
        return 15;
      case EnergyLevel.moderate:
        return 40;
      case EnergyLevel.low:
        return 70;
      case EnergyLevel.veryLow:
        return 100;
    }
  }
}
