// lib/providers/workout_session_manager.dart

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:gymgenius/models/logged_exercise.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/models/workout_log.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:uuid/uuid.dart';

class WorkoutSessionManager with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final _uuid = const Uuid();

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

  // Getters
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

  // Sound methods
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
      await _playSound('rest_end.mp3');
      _exerciseTimeUpSoundPlayed = true;
    }
  }

  void resetExerciseTimeUpSoundFlag() {
    _exerciseTimeUpSoundPlayed = false;
  }

  // Wakelock methods
  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
      Log.debug("WorkoutSession: Wakelock enabled - screen will stay awake");
    } catch (e) {
      Log.error("WorkoutSession: Failed to enable wakelock", error: e);
    }
  }

  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
      Log.debug("WorkoutSession: Wakelock disabled - screen can sleep");
    } catch (e) {
      Log.error("WorkoutSession: Failed to disable wakelock", error: e);
    }
  }

  // Internal workout start
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

    // Enable wakelock to keep screen awake during workout
    _enableWakelock();

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

  // Public workout start methods
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

  // Logging methods
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

  // Rest timer methods
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

  // Navigation methods
  bool moveToNextExercise() {
    if (!_isWorkoutActive) return false;
    Log.debug(
        "Attempting move from index currentExerciseIndex($_currentExerciseIndex) for ${currentExercise?.name}");

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

  /// End workout and return WorkoutLog object (without user ID - repository handles that)
  WorkoutLog? endWorkout() {
    if (!_isWorkoutActive) {
      Log.debug("Workout NOT active. Cannot end");
      return null;
    }

    String endedWorkoutName = _currentWorkoutName;
    DateTime workoutEndTime = DateTime.now();

    Log.debug(
        "Ending workout '$endedWorkoutName'. Duration: ${_formatDuration(_currentWorkoutDuration)}");

    _sessionDurationTimer?.cancel();
    _restTimer?.cancel();

    // Disable wakelock when workout ends
    _disableWakelock();

    // Create WorkoutLog object WITHOUT userId (repository will add it)
    final workoutLog = WorkoutLog(
      id: _uuid.v4(),
      userId: '', // Will be set by repository when saving
      savedAt: DateTime.now(),
      workoutName: _currentWorkoutName.isNotEmpty
          ? _currentWorkoutName
          : 'Unnamed Workout',
      routineId: _currentRoutineId,
      dayKey: _currentDayKey,
      startTime: _workoutStartTime ?? workoutEndTime,
      endTime: workoutEndTime,
      durationSeconds: _currentWorkoutDuration.inSeconds,
      exercises: List.from(_loggedExercisesData),
      totalPlannedExercises: _plannedExercises.length,
      totalCompletedExercises: completedExercisesCount,
      synced: true,
    );

    Log.debug("========== WORKOUT LOG OBJECT CREATED ==========");
    Log.debug("  - ID: ${workoutLog.id}");
    Log.debug("  - Name: ${workoutLog.workoutName}");
    Log.debug("  - Duration: ${workoutLog.durationSeconds}s");
    Log.debug("  - Exercises logged: ${workoutLog.exercises.length}");
    Log.debug(
        "  - Completed: ${workoutLog.totalCompletedExercises}/${workoutLog.totalPlannedExercises}");
    Log.debug("  - Start: ${workoutLog.startTime}");
    Log.debug("  - End: ${workoutLog.endTime}");
    Log.debug("================================================");

    _resetSessionState(notify: false);
    Log.debug(
        "Session '$endedWorkoutName' ended. Log prepared. isWorkoutActive is now $_isWorkoutActive");
    notifyListeners();

    return workoutLog;
  }

  // Reset session
  void _resetSessionState({bool notify = true}) {
    Log.debug("Resetting all session state");

    // Disable wakelock when resetting session
    _disableWakelock();

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

  // Utility methods
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
    Log.debug("dispose() called. Cancelling timers and disabling wakelock");
    _sessionDurationTimer?.cancel();
    _restTimer?.cancel();
    _audioPlayer.dispose();

    // Ensure wakelock is disabled on disposal
    _disableWakelock();

    super.dispose();
  }
}
