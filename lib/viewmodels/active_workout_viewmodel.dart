import 'package:flutter/material.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/repositories/workout_repository.dart';
import 'package:gymgenius/screens/exercise_logging_screen.dart';
import 'package:gymgenius/services/logger_service.dart';

class ActiveWorkoutViewModel {
  final WorkoutSessionManager _sessionManager;
  final WorkoutRepository _workoutRepository;
  final BuildContext _context; // For navigation

  ActiveWorkoutViewModel({
    required WorkoutSessionManager sessionManager,
    required WorkoutRepository workoutRepository,
    required BuildContext context,
  })  : _sessionManager = sessionManager,
        _workoutRepository = workoutRepository,
        _context = context;

  /// Ends the current workout, saves the log, and shows appropriate feedback.
  Future<void> endWorkout() async {
    final scaffoldMessenger = ScaffoldMessenger.of(_context);
    final theme = Theme.of(_context);

    // Get the workout payload before ending the session.
    final workoutLog = _sessionManager.endWorkout();

    if (workoutLog == null) {
      Log.debug("ActiveWorkoutViewModel: No log to save, session ended.");
      // The Consumer in the UI will handle navigation since isWorkoutActive is now false.
      return;
    }

    // Pass the payload to the repository to handle saving.
    final result = await _workoutRepository.saveWorkoutLog(workoutLog);

    // Show feedback based on the result.
    if (!_context.mounted) return;
    switch (result) {
      case SaveResult.successOnline:
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text("Workout saved successfully!"),
            backgroundColor: Colors.green));
        break;
      case SaveResult.successOffline:
        scaffoldMessenger.showSnackBar(const SnackBar(
            content:
                Text("Offline. Workout saved locally and will sync later."),
            backgroundColor: Colors.orange));
        break;
      case SaveResult.failure:
        scaffoldMessenger.showSnackBar(SnackBar(
            content: const Text("Error: Could not save workout."),
            backgroundColor: theme.colorScheme.error));
        break;
    }
  }

  /// Navigates to the screen for logging a specific exercise.
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
