import 'package:gymgenius/domain/enums/trend_direction.dart';

/// Body-weight progress over a lookback window.
class WeightTrend {
  final double? currentWeightKg;
  final double? weeklyAverageKg;
  final double? changeKg;
  final TrendDirection direction;
  final double? distanceToTargetKg;
  final int dataPointCount;

  const WeightTrend({
    required this.currentWeightKg,
    required this.weeklyAverageKg,
    required this.changeKg,
    required this.direction,
    required this.distanceToTargetKg,
    required this.dataPointCount,
  });

  bool get hasSufficientData => dataPointCount >= 3 && currentWeightKg != null;

  @override
  String toString() =>
      'WeightTrend(current: $currentWeightKg, change: $changeKg, $direction)';
}
