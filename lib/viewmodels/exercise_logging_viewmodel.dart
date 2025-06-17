import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/services/logger_service.dart';

/// ViewModel for the Exercise Logging Screen.
///
/// This class encapsulates all the business logic, state management,
/// controllers, and timers related to logging a single exercise.
class ExerciseLoggingViewModel extends ChangeNotifier {
  final WorkoutSessionManager _sessionManager;
  final RoutineExercise exercise;

  // Controllers for text fields are managed here.
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController minutesController = TextEditingController();
  final TextEditingController secondsController = TextEditingController();

  // State for the timed exercise timer.
  Timer? _exerciseTimer;
  int _targetDurationSeconds = 0;
  int _currentExerciseRunDownSeconds = 0;
  int get currentExerciseRunDownSeconds => _currentExerciseRunDownSeconds;

  bool _isExerciseTimerRunning = false;
  bool get isExerciseTimerRunning => _isExerciseTimerRunning;

  ExerciseLoggingViewModel({
    required WorkoutSessionManager sessionManager,
    required this.exercise,
  }) : _sessionManager = sessionManager {
    _initializeFieldsForCurrentSet();
  }

  /// Sets up the input fields with appropriate values for the current set.
  void _initializeFieldsForCurrentSet() {
    final loggedData = _sessionManager.currentLoggedExerciseData;
    if (loggedData == null || loggedData.isCompleted) {
      // If exercise is done, or data is unavailable, clear fields.
      repsController.clear();
      weightController.clear();
      return;
    }

    if (exercise.isTimed) {
      _targetDurationSeconds = exercise.targetDurationSeconds ?? 60;
      minutesController.text = (_targetDurationSeconds ~/ 60).toString();
      secondsController.text =
          (_targetDurationSeconds % 60).toString().padLeft(2, '0');
      _currentExerciseRunDownSeconds = _targetDurationSeconds;
      _sessionManager.resetExerciseTimeUpSoundFlag();
    } else {
      repsController.text = _getInitialRepsSuggestion();
      weightController.text = _getInitialWeightSuggestion();
    }
    notifyListeners();
  }

  String _getInitialRepsSuggestion() {
    final repsSuggestion = exercise.reps.trim();
    final repsRangeRegex = RegExp(r'^(\d+)\s*-\s*\d+');
    final singleRepRegex = RegExp(r'^(\d+)$');
    if (repsRangeRegex.hasMatch(repsSuggestion)) {
      return repsRangeRegex.firstMatch(repsSuggestion)!.group(1)!;
    } else if (singleRepRegex.hasMatch(repsSuggestion)) {
      return singleRepRegex.firstMatch(repsSuggestion)!.group(1)!;
    }
    return ""; // For AMRAP, 'to failure', etc.
  }

  String _getInitialWeightSuggestion() {
    if (!exercise.usesWeight) return "";
    final weightSuggestion = exercise.weightSuggestionKg.trim();
    if (['bodyweight', 'bw', 'n/a', '']
        .contains(weightSuggestion.toLowerCase())) {
      return "";
    }
    final weightRegex = RegExp(r'^(\d+(\.\d+)?)');
    final match = weightRegex.firstMatch(weightSuggestion);
    return match?.group(1) ?? "";
  }

  /// Starts or stops the timer for a timed exercise.
  void startOrStopExerciseTimer() {
    if (_isExerciseTimerRunning) {
      _stopTimerAndLog(isFinished: false);
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    final minutes = int.tryParse(minutesController.text.trim()) ?? 0;
    final seconds = int.tryParse(secondsController.text.trim()) ?? 0;
    final totalSeconds = (minutes * 60) + seconds;

    if (totalSeconds <= 0) {
      // Optionally show a snackbar or validation message from the UI.
      return;
    }
    _targetDurationSeconds = totalSeconds;
    _currentExerciseRunDownSeconds = _targetDurationSeconds;
    _isExerciseTimerRunning = true;
    _sessionManager.resetExerciseTimeUpSoundFlag();
    notifyListeners();

    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentExerciseRunDownSeconds > 0) {
        _currentExerciseRunDownSeconds--;
        notifyListeners();
      } else {
        _stopTimerAndLog(isFinished: true);
      }
    });
  }

  void _stopTimerAndLog({bool isFinished = false}) {
    _exerciseTimer?.cancel();
    _isExerciseTimerRunning = false;

    int durationToLog = _targetDurationSeconds;
    if (!isFinished) {
      // If user stopped it manually
      durationToLog = _targetDurationSeconds - _currentExerciseRunDownSeconds;
    }

    _sessionManager.logSetForCurrentExercise(durationToLog.toString(), "0");
    if (isFinished) {
      _sessionManager.playExerciseTimeUpSound();
    }
    _initializeFieldsForCurrentSet();
  }

  /// Logs a set for a repetition-based exercise.
  /// Returns a validation error message, or null if successful.
  String? logSet() {
    if (exercise.isTimed) return "Cannot log set for a timed exercise.";

    final reps = repsController.text.trim();
    if (reps.isEmpty || int.tryParse(reps) == null || int.parse(reps) < 0) {
      return "Please enter valid reps (a non-negative number).";
    }

    String weightToLog = "N/A";
    if (exercise.usesWeight) {
      final weightInput = weightController.text.trim();
      if (weightInput.isEmpty) {
        weightToLog = "0";
      } else {
        final parsedWeight = double.tryParse(weightInput);
        if (parsedWeight == null || parsedWeight < 0) {
          return "Weight must be a valid positive number.";
        }
        weightToLog = parsedWeight.toStringAsFixed(2);
      }
    }

    _sessionManager.logSetForCurrentExercise(reps, weightToLog);
    _initializeFieldsForCurrentSet();
    return null; // Success
  }

  String formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    Log.debug("ExerciseLoggingViewModel disposed.");
    repsController.dispose();
    weightController.dispose();
    minutesController.dispose();
    secondsController.dispose();
    _exerciseTimer?.cancel();
    super.dispose();
  }
}
