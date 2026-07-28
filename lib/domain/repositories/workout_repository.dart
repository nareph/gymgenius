// lib/domain/repositories/workout_repository.dart

import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/entities/weekly_workout.dart';
import 'package:gymgenius/domain/entities/workout_log.dart';

/// Contract for workout-related persistence operations.
abstract interface class WorkoutRepository {
  // Training Program
  Future<TrainingProgram?> getCurrentProgram(String userId);
  Future<void> saveProgram(TrainingProgram program);
  Future<void> deleteProgram(String programId);

  // Weekly Workout
  Future<WeeklyWorkout?> getCurrentWeeklyWorkout(String programId);
  Future<void> saveWeeklyWorkout(WeeklyWorkout weekly);
  Future<void> deleteWeeklyWorkout(String weeklyId);

  // Workout Log
  Future<void> saveWorkoutLog(WorkoutLog log);
  Future<List<WorkoutLog>> getWorkoutLogs(String userId,
      {DateTime? from, DateTime? to});
  Future<WorkoutLog?> getWorkoutLog(String logId);

  // Exercise (for the pool)
  Future<List<Exercise>> getAllExercises();
  Future<List<Exercise>> getExercisesForEquipment(List<String> equipment);
}
