import 'package:gymgenius/domain/enums/trend_direction.dart';

/// A single measurable progress indicator (weight, strength, consistency…).
class ProgressMetric {
  final String id;
  final String label;
  final double? value;
  final String unit;
  final TrendDirection trend;
  final bool hasSufficientData;

  const ProgressMetric({
    required this.id,
    required this.label,
    required this.value,
    required this.unit,
    required this.trend,
    required this.hasSufficientData,
  });
}
