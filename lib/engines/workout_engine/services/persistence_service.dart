import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/entities/weekly_workout.dart';
import 'package:gymgenius/data/repositories/workout_repository_impl.dart';
import 'package:gymgenius/core/logger/logger_service.dart';

/// Handles persistence of workout-related data.
class PersistenceService {
  final WorkoutRepositoryImpl _repository;

  PersistenceService({WorkoutRepositoryImpl? repository})
      : _repository = repository ?? const WorkoutRepositoryImpl();

  Future<void> saveProgram(TrainingProgram program) async {
    Log.debug('PersistenceService: Saving program ${program.id}');
    await _repository.saveProgram(program);
  }

  Future<void> saveWeeklyWorkout(WeeklyWorkout weekly) async {
    Log.debug('PersistenceService: Saving weekly workout ${weekly.id}');
    await _repository.saveWeeklyWorkout(weekly);
  }

  Future<TrainingProgram?> loadProgram(String userId) async {
    Log.debug('PersistenceService: Loading program for user $userId');
    return _repository.getCurrentProgram(userId);
  }

  Future<void> deleteProgram(String programId) async {
    Log.debug('PersistenceService: Deleting program $programId');
    await _repository.deleteProgram(programId);
  }

  /// Returns the currently active weekly workout for [programId], if any.
  Future<WeeklyWorkout?> getCurrentWeeklyWorkout(String programId) async {
    Log.debug(
        'PersistenceService: Loading current weekly workout for program $programId');
    return _repository.getCurrentWeeklyWorkout(programId);
  }

  /// Returns every weekly workout ever generated for [programId] (used
  /// when clearing a program, to delete all of its weekly workouts too).
  Future<List<WeeklyWorkout>> getProgramWeeklyWorkouts(String programId) async {
    Log.debug(
        'PersistenceService: Loading all weekly workouts for program $programId');
    return _repository.getProgramWeeklyWorkouts(programId);
  }

  Future<void> deleteWeeklyWorkout(String weeklyId) async {
    Log.debug('PersistenceService: Deleting weekly workout $weeklyId');
    await _repository.deleteWeeklyWorkout(weeklyId);
  }
}
