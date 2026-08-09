import 'package:gymgenius/domain/entities/training_program.dart';
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

  Future<TrainingProgram?> loadProgram(String userId) async {
    Log.debug('PersistenceService: Loading program for user $userId');
    return _repository.getCurrentProgram(userId);
  }

  Future<void> deleteProgram(String programId) async {
    Log.debug('PersistenceService: Deleting program $programId');
    await _repository.deleteProgram(programId);
  }
}
