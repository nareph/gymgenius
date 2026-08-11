import 'package:gymgenius/domain/enums/trend_direction.dart';

/// Training adherence over a lookback window.
class WorkoutConsistency {
  final int plannedWorkouts;
  final int completedWorkouts;
  final int consistencyScore;
  final double weeklyFrequency;
  final int consecutiveTrainingDays;
  final TrendDirection trend;

  const WorkoutConsistency({
    required this.plannedWorkouts,
    required this.completedWorkouts,
    required this.consistencyScore,
    required this.weeklyFrequency,
    required this.consecutiveTrainingDays,
    required this.trend,
  });

  double get completionRate =>
      plannedWorkouts > 0 ? completedWorkouts / plannedWorkouts : 0.0;

  bool get hasSufficientData => plannedWorkouts > 0;

  @override
  String toString() =>
      'WorkoutConsistency($completedWorkouts/$plannedWorkouts, score: $consistencyScore)';
}
