import 'package:gymgenius/domain/enums/trend_direction.dart';

/// Strength progression for a single tracked exercise.
class ExerciseStrengthMetric {
  final String exerciseId;
  final String exerciseName;
  final double bestWeightKg;
  final int bestReps;
  final double estimated1Rm;
  final TrendDirection trend;
  final bool plateauDetected;

  const ExerciseStrengthMetric({
    required this.exerciseId,
    required this.exerciseName,
    required this.bestWeightKg,
    required this.bestReps,
    required this.estimated1Rm,
    required this.trend,
    required this.plateauDetected,
  });
}
