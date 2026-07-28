import 'logged_exercise.dart';

/// Domain Entity representing a completed workout session.
class WorkoutLog {
  final String id;
  final String userId;
  final String programId;
  final int week;
  final String day;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final int? caloriesEstimate;
  final double? volume; // total kg lifted
  final double? averageRPE;
  final int completionScore; // 0-100
  final List<LoggedExercise> exercises;
  final DateTime savedAt;

  const WorkoutLog({
    required this.id,
    required this.userId,
    required this.programId,
    required this.week,
    required this.day,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    this.caloriesEstimate,
    this.volume,
    this.averageRPE,
    required this.completionScore,
    required this.exercises,
    required this.savedAt,
  });

  int get totalExercises => exercises.length;
  int get completedExercises => exercises.where((e) => e.completed).length;
  double get exerciseCompletionRate =>
      totalExercises > 0 ? completedExercises / totalExercises : 0;

  @override
  String toString() =>
      'WorkoutLog(${exercises.length} exercises, ${durationSeconds}s)';
}
