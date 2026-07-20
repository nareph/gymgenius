import 'package:flutter/material.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/repositories/workout_repository.dart';
import 'package:gymgenius/screens/exercise_logging_screen.dart';
import 'package:gymgenius/services/logger_service.dart';

class ActiveWorkoutViewModel {
  final WorkoutSessionManager _sessionManager;
  final WorkoutRepository _workoutRepository;
  final BuildContext _context;

  ActiveWorkoutViewModel({
    required WorkoutSessionManager sessionManager,
    required WorkoutRepository workoutRepository,
    required BuildContext context,
  })  : _sessionManager = sessionManager,
        _workoutRepository = workoutRepository,
        _context = context;

  Future<void> endWorkout() async {
    final scaffoldMessenger = ScaffoldMessenger.of(_context);
    final theme = Theme.of(_context);

    final workoutLog = _sessionManager.endWorkout();

    if (workoutLog == null) {
      Log.debug("ActiveWorkoutViewModel: No log to save, session ended.");
      return;
    }

    try {
      await _workoutRepository.saveWorkoutLog(workoutLog);
      if (!_context.mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Workout saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, s) {
      Log.error("ActiveWorkoutViewModel: Failed to save workout log",
          error: e, stackTrace: s);
      if (!_context.mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text("Error: Could not save workout."),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  void navigateToLogExercise(int exerciseIndex) {
    if (!_sessionManager.selectExercise(exerciseIndex)) return;
    final exerciseToLog = _sessionManager.currentExercise;
    if (exerciseToLog == null) return;
    Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (_) => ExerciseLoggingScreen(
            exercise: exerciseToLog, onExerciseCompleted: () {}),
      ),
    );
  }
}
