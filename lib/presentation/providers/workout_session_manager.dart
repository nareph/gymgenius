import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/logged_exercise.dart';
import 'package:gymgenius/domain/entities/logged_set.dart';
import 'package:gymgenius/domain/entities/workout_log.dart';
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
  String? _currentProgramId;
  String? _currentDayKey;
  List<Exercise> _plannedExercises = [];
  List<LoggedExercise> _loggedExercisesData = [];
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
  String? get currentProgramId => _currentProgramId;
  String? get currentDayKey => _currentDayKey;
  List<Exercise> get plannedExercises => List.unmodifiable(_plannedExercises);
  List<LoggedExercise> get loggedExercisesData =>
      List.unmodifiable(_loggedExercisesData);

  Exercise? get currentExercise => (_isWorkoutActive &&
          _currentExerciseIndex >= 0 &&
          _currentExerciseIndex < _plannedExercises.length)
      ? _plannedExercises[_currentExerciseIndex]
      : null;

  LoggedExercise? get currentLoggedExerciseData => (_isWorkoutActive &&
          _currentExerciseIndex >= 0 &&
          _currentExerciseIndex < _loggedExercisesData.length)
      ? _loggedExercisesData[_currentExerciseIndex]
      : null;

  int get currentSetIndexForLogging =>
      currentLoggedExerciseData?.sets.length ?? 0;
  int get currentExerciseIndex => _currentExerciseIndex;
  int get totalExercises => _plannedExercises.length;
  int get completedExercisesCount =>
      _loggedExercisesData.where((ex) => ex.completed).length;
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
    List<Exercise> exercisesForSession, {
    String workoutName = "Workout Session",
    String? programId,
    String? dayKey,
  }) {
    _isWorkoutActive = true;
    _workoutStartTime = DateTime.now();
    _currentWorkoutDuration = Duration.zero;
    _currentWorkoutName = workoutName;
    _currentProgramId = programId;
    _currentDayKey = dayKey;
    _plannedExercises = List.from(exercisesForSession);
    _loggedExercisesData = _plannedExercises.map((ex) {
      return LoggedExercise(
        exerciseId: ex.id,
        name: ex.name,
        targetSets: ex.sets,
        targetReps: ex.reps,
        targetRestSeconds: ex.restSeconds,
        isTimed: ex.isTimed,
        sets: [], // no sets logged yet
        completed: false,
        rpe: null,
      );
    }).toList();
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
        "Workout '$workoutName' started. CurrentExIndex: $_currentExerciseIndex. ProgramID: $programId, DayKey: $dayKey");
  }

  // Public workout start methods
  bool startWorkoutIfNoSession(
    List<Exercise> exercisesForSession, {
    String workoutName = "Workout Session",
    String? programId,
    String? dayKey,
  }) {
    if (_isWorkoutActive) {
      Log.debug(
          "Workout already active ('$_currentWorkoutName'). New session not started.");
      return false;
    }
    Log.debug("Initializing new workout '$workoutName'");
    _startWorkoutInternal(exercisesForSession,
        workoutName: workoutName, programId: programId, dayKey: dayKey);
    notifyListeners();
    return true;
  }

  void forceStartNewWorkout(
    List<Exercise> exercisesForSession, {
    String workoutName = "Workout Session",
    String? programId,
    String? dayKey,
  }) {
    Log.debug("Forcing new workout '$workoutName'");
    if (_isWorkoutActive) {
      Log.debug("Resetting previous active session before starting new one");
      _resetSessionState(notify: false);
    }
    _startWorkoutInternal(exercisesForSession,
        workoutName: workoutName, programId: programId, dayKey: dayKey);
    notifyListeners();
  }

  // Logging methods
  void logSetForCurrentExercise(String reps, String weight) {
    if (currentExercise == null || currentLoggedExerciseData == null) {
      Log.error("No current exercise or logged data available");
      return;
    }

    final currentEx = currentExercise!;
    final currentLog = currentLoggedExerciseData!;

    final parsedReps = int.tryParse(reps) ?? 0;
    final parsedWeight = double.tryParse(weight) ?? 0.0;

    final newSet = LoggedSet(
      setNumber: currentLog.sets.length + 1,
      reps: parsedReps,
      weightKg: parsedWeight,
      loggedAt: DateTime.now(),
    );

    final updatedLog = currentLog.copyWith(
      sets: [...currentLog.sets, newSet],
      completed: currentLog.completed ||
          (currentLog.sets.length + 1 >= currentEx.sets),
    );

    _loggedExercisesData[_currentExerciseIndex] = updatedLog;

    Log.debug(
        "Logged set ${newSet.setNumber} for '${currentEx.name}': Reps $reps, Weight $weight. Total sets: ${updatedLog.sets.length}");

    if (!updatedLog.completed && updatedLog.sets.length >= currentEx.sets) {
      // Mark as completed but already done in copyWith
      Log.debug("Exercise '${currentEx.name}' now marked as completed");
      if (_isResting) {
        skipRest();
      }
    } else if (!updatedLog.completed) {
      if (currentEx.restSeconds > 0) {
        startRestTimer(currentEx.restSeconds);
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
        "Attempting move from index $_currentExerciseIndex for ${currentExercise?.name}");

    if (currentExercise != null &&
        currentLoggedExerciseData != null &&
        !currentLoggedExerciseData!.completed &&
        currentLoggedExerciseData!.sets.length >= currentExercise!.sets) {
      // Already completed via logging, but ensure it's marked
      _loggedExercisesData[_currentExerciseIndex] =
          _loggedExercisesData[_currentExerciseIndex].copyWith(completed: true);
      Log.debug("Auto-marked '${currentExercise!.name}' as complete");
    }

    if (_isResting) skipRest();

    int nextIdx = -1;
    for (int i = _currentExerciseIndex + 1; i < _plannedExercises.length; i++) {
      if (i < _loggedExercisesData.length &&
          !_loggedExercisesData[i].completed) {
        nextIdx = i;
        break;
      }
    }
    if (nextIdx == -1) {
      for (int i = 0; i < _currentExerciseIndex; i++) {
        if (i < _loggedExercisesData.length &&
            !_loggedExercisesData[i].completed) {
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
          _loggedExercisesData.every((ex) => ex.completed);
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

  /// End workout and return domain WorkoutLog object.
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

    // Compute completion score (percentage of completed exercises)
    int totalExercises = _plannedExercises.length;
    int completedExercises =
        _loggedExercisesData.where((e) => e.completed).length;
    int completionScore = totalExercises > 0
        ? (completedExercises / totalExercises * 100).round()
        : 0;

    // Create WorkoutLog domain entity
    final workoutLog = WorkoutLog(
      id: _uuid.v4(),
      userId: '', // Will be set by repository when saving
      programId: _currentProgramId ?? '',
      week: 1, // default; could be derived from program later
      day: _currentDayKey ?? 'unknown',
      startedAt: _workoutStartTime ?? workoutEndTime,
      endedAt: workoutEndTime,
      durationSeconds: _currentWorkoutDuration.inSeconds,
      caloriesEstimate: null,
      volume: null, // Could compute total kg lifted if needed
      averageRPE: null,
      completionScore: completionScore,
      exercises: _loggedExercisesData,
      savedAt: DateTime.now(),
    );

    Log.debug("========== WORKOUT LOG OBJECT CREATED (DOMAIN) ==========");
    Log.debug("  - ID: ${workoutLog.id}");
    Log.debug("  - Name: ${workoutLog.programId} - ${workoutLog.day}");
    Log.debug("  - Duration: ${workoutLog.durationSeconds}s");
    Log.debug("  - Exercises logged: ${workoutLog.exercises.length}");
    Log.debug(
        "  - Completed: ${workoutLog.completedExercises}/${workoutLog.totalExercises}");
    Log.debug("  - Completion score: ${workoutLog.completionScore}");
    Log.debug("  - Start: ${workoutLog.startedAt}");
    Log.debug("  - End: ${workoutLog.endedAt}");
    Log.debug("========================================================");

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
    _currentProgramId = null;
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
