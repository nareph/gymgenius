// lib/data/repositories/workout_repository_impl.dart

import 'dart:async';
import 'package:gymgenius/data/datasources/local/hive/boxes/hive_datasource.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/training_program.dart';
import '../../domain/entities/weekly_workout.dart';
import '../../domain/entities/workout_log.dart';
import '../../domain/repositories/workout_repository.dart';
import '../mappers/workout_mapper.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  const WorkoutRepositoryImpl();

  // ============================================================
  // Training Program
  // ============================================================

  @override
  Future<TrainingProgram?> getCurrentProgram(String userId) async {
    final model = HiveDatasource.getCurrentTrainingProgram(userId);
    if (model == null) return null;
    return WorkoutMapper.toTrainingProgram(model);
  }

  @override
  Future<void> saveProgram(TrainingProgram program) async {
    final model = WorkoutMapper.fromTrainingProgram(program);
    await HiveDatasource.saveTrainingProgram(model);
  }

  @override
  Future<void> deleteProgram(String programId) async {
    await HiveDatasource.deleteTrainingProgram(programId);
  }

// ============================================================
// Weekly Workout
// ============================================================

  @override
  Future<WeeklyWorkout?> getCurrentWeeklyWorkout(String programId) async {
    final model = HiveDatasource.getCurrentWeeklyWorkout(programId);
    if (model == null) return null;
    return WorkoutMapper.toWeeklyWorkout(model);
  }

  @override
  Future<void> saveWeeklyWorkout(WeeklyWorkout weekly) async {
    final model = WorkoutMapper.fromWeeklyWorkout(weekly);
    await HiveDatasource.saveWeeklyWorkout(model);
  }

  @override
  Future<void> deleteWeeklyWorkout(String weeklyId) async {
    await HiveDatasource.deleteWeeklyWorkout(weeklyId);
  }

  /// Get all weekly workouts for a program (convenience method, not in interface)
  Future<List<WeeklyWorkout>> getProgramWeeklyWorkouts(String programId) async {
    final models = HiveDatasource.getProgramWeeklyWorkouts(programId);
    return models.map(WorkoutMapper.toWeeklyWorkout).toList();
  }

  // ============================================================
  // Workout Log
  // ============================================================

  @override
  Future<void> saveWorkoutLog(WorkoutLog log) async {
    final model = WorkoutMapper.fromWorkoutLog(log);
    await HiveDatasource.saveWorkoutLog(model);
  }

  @override
  Future<List<WorkoutLog>> getWorkoutLogs(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final allLogs = HiveDatasource.getUserWorkoutLogs(userId);
    return allLogs
        .where((model) {
          if (from != null && model.savedAt.isBefore(from)) return false;
          if (to != null && model.savedAt.isAfter(to)) return false;
          return true;
        })
        .map(WorkoutMapper.toWorkoutLog)
        .toList();
  }

  @override
  Future<WorkoutLog?> getWorkoutLog(String logId) async {
    final model = HiveDatasource.getWorkoutLog(logId);
    if (model == null) return null;
    return WorkoutMapper.toWorkoutLog(model);
  }

  // ============================================================
  // Exercise (pool)
  // ============================================================

  @override
  Future<List<Exercise>> getAllExercises() async {
    // TODO: Implement exercise retrieval from the exercise pool.
    // For now, return an empty list. Future implementation will convert
    // ExercisePoolEntry to domain Exercise using ExerciseMapper.
    return [];
  }

  @override
  Future<List<Exercise>> getExercisesForEquipment(
    List<String> equipment,
  ) async {
    // TODO: Filter exercises based on equipment.
    // This will eventually query ExercisePool with allowed equipment types.
    return [];
  }

  // ============================================================
  // Convenience methods (not in interface)
  // ============================================================

  /// Gets current program and its active weekly workout together.
  (TrainingProgram?, WeeklyWorkout?) getCurrentProgramAndWeekly() {
    final userId = HiveDatasource.getCurrentUserId();
    if (userId == null) return (null, null);
    final program = getCurrentProgramSync(userId);
    if (program == null) return (null, null);
    final weekly = getCurrentWeeklyWorkoutSync(program.id);
    return (program, weekly);
  }

  /// Returns true if the user has an active (non-expired) program.
  bool hasActiveProgram() {
    final userId = HiveDatasource.getCurrentUserId();
    if (userId == null) return false;
    final program = getCurrentProgramSync(userId);
    return program != null && !program.isExpired;
  }

  // Synchronous versions for convenience (they use Hive directly)
  TrainingProgram? getCurrentProgramSync(String userId) {
    final model = HiveDatasource.getCurrentTrainingProgram(userId);
    return model != null ? WorkoutMapper.toTrainingProgram(model) : null;
  }

  WeeklyWorkout? getCurrentWeeklyWorkoutSync(String programId) {
    final model = HiveDatasource.getCurrentWeeklyWorkout(programId);
    return model != null ? WorkoutMapper.toWeeklyWorkout(model) : null;
  }
}
