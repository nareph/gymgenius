// lib/providers/workout_session_manager.dart
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/services/logger_service.dart';

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
      'exerciseId': originalExercise.id,
      'exerciseName': originalExercise.name,
      'targetSets': originalExercise.sets,
      'targetReps': originalExercise.reps,
      'targetWeight': originalExercise.weightSuggestionKg,
      'targetRest': originalExercise.restBetweenSetsSeconds,
      'description': originalExercise.description,
      'usesWeight': originalExercise.usesWeight,
      'isTimed': originalExercise.isTimed,
      if (originalExercise.targetDurationSeconds != null)
        'targetDurationSeconds': originalExercise.targetDurationSeconds,
      'loggedSets': loggedSets.map((s) => s.toMap()).toList(),
      'isCompleted': isCompleted,
    };
  }
}

class WorkoutSessionManager with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _restEndTimeSoundPlayed = false;
  bool _exerciseTimeUpSoundPlayed = false;

  bool _isWorkoutActive = false;
  DateTime? _workoutStartTime;
  Timer? _sessionDurationTimer;
  Duration _currentWorkoutDuration = Duration.zero;
  String _currentWorkoutName = "";
  String? _currentRoutineId;
  String? _currentDayKey;

  List<RoutineExercise> _plannedExercises = [];
  List<LoggedExerciseData> _loggedExercisesData = [];
  int _currentExerciseIndex = -1;

  Timer? _restTimer;
  int _restTimeRemainingSeconds = 0;
  int _currentRestTotalSeconds = 0;
  bool _isResting = false;

  bool get isWorkoutActive => _isWorkoutActive;
  Duration get currentWorkoutDuration => _currentWorkoutDuration;
  DateTime? get workoutStartTime => _workoutStartTime;
  String get currentWorkoutName => _currentWorkoutName;
  String? get currentRoutineId => _currentRoutineId;
  String? get currentDayKey => _currentDayKey;

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

  int get currentSetIndexForLogging =>
      currentLoggedExerciseData?.loggedSets.length ?? 0;
  int get currentExerciseIndex => _currentExerciseIndex;
  int get totalExercises => _plannedExercises.length;
  int get completedExercisesCount =>
      _loggedExercisesData.where((ex) => ex.isCompleted).length;
  bool get isResting => _isResting;
  int get restTimeRemainingSeconds => _restTimeRemainingSeconds;
  int get currentRestTotalSeconds => _currentRestTotalSeconds;

  Future<void> _playSound(String assetName) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$assetName'));
      Log.debug("Played sound: assets/sounds/$assetName");
    } catch (e, stackTrace) {
      Log.error("Error playing sound 'assets/sounds/$assetName'",
          error: e, stackTrace: stackTrace);
    }
  }

  Future<void> playExerciseTimeUpSound() async {
    if (!_exerciseTimeUpSoundPlayed) {
      await _playSound('exercise_end.mp3');
      _exerciseTimeUpSoundPlayed = true;
    }
  }

  void resetExerciseTimeUpSoundFlag() {
    _exerciseTimeUpSoundPlayed = false;
  }

  void _startWorkoutInternal(
    List<RoutineExercise> exercisesForSession, {
    String workoutName = "Workout Session",
    String? routineId,
    String? dayKey,
  }) {
    _isWorkoutActive = true;
    _workoutStartTime = DateTime.now();
    _currentWorkoutDuration = Duration.zero;
    _currentWorkoutName = workoutName;
    _currentRoutineId = routineId;
    _currentDayKey = dayKey;
    _plannedExercises = List.from(exercisesForSession);
    _loggedExercisesData = _plannedExercises
        .map((ex) => LoggedExerciseData(originalExercise: ex))
        .toList();
    _currentExerciseIndex = _plannedExercises.isNotEmpty ? 0 : -1;

    _sessionDurationTimer?.cancel();
    _sessionDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isWorkoutActive) {
        timer.cancel();
        return;
      }
      _currentWorkoutDuration += const Duration(seconds: 1);
      notifyListeners();
    });
    Log.debug(
        "Workout '$workoutName' started. CurrentExIndex: $_currentExerciseIndex. RoutineID: $routineId, DayKey: $dayKey");
  }

  bool startWorkoutIfNoSession(
    List<RoutineExercise> exercisesForSession, {
    String workoutName = "Workout Session",
    String? routineId,
    String? dayKey,
  }) {
    if (_isWorkoutActive) {
      Log.debug(
          "Workout already active ('$_currentWorkoutName'). New session not started.");
      return false;
    }
    Log.debug("Initializing new workout '$workoutName'");
    _startWorkoutInternal(exercisesForSession,
        workoutName: workoutName, routineId: routineId, dayKey: dayKey);
    notifyListeners();
    return true;
  }

  void forceStartNewWorkout(
    List<RoutineExercise> exercisesForSession, {
    String workoutName = "Workout Session",
    String? routineId,
    String? dayKey,
  }) {
    Log.debug("Forcing new workout '$workoutName'");
    if (_isWorkoutActive) {
      Log.debug("Resetting previous active session before starting new one");
      _resetSessionState(notify: false);
    }
    _startWorkoutInternal(exercisesForSession,
        workoutName: workoutName, routineId: routineId, dayKey: dayKey);
    notifyListeners();
  }

  void logSetForCurrentExercise(String reps, String weight) {
    if (currentExercise == null || currentLoggedExerciseData == null) {
      Log.error("No current exercise or logged data available");
      return;
    }

    if (currentLoggedExerciseData!.isCompleted) {
      Log.debug(
          "Exercise '${currentExercise!.name}' was already marked complete. Logging an additional set");
    }

    final loggedSet = LoggedSetData(
      setNumber: currentLoggedExerciseData!.loggedSets.length + 1,
      performedReps: reps,
      performedWeightKg: weight,
      loggedAt: DateTime.now(),
    );

    _loggedExercisesData[_currentExerciseIndex] =
        currentLoggedExerciseData!.addSet(loggedSet);
    Log.debug(
        "Logged set ${loggedSet.setNumber} for '${currentExercise!.name}': Reps $reps, Weight $weight. Total sets: ${_loggedExercisesData[_currentExerciseIndex].loggedSets.length}");

    if (!_loggedExercisesData[_currentExerciseIndex].isCompleted &&
        _loggedExercisesData[_currentExerciseIndex].loggedSets.length >=
            currentExercise!.sets) {
      _loggedExercisesData[_currentExerciseIndex] =
          _loggedExercisesData[_currentExerciseIndex].markAsCompleted(true);
      Log.debug("Exercise '${currentExercise!.name}' now marked as completed");
      if (_isResting) {
        skipRest();
      }
    } else if (!_loggedExercisesData[_currentExerciseIndex].isCompleted) {
      if (currentExercise!.restBetweenSetsSeconds > 0) {
        startRestTimer(currentExercise!.restBetweenSetsSeconds);
      }
    }
    notifyListeners();
  }

  void startRestTimer(int durationSeconds) {
    if (durationSeconds <= 0) {
      Log.debug("Rest timer not started, duration was $durationSeconds");
      if (_isResting) {
        _isResting = false;
        notifyListeners();
      }
      return;
    }

    _restTimer?.cancel();
    _isResting = true;
    _currentRestTotalSeconds = durationSeconds;
    _restTimeRemainingSeconds = durationSeconds;
    _restEndTimeSoundPlayed = false;
    Log.debug(
        "Starting rest for $durationSeconds seconds for ${currentExercise?.name}");
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isWorkoutActive || !_isResting) {
        timer.cancel();
        _isResting = false;
        _restTimeRemainingSeconds = 0;
        notifyListeners();
        return;
      }

      if (_restTimeRemainingSeconds > 0) {
        _restTimeRemainingSeconds--;
      } else {
        timer.cancel();
        if (_isResting) {
          if (!_restEndTimeSoundPlayed) {
            _playSound('rest_end.mp3');
            _restEndTimeSoundPlayed = true;
          }
        }
        _isResting = false;
      }
      notifyListeners();
    });
  }

  void skipRest() {
    Log.debug("Skipping rest for ${currentExercise?.name}");
    _restTimer?.cancel();
    _isResting = false;
    _restTimeRemainingSeconds = 0;
    _restEndTimeSoundPlayed = true;
    notifyListeners();
  }

  bool moveToNextExercise() {
    if (!_isWorkoutActive) return false;
    Log.debug(
        "Attempting move from index $_currentExerciseIndex (${currentExercise?.name})");

    if (currentExercise != null &&
        currentLoggedExerciseData != null &&
        !currentLoggedExerciseData!.isCompleted &&
        currentLoggedExerciseData!.loggedSets.length >= currentExercise!.sets) {
      _loggedExercisesData[_currentExerciseIndex] =
          _loggedExercisesData[_currentExerciseIndex].markAsCompleted(true);
      Log.debug("Auto-marked '${currentExercise!.name}' as complete");
    }

    if (_isResting) skipRest();

    int nextIdx = -1;
    for (int i = _currentExerciseIndex + 1; i < _plannedExercises.length; i++) {
      if (i < _loggedExercisesData.length &&
          !_loggedExercisesData[i].isCompleted) {
        nextIdx = i;
        break;
      }
    }
    if (nextIdx == -1) {
      for (int i = 0; i < _currentExerciseIndex; i++) {
        if (i < _loggedExercisesData.length &&
            !_loggedExercisesData[i].isCompleted) {
          nextIdx = i;
          break;
        }
      }
    }

    if (nextIdx != -1) {
      _currentExerciseIndex = nextIdx;
      _exerciseTimeUpSoundPlayed = false;
      Log.debug(
          "Moved to: ${_plannedExercises[_currentExerciseIndex].name} (index $_currentExerciseIndex)");
      notifyListeners();
      return true;
    } else {
      bool allEffectivelyDone =
          _loggedExercisesData.every((ex) => ex.isCompleted);
      if (allEffectivelyDone && _plannedExercises.isNotEmpty) {
        Log.debug("All exercises are now effectively completed!");
      } else {
        Log.debug("No further uncompleted exercises found");
      }
      notifyListeners();
      return false;
    }
  }

  bool selectExercise(int index) {
    if (!_isWorkoutActive || index < 0 || index >= _plannedExercises.length) {
      Log.error("Invalid index $index or workout not active");
      return false;
    }
    Log.debug(
        "Manually selecting index $index: ${_plannedExercises[index].name}");
    _currentExerciseIndex = index;
    _exerciseTimeUpSoundPlayed = false;
    if (_isResting) skipRest();
    notifyListeners();
    return true;
  }

  Map<String, dynamic>? endWorkout() {
    if (!_isWorkoutActive) {
      Log.debug("Workout NOT active. Cannot end");
      return null;
    }
    String endedWorkoutName = _currentWorkoutName;
    Log.debug(
        "Ending workout '$endedWorkoutName'. Duration: ${_formatDuration(_currentWorkoutDuration)}");

    _sessionDurationTimer?.cancel();
    _restTimer?.cancel();

    final Map<String, dynamic> workoutLogData = {
      'workoutName': _currentWorkoutName,
      'routineId': _currentRoutineId,
      'dayKey': _currentDayKey,
      'startTime': _workoutStartTime?.toIso8601String(),
      'endTime': DateTime.now().toIso8601String(),
      'durationSeconds': _currentWorkoutDuration.inSeconds,
      'exercises':
          _loggedExercisesData.map((exData) => exData.toMap()).toList(),
      'totalPlannedExercises': _plannedExercises.length,
      'totalCompletedExercises': completedExercisesCount,
    };

    _resetSessionState(notify: false);
    Log.debug(
        "Session '$endedWorkoutName' ended. Log prepared. isWorkoutActive is now $_isWorkoutActive");
    notifyListeners();
    return workoutLogData;
  }

  void _resetSessionState({bool notify = true}) {
    Log.debug("Resetting all session state");
    _isWorkoutActive = false;
    _workoutStartTime = null;
    _currentWorkoutDuration = Duration.zero;
    _currentWorkoutName = "";
    _currentRoutineId = null;
    _currentDayKey = null;
    _plannedExercises = [];
    _loggedExercisesData = [];
    _currentExerciseIndex = -1;
    _isResting = false;
    _restTimeRemainingSeconds = 0;
    _currentRestTotalSeconds = 0;
    _restEndTimeSoundPlayed = false;
    _exerciseTimeUpSoundPlayed = false;

    _sessionDurationTimer?.cancel();
    _sessionDurationTimer = null;
    _restTimer?.cancel();
    _restTimer = null;

    if (notify) {
      notifyListeners();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return "$hours:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    Log.debug("dispose() called. Cancelling timers");
    _sessionDurationTimer?.cancel();
    _restTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
