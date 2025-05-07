// lib/providers/workout_session_manager.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymgenius/models/routine.dart';

class LoggedSetData {
  final int setNumber;
  final String performedReps;
  final String performedWeightKg;
  final DateTime loggedAt;

  LoggedSetData({
    required this.setNumber,
    required this.performedReps,
    required this.performedWeightKg,
    required this.loggedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'performedReps': performedReps,
      'performedWeightKg': performedWeightKg,
      'loggedAt': Timestamp.fromDate(loggedAt),
    };
  }
}

class LoggedExerciseData {
  final RoutineExercise originalExercise;
  final List<LoggedSetData> loggedSets;
  bool isCompleted;

  LoggedExerciseData({
    required this.originalExercise,
    this.loggedSets = const [],
    this.isCompleted = false,
  });

  LoggedExerciseData addSet(LoggedSetData set) {
    return LoggedExerciseData(
      originalExercise: originalExercise,
      loggedSets: List.from(loggedSets)..add(set),
      isCompleted: isCompleted,
    );
  }

  LoggedExerciseData markAsCompleted(bool completedStatus) {
    return LoggedExerciseData(
      originalExercise: originalExercise,
      loggedSets: loggedSets,
      isCompleted: completedStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseName': originalExercise.name,
      'targetSets': originalExercise.sets,
      'targetReps': originalExercise.reps,
      'targetWeight': originalExercise.weightSuggestionKg,
      'targetRest': originalExercise.restBetweenSetsSeconds,
      'description': originalExercise.description,
      'loggedSets': loggedSets.map((s) => s.toMap()).toList(),
      'isCompleted': isCompleted,
    };
  }
}

class WorkoutSessionManager with ChangeNotifier {
  bool _isWorkoutActive = false;
  DateTime? _workoutStartTime;
  Timer? _sessionDurationTimer;
  Duration _currentWorkoutDuration = Duration.zero;
  String _currentWorkoutName = "";

  List<RoutineExercise> _plannedExercises = [];
  List<LoggedExerciseData> _loggedExercisesData = [];
  int _currentExerciseIndex = -1;

  Timer? _restTimer;
  int _restTimeRemainingSeconds = 0;
  bool _isResting = false;
  int _currentSetIndexForLogging = 0;

  bool get isWorkoutActive => _isWorkoutActive;
  Duration get currentWorkoutDuration => _currentWorkoutDuration;
  DateTime? get workoutStartTime => _workoutStartTime;
  String get currentWorkoutName => _currentWorkoutName;
  List<RoutineExercise> get plannedExercises =>
      List.unmodifiable(_plannedExercises);
  List<LoggedExerciseData> get loggedExercisesData =>
      List.unmodifiable(_loggedExercisesData);

  RoutineExercise? get currentExercise => (_isWorkoutActive &&
          _currentExerciseIndex >= 0 &&
          _currentExerciseIndex < _plannedExercises.length)
      ? _plannedExercises[_currentExerciseIndex]
      : null;

  LoggedExerciseData? get currentLoggedExerciseData => (_isWorkoutActive &&
          _currentExerciseIndex >= 0 &&
          _currentExerciseIndex < _loggedExercisesData.length)
      ? _loggedExercisesData[_currentExerciseIndex]
      : null;

  int get currentExerciseIndex => _currentExerciseIndex;
  int get totalExercises => _plannedExercises.length;
  int get completedExercisesCount =>
      _loggedExercisesData.where((ex) => ex.isCompleted).length;
  bool get isResting => _isResting;
  int get restTimeRemainingSeconds => _restTimeRemainingSeconds;
  int get currentSetIndexForLogging => _currentSetIndexForLogging;

