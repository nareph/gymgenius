import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/providers/workout_session_manager.dart';
import 'package:gymgenius/services/logger_service.dart';

/// ViewModel for handling exercise logging logic, especially for timed exercises
class ExerciseLoggingViewModel extends ChangeNotifier {
  final WorkoutSessionManager _sessionManager;
  final RoutineExercise exercise;

  // Form controllers
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController minutesController = TextEditingController();
  final TextEditingController secondsController = TextEditingController();

  // Timer state
  Timer? _exerciseTimer;
  int _targetDurationSeconds = 0;
  int _currentExerciseRunDownSeconds = 0;
  bool _isExerciseTimerRunning = false;
  bool _timerPaused = false;
  int _actualDurationCompleted = 0; // Actual time completed in seconds

  // Getters
  int get currentExerciseRunDownSeconds => _currentExerciseRunDownSeconds;
  int get targetDurationSeconds => _targetDurationSeconds;
  bool get isExerciseTimerRunning => _isExerciseTimerRunning;
  bool get isTimerPaused => _timerPaused;
  int get actualDurationCompleted => _actualDurationCompleted;

  ExerciseLoggingViewModel({
    required WorkoutSessionManager sessionManager,
    required this.exercise,
  }) : _sessionManager = sessionManager {
    _initializeFieldsForCurrentSet();
  }

  /// Initialize form fields based on current set and exercise type
  void _initializeFieldsForCurrentSet() {
    final loggedData = _sessionManager.currentLoggedExerciseData;

    // Reset timer state
    _stopTimer();
    _isExerciseTimerRunning = false;
    _timerPaused = false;
    _actualDurationCompleted = 0;

    if (loggedData == null || loggedData.isCompleted) {
      repsController.clear();
      weightController.clear();
      minutesController.clear();
      secondsController.clear();

      // Initialize with exercise default value
      if (exercise.isTimed) {
        _targetDurationSeconds = exercise.targetDurationSeconds ?? 60;
        minutesController.text = (_targetDurationSeconds ~/ 60).toString();
        secondsController.text =
            (_targetDurationSeconds % 60).toString().padLeft(2, '0');
        _currentExerciseRunDownSeconds = _targetDurationSeconds;
      }
    } else {
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
    }
    notifyListeners();
  }

  /// Get initial reps suggestion from exercise reps string
  String _getInitialRepsSuggestion() {
    final repsSuggestion = exercise.reps.trim();
    final repsRangeRegex = RegExp(r'^(\d+)\s*-\s*\d+');
    final singleRepRegex = RegExp(r'^(\d+)$');

    if (repsRangeRegex.hasMatch(repsSuggestion)) {
      return repsRangeRegex.firstMatch(repsSuggestion)!.group(1)!;
    } else if (singleRepRegex.hasMatch(repsSuggestion)) {
      return singleRepRegex.firstMatch(repsSuggestion)!.group(1)!;
    }
    return "";
  }

  /// Get initial weight suggestion from exercise weight suggestion
  String _getInitialWeightSuggestion() {
    if (!exercise.usesWeight) return "";
    final weightSuggestion = exercise.weightSuggestionKg.trim();

    if (['bodyweight', 'bw', 'n/a', '']
        .contains(weightSuggestion.toLowerCase())) {
      return "";
    }

    final weightRegex = RegExp(r'^(\d+(.\d+)?)');
    final match = weightRegex.firstMatch(weightSuggestion);
    return match?.group(1) ?? "";
  }

  /// Start timer with adjusted time from form fields
  void startTimerWithAdjustedTime() {
    final minutes = int.tryParse(minutesController.text.trim()) ?? 0;
    final seconds = int.tryParse(secondsController.text.trim()) ?? 0;
    final totalSeconds = (minutes * 60) + seconds;

    if (totalSeconds <= 0) {
      Log.error("Invalid time for timer");
      return;
    }

    _targetDurationSeconds = totalSeconds;
    _currentExerciseRunDownSeconds = _targetDurationSeconds;
    _actualDurationCompleted = 0;
    _isExerciseTimerRunning = true;
    _timerPaused = false;
    _sessionManager.resetExerciseTimeUpSoundFlag();
    notifyListeners();

    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentExerciseRunDownSeconds > 0) {
        _currentExerciseRunDownSeconds--;
        _actualDurationCompleted++;
        notifyListeners();
      } else {
        _stopTimerAndLog(isFinished: true);
      }
    });
  }

  /// Pause or resume the exercise timer
  void pauseOrResumeTimer() {
    if (_timerPaused) {
      // Resume timer
      _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_currentExerciseRunDownSeconds > 0) {
          _currentExerciseRunDownSeconds--;
          _actualDurationCompleted++;
          notifyListeners();
        } else {
          _stopTimerAndLog(isFinished: true);
        }
      });
      _timerPaused = false;
    } else {
      // Pause timer
      _exerciseTimer?.cancel();
      _exerciseTimer = null;
      _timerPaused = true;
    }
    notifyListeners();
  }

  /// Stop timer and log the completed time
  void stopTimerAndLog() {
    // If timer hasn't been started, do nothing
    if (!_isExerciseTimerRunning && _actualDurationCompleted == 0) {
      return;
    }

    _stopTimerAndLog(isFinished: false);
  }

  /// Internal method to stop timer and log exercise set
  void _stopTimerAndLog({bool isFinished = false}) {
    _exerciseTimer?.cancel();
    _exerciseTimer = null;
    _isExerciseTimerRunning = false;
    _timerPaused = false;

    // For timed exercises, log the actual time completed
    int durationToLog = _actualDurationCompleted;

    // If timer completed (reached 0), log target duration
    if (isFinished) {
      durationToLog = _targetDurationSeconds;
      _sessionManager.playExerciseTimeUpSound();
    }

    // Log set with completed time
    _sessionManager.logSetForCurrentExercise(
        durationToLog.toString(), // reps = time in seconds
        "0" // weight = N/A for timed exercises
        );

    // Reinitialize for next set
    _initializeFieldsForCurrentSet();
  }

  /// Stop timer without logging
  void _stopTimer() {
    _exerciseTimer?.cancel();
    _exerciseTimer = null;
    _isExerciseTimerRunning = false;
    _timerPaused = false;
  }

  /// Log a set for non-timed exercises (rep-based)
  String? logSet() {
    if (exercise.isTimed) {
      return "Use the 'Stop & Log Time' button for timed exercises.";
    }

    final reps = repsController.text.trim();
    if (reps.isEmpty || int.tryParse(reps) == null || int.parse(reps) < 0) {
      return "Please enter a valid number of repetitions.";
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
    return null;
  }

  /// Format seconds to MM:SS string
  String formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  /// Get text for timer button based on current state
  String getTimerButtonText() {
    if (!_isExerciseTimerRunning) {
      return "Start Timer";
    } else if (_timerPaused) {
      return "Resume";
    } else {
      return "Stop & Log Time";
    }
  }

  /// Get icon for timer button based on current state
  IconData getTimerButtonIcon() {
    if (!_isExerciseTimerRunning) {
      return Icons.play_arrow_rounded;
    } else if (_timerPaused) {
      return Icons.play_arrow_rounded;
    } else {
      return Icons.stop_rounded;
    }
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
