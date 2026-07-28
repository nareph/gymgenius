// lib/domain/entities/progress_metrics.dart

import 'package:gymgenius/domain/enums/muscle_group.dart';

/// Domain Entity representing the user's progress metrics.
class ProgressMetrics {
  final String userId;
  final DateTime date;
  final double? weightTrend; // kg/week
  final double? strengthTrend; // % change
  final int consistencyScore; // 0-100
  final double? estimatedBodyFat;
  final double? estimatedLeanMass;
  final bool plateauDetected;
  final MuscleGroup? plateauMuscleGroup;

  const ProgressMetrics({
    required this.userId,
    required this.date,
    this.weightTrend,
    this.strengthTrend,
    required this.consistencyScore,
    this.estimatedBodyFat,
    this.estimatedLeanMass,
    required this.plateauDetected,
    this.plateauMuscleGroup,
  });

  bool get isProgressing => consistencyScore > 70 && !plateauDetected;
  bool get isPlateau => plateauDetected;
  bool get isConsistent => consistencyScore >= 80;

  @override
  String toString() => 'ProgressMetrics($date, consistency: $consistencyScore)';
}