  void startWorkout(List<RoutineExercise> exercisesForSession,
      {String workoutName = "Workout Session"}) {
    if (_isWorkoutActive) {
      print(
          "MANAGER startWorkout: Workout already active ('${_currentWorkoutName}'). To start a new one, end current or use forceStart. Current session continues.");
      return; // Ne pas écraser la session active sans confirmation explicite de l'UI
    }
    print("MANAGER startWorkout: Initializing new workout '$workoutName'.");
    _isWorkoutActive = true;
    _workoutStartTime = DateTime.now();
    _currentWorkoutDuration = Duration.zero;
    _currentWorkoutName = workoutName;
    _plannedExercises = List.from(exercisesForSession);
    _loggedExercisesData = _plannedExercises
        .map((ex) => LoggedExerciseData(originalExercise: ex))
        .toList();

    if (_plannedExercises.isNotEmpty) {
      _currentExerciseIndex = 0;
      _currentSetIndexForLogging = 0;
    } else {
      _currentExerciseIndex = -1;
    }

    _sessionDurationTimer?.cancel();
    _sessionDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isWorkoutActive) {
        timer.cancel();
        return;
      }
      _currentWorkoutDuration += const Duration(seconds: 1);
      notifyListeners();
    });
    print(
        "MANAGER startWorkout: Workout '$workoutName' started with ${_plannedExercises.length} exercises. currentExerciseIndex: $_currentExerciseIndex.");
    notifyListeners();
  }

  void forceStartNewWorkout(List<RoutineExercise> exercisesForSession,
      {String workoutName = "Workout Session"}) {
    print(
        "MANAGER forceStartNewWorkout: Forcing new workout '$workoutName', resetting previous session if any.");
    _resetSessionState();
    startWorkout(exercisesForSession, workoutName: workoutName);
  }

  void logSetForCurrentExercise(String reps, String weight) {
    if (currentExercise == null ||
        _currentExerciseIndex < 0 ||
        _currentExerciseIndex >= _loggedExercisesData.length) {
      print(
          "MANAGER logSet: Error - No current exercise or index out of bounds. Index: $_currentExerciseIndex");
      return;
    }
    if (_loggedExercisesData[_currentExerciseIndex].isCompleted) {
      print(
          "MANAGER logSet: Error - Attempt to log set for already completed exercise: ${currentExercise!.name}");
      return;
    }

    final loggedSet = LoggedSetData(
      setNumber: _currentSetIndexForLogging + 1,
      performedReps: reps,
      performedWeightKg: weight,
      loggedAt: DateTime.now(),
    );

    final currentLoggedExData = _loggedExercisesData[_currentExerciseIndex];
    _loggedExercisesData[_currentExerciseIndex] =
        currentLoggedExData.addSet(loggedSet);

    print(
        "MANAGER logSet: Logged set ${_currentSetIndexForLogging + 1} for ${currentExercise!.name}: Reps $reps, Weight $weight kg");

    if (_loggedExercisesData[_currentExerciseIndex].loggedSets.length >=
        currentExercise!.sets) {
      _loggedExercisesData[_currentExerciseIndex] =
          _loggedExercisesData[_currentExerciseIndex].markAsCompleted(true);
      print(
          "MANAGER logSet: Exercise ${currentExercise!.name} marked as completed.");
    }

    if (!_loggedExercisesData[_currentExerciseIndex].isCompleted) {
      _currentSetIndexForLogging++;
      print(
          "MANAGER logSet: Moving to next set index for ${currentExercise!.name}: $_currentSetIndexForLogging");
      if (currentExercise!.restBetweenSetsSeconds > 0) {
        startRestTimer(currentExercise!.restBetweenSetsSeconds);
      }
    } else {
      _isResting = false;
      _restTimer?.cancel();
      print(
          "MANAGER logSet: Exercise ${currentExercise!.name} just completed. Rest cancelled/not started.");
    }
    notifyListeners();
  }

  void startRestTimer(int durationSeconds) {
    if (durationSeconds <= 0) return;
    _restTimer?.cancel();
    _isResting = true;
    _restTimeRemainingSeconds = durationSeconds;
    print(
        "MANAGER startRestTimer: Starting rest for $durationSeconds seconds for ${currentExercise?.name}.");
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isWorkoutActive || !_isResting) {
        print(
            "MANAGER restTimer tick: Workout no longer active or not resting. Cancelling rest timer.");
        timer.cancel();
        _isResting = false;
        _restTimeRemainingSeconds = 0;
        notifyListeners();
        return;
      }
      if (_restTimeRemainingSeconds > 0) {
        _restTimeRemainingSeconds--;
      } else {
        _isResting = false;
        timer.cancel();
        print(
            "MANAGER restTimer tick: Rest finished for ${currentExercise?.name}");
      }
      notifyListeners();
    });
  }

  void skipRest() {
    print("MANAGER skipRest: Skipping rest for ${currentExercise?.name}.");
    _restTimer?.cancel();
    _isResting = false;
    _restTimeRemainingSeconds = 0;
    notifyListeners();
  }

  bool moveToNextExercise() {
    if (!_isWorkoutActive) {
      print("MANAGER moveToNextExercise: Workout NOT active. Returning false.");
      return false;
    }
    print(
        "MANAGER moveToNextExercise: Attempting to move from index $_currentExerciseIndex (${currentExercise?.name})");

    if (currentExercise != null &&
        currentLoggedExerciseData != null &&
        currentLoggedExerciseData!.loggedSets.length >= currentExercise!.sets &&
        !currentLoggedExerciseData!.isCompleted) {
      print(
          "MANAGER moveToNextExercise: Marking current exercise ${currentExercise!.name} as completed before moving.");
      _loggedExercisesData[_currentExerciseIndex] =
          _loggedExercisesData[_currentExerciseIndex].markAsCompleted(true);
    }

    int nextIndex = -1;
    int searchStartIndex =
        (_currentExerciseIndex < 0) ? 0 : _currentExerciseIndex + 1;
    print(
        "MANAGER moveToNextExercise: Searching for next uncompleted from index $searchStartIndex.");

    for (int i = searchStartIndex; i < _plannedExercises.length; i++) {
      if (i < _loggedExercisesData.length &&
          !_loggedExercisesData[i].isCompleted) {
        nextIndex = i;
        break;
      }
    }

    if (nextIndex != -1) {
      _currentExerciseIndex = nextIndex;
      _currentSetIndexForLogging =
          _loggedExercisesData[_currentExerciseIndex].loggedSets.length;
      _isResting = false;
      _restTimer?.cancel();
      print(
          "MANAGER moveToNextExercise: Successfully moved to next exercise: ${_plannedExercises[_currentExerciseIndex].name} (index $_currentExerciseIndex). Next set to log: ${_currentSetIndexForLogging + 1}");
      notifyListeners();
      return true;
    } else {
      bool allDone = _plannedExercises.isNotEmpty &&
          _loggedExercisesData.every((ex) => ex.isCompleted);
      if (allDone) {
        _currentExerciseIndex = _plannedExercises.length;
        _isResting = false;
        _restTimer?.cancel();
        print(
            "MANAGER moveToNextExercise: All exercises in the session are completed! currentExerciseIndex set to $_currentExerciseIndex");
      } else {
        if (_currentExerciseIndex < _plannedExercises.length) {
          print(
              "MANAGER moveToNextExercise: No *further* uncompleted exercises. Current index $_currentExerciseIndex is likely last uncompleted or all done.");
        }
      }
      notifyListeners();
      return false;
    }
  }

  bool selectExercise(int index) {
    if (!_isWorkoutActive || index < 0 || index >= _plannedExercises.length) {
      print(
          "MANAGER selectExercise: Invalid index $index or workout not active.");
      return false;
    }
    print(
        "MANAGER selectExercise: Selecting exercise at index $index: ${_plannedExercises[index].name}.");
    _currentExerciseIndex = index;
    _currentSetIndexForLogging = _loggedExercisesData[index]
        .loggedSets
        .length; // Prochain set à logger pour cet exercice
    _isResting = false;
    _restTimer?.cancel();
    notifyListeners();
    return true;
  }

  Map<String, dynamic>? endWorkout() {
    if (!_isWorkoutActive) {
      print("MANAGER endWorkout: Called but workout session NOT active.");
      return null;
    }
    print(
        "MANAGER endWorkout: CALLED. Workout WAS active. Current duration: ${_formatDuration(_currentWorkoutDuration)}. Stack trace:");
    debugPrintStack(maxFrames: 5);

    _sessionDurationTimer?.cancel();
    _restTimer?.cancel();

    final Map<String, dynamic> workoutLogData = {
      'workoutName': _currentWorkoutName,
      'workoutDate': Timestamp.fromDate(_workoutStartTime!),
      'durationInSeconds': _currentWorkoutDuration.inSeconds,
      'completedExercises':
          _loggedExercisesData.map((exData) => exData.toMap()).toList(),
    };

    String summary =
        "Workout Ended: $_currentWorkoutName. Duration: ${_formatDuration(_currentWorkoutDuration)}. Exercises logged: ${_loggedExercisesData.where((e) => e.loggedSets.isNotEmpty).length}.";
    _resetSessionState(); // Met _isWorkoutActive à false

    print(
        "MANAGER endWorkout: Session ended. Data prepared. isWorkoutActive is now $_isWorkoutActive.");
    print(summary);
    notifyListeners();
    return workoutLogData;
  }

  void _resetSessionState() {
    print(
        "MANAGER: _resetSessionState CALLED! About to set isWorkoutActive to false. Current value: $_isWorkoutActive. Stack trace:");
    debugPrintStack(maxFrames: 5);
    _isWorkoutActive = false;
    _workoutStartTime = null;
    _currentWorkoutDuration = Duration.zero;
    _currentWorkoutName = "";
    _plannedExercises = [];
    _loggedExercisesData = [];
    _currentExerciseIndex = -1;
    _currentSetIndexForLogging = 0;
    _isResting = false;
    _restTimeRemainingSeconds = 0;
    _sessionDurationTimer?.cancel();
    _restTimer?.cancel();
    print(
        "MANAGER: _resetSessionState FINISHED. isWorkoutActive is now $_isWorkoutActive.");
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    print("MANAGER: WorkoutSessionManager dispose called.");
    _resetSessionState();
    super.dispose();
  }
}
