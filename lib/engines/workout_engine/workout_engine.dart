import 'package:gymgenius/data/repositories/user_repository_impl.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/repositories/user_repository.dart';
import 'package:gymgenius/engines/workout_engine/services/generation_service.dart';
import 'package:gymgenius/engines/workout_engine/services/persistence_service.dart';
import 'package:gymgenius/engines/workout_engine/services/regeneration_service.dart';
import 'package:gymgenius/core/logger/logger_service.dart';

/// Public facade for the Workout Engine.
///
/// This is the only entry point that the rest of the application should use.
/// It encapsulates all internal complexity: generation, optimization, validation,
/// and persistence of programs and weekly workouts.
class WorkoutEngine {
  final GenerationService _generationService;
  final RegenerationService _regenerationService;
  final PersistenceService _persistenceService;
  final UserRepository _userRepository;

  WorkoutEngine({
    GenerationService? generationService,
    RegenerationService? regenerationService,
    PersistenceService? persistenceService,
    UserRepository? userRepository,
  })  : _generationService = generationService ?? GenerationService(),
        _regenerationService = regenerationService ?? RegenerationService(),
        _persistenceService = persistenceService ?? PersistenceService(),
        _userRepository = userRepository ?? UserRepositoryImpl();

  /// Generates a new training program.
  ///
  /// 1. Local generator produces a valid program immediately.
  /// 2. Optimizers (local + optional Gemini) improve the program.
  /// 3. Final program is validated and persisted.
  Future<TrainingProgram> generateProgram({
    required HealthProfile profile,
    TrainingProgram? previousProgram,
    Map<String, dynamic>? options,
  }) async {
    final program = await _generationService.generate(
      profile: profile,
      previousProgram: previousProgram,
      options: options,
    );

    // Persist the program and its first weekly workout
    await _persistenceService.saveProgram(program);

    Log.debug('WorkoutEngine: Program workout saved');
    return program;
  }

  /// Regenerates a program with specific options.
  ///
  /// Useful for user-triggered regenerations (e.g., change equipment, focus areas).
  Future<TrainingProgram> regenerateProgram({
    required HealthProfile profile,
    required TrainingProgram previousProgram,
    required Map<String, dynamic> options,
  }) async {
    final program = await _regenerationService.regenerate(
      profile: profile,
      previousProgram: previousProgram,
      options: options,
    );

    // Save the new program and update weekly workout
    await _persistenceService.saveProgram(program);

    Log.debug('WorkoutEngine: Program regenerated and saved');
    return program;
  }

  // ============================================================
  // Convenience methods for ViewModels
  // ============================================================

  /// Gets the current program and its active weekly workout.
  ///
  /// Returns a tuple: (program, weeklyWorkout).
  Future<TrainingProgram?> getCurrentProgram() async {
    final user = await _userRepository.getCurrentUser();
    if (user == null) return null;

    final program = await _persistenceService.loadProgram(user.id);
    if (program == null) return null;

    return program;
  }

  /// Clears the current program and all associated weekly workouts.
  Future<void> clearCurrentProgram() async {
    final user = await _userRepository.getCurrentUser();
    if (user == null) return;

    final program = await _persistenceService.loadProgram(user.id);
    if (program != null) {
      await _persistenceService.deleteProgram(program.id);
      Log.debug('WorkoutEngine: Current program and weekly workouts cleared');
    }
  }
}
