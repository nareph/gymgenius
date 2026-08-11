import 'package:gymgenius/domain/enums/trend_direction.dart';

import 'exercise_strength_metric.dart';

/// Aggregated strength progression across tracked exercises.
class StrengthProgress {
  final int trackedExerciseCount;
  final List<ExerciseStrengthMetric> topExercises;
  final TrendDirection overallTrend;
  final double strengthChangePercent;
  final bool plateauDetected;

  const StrengthProgress({
    required this.trackedExerciseCount,
    required this.topExercises,
    required this.overallTrend,
    required this.strengthChangePercent,
    required this.plateauDetected,
  });

  bool get hasSufficientData => trackedExerciseCount > 0;

  @override
  String toString() =>
      'StrengthProgress(exercises: $trackedExerciseCount, trend: $overallTrend)';
}
