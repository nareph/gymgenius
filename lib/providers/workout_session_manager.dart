// lib/providers/workout_session_manager.dart
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
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
      'loggedAt': Timestamp.fromDate(loggedAt), // Good for Firestore
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
      isCompleted:
          isCompleted, // isCompleted status is not changed by just adding a set
    );
  }

  LoggedExerciseData markAsCompleted(bool completedStatus) {
    return LoggedExerciseData(
      originalExercise: originalExercise,
      loggedSets: loggedSets, // Keep existing sets
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
  // --- Audio Player ---
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _restEndTimeSoundPlayed = false;
  bool _exerciseTimeUpSoundPlayed = false; // For timed exercises ending in ELS

  // --- Session State ---
  bool _isWorkoutActive = false;
  DateTime? _workoutStartTime;
  Timer? _sessionDurationTimer;
  Duration _currentWorkoutDuration = Duration.zero;
  String _currentWorkoutName = "";
  String? _currentRoutineId;
  String? _currentDayKey;

  // --- Exercise Tracking ---
  List<RoutineExercise> _plannedExercises = [];
  List<LoggedExerciseData> _loggedExercisesData = [];
  int _currentExerciseIndex = -1; // Index for current exercise

  // --- Rest Timer State ---
  Timer? _restTimer;
  int _restTimeRemainingSeconds = 0;
  int _currentRestTotalSeconds = 0;
  bool _isResting = false;

  // --- Current Set Tracking ---
  // Using a getter for currentSetIndexForLogging is generally more robust
  int get currentSetIndexForLogging =>
      currentLoggedExerciseData?.loggedSets.length ?? 0;
  // int _currentSetIndexForLogging = 0; // If you prefer manual tracking

  // --- Getters ---
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

  int get currentExerciseIndex => _currentExerciseIndex;
  int get totalExercises => _plannedExercises.length;
  int get completedExercisesCount =>
      _loggedExercisesData.where((ex) => ex.isCompleted).length;

  bool get isResting => _isResting;
  int get restTimeRemainingSeconds => _restTimeRemainingSeconds;
  int get currentRestTotalSeconds => _currentRestTotalSeconds;

  // --- Sound Methods ---
  Future<void> _playSound(String assetName) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$assetName'));
      print("MANAGER Played sound: assets/sounds/$assetName");
    } catch (e) {
      print("MANAGER Error playing sound 'assets/sounds/$assetName': $e");
    }
  }

  // Public method for ELS to call when its timer for a timed exercise ends
  Future<void> playExerciseTimeUpSound() async {
    if (!_exerciseTimeUpSoundPlayed) {
      await _playSound(
          'exercise_end.mp3'); // Assuming 'exercise_end.mp3' is for this
      _exerciseTimeUpSoundPlayed = true;
    }
  }

  // Call this from ELS when initializing a new timed set
  void resetExerciseTimeUpSoundFlag() {
    _exerciseTimeUpSoundPlayed = false;
  }

  // --- Workout Lifecycle Methods ---
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
    // _currentSetIndexForLogging = 0; // Getter handles this

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
        "MANAGER: Workout '$workoutName' started. CurrentExIndex: $_currentExerciseIndex. RoutineID: $routineId, DayKey: $dayKey");
  }

  bool startWorkoutIfNoSession(
    List<RoutineExercise> exercisesForSession, {
    String workoutName = "Workout Session",
    String? routineId,
    String? dayKey,
  }) {
    if (_isWorkoutActive) {
      print(
          "MANAGER: Workout already active ('$_currentWorkoutName'). Not starting.");
      return false;
    }
    print("MANAGER: Initializing new workout '$workoutName'.");
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
    print("MANAGER: Forcing new workout '$workoutName'.");
    if (_isWorkoutActive) {
      print("MANAGER: Resetting previous active session.");
      _resetSessionState(notify: false); // Reset without immediate notify
    }
    _startWorkoutInternal(exercisesForSession,
        workoutName: workoutName, routineId: routineId, dayKey: dayKey);
    notifyListeners(); // Notify after new state is set
  }

  void logSetForCurrentExercise(String reps, String weight) {
    if (currentExercise == null || currentLoggedExerciseData == null) {
      print("MANAGER logSet: Error - No current exercise data.");
      return;
    }

    // If exercise was marked complete but user logs another set (e.g. "extra set")
    if (currentLoggedExerciseData!.isCompleted) {
      print(
          "MANAGER logSet: Note - Exercise '${currentExercise!.name}' was marked complete. Logging an additional set.");
    }

    final loggedSet = LoggedSetData(
      setNumber: currentLoggedExerciseData!.loggedSets.length + 1,
      performedReps: reps,
      performedWeightKg: weight,
      loggedAt: DateTime.now(),
    );

    // Update the LoggedExerciseData for the current exercise
    _loggedExercisesData[_currentExerciseIndex] =
        currentLoggedExerciseData!.addSet(loggedSet);
    // _currentSetIndexForLogging++; // No longer needed if using getter for currentSetIndexForLogging

    print(
        "MANAGER logSet: Logged set ${loggedSet.setNumber} for '${currentExercise!.name}': Reps $reps, Weight $weight kg. Total sets logged: ${_loggedExercisesData[_currentExerciseIndex].loggedSets.length}");

    // Check if this set completes the planned number of sets for the exercise
    // and if the exercise wasn't already marked as complete
    if (!_loggedExercisesData[_currentExerciseIndex].isCompleted &&
        _loggedExercisesData[_currentExerciseIndex].loggedSets.length >=
            currentExercise!.sets) {
      _loggedExercisesData[_currentExerciseIndex] =
          _loggedExercisesData[_currentExerciseIndex].markAsCompleted(true);
      print(
          "MANAGER logSet: Exercise '${currentExercise!.name}' now marked as completed.");

      // If exercise just got completed, don't start a rest timer for it.
      // The user will move to the next exercise or end the workout.
      if (_isResting) {
        // Cancel any ongoing rest if the exercise completes
        skipRest();
      }
    } else if (!_loggedExercisesData[_currentExerciseIndex].isCompleted) {
      // If exercise is not yet complete, and more sets might be coming, start rest
      if (currentExercise!.restBetweenSetsSeconds > 0) {
        startRestTimer(currentExercise!.restBetweenSetsSeconds);
      }
    } else {
      // Exercise was already complete or just got completed.
      print(
          "MANAGER logSet: Exercise '${currentExercise!.name}' is complete. No automatic rest initiated from here.");
    }

    notifyListeners();
  }

  void startRestTimer(int durationSeconds) {
    if (durationSeconds <= 0) return;
    _restTimer?.cancel(); // Cancel any existing timer
    _isResting = true;
    _currentRestTotalSeconds = durationSeconds;
    _restTimeRemainingSeconds = durationSeconds;
    _restEndTimeSoundPlayed = false; // Reset sound flag for this rest period
    print(
        "MANAGER: Starting rest for $durationSeconds seconds for ${currentExercise?.name}.");
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isWorkoutActive || !_isResting) {
        timer.cancel();
        _isResting = false;
        _restTimeRemainingSeconds = 0;
        notifyListeners(); // Ensure UI updates if rest is prematurely stopped
        return;
      }

      if (_restTimeRemainingSeconds > 0) {
        _restTimeRemainingSeconds--;
      } else {
        // Timer reached 0
        timer.cancel();
        if (_isResting) {
          // Check if rest finished naturally
          if (!_restEndTimeSoundPlayed) {
            _playSound('rest_end.mp3'); // Play rest end sound
            _restEndTimeSoundPlayed = true;
          }
        }
        _isResting = false;
        // _currentSetIndexForLogging should naturally be ready for next set after rest
      }
      notifyListeners();
    });
  }

  void skipRest() {
    print("MANAGER: Skipping rest for ${currentExercise?.name}.");
    _restTimer?.cancel();
    _isResting = false;
    _restTimeRemainingSeconds = 0;
    _currentRestTotalSeconds = 0;
    _restEndTimeSoundPlayed = true; // Ensure sound doesn't play
    notifyListeners();
  }

  bool moveToNextExercise() {
    if (!_isWorkoutActive) return false;
    print(
        "MANAGER: Attempting move from index $_currentExerciseIndex (${currentExercise?.name})");

    // Mark current as complete if all planned sets are done (safety check)
    if (currentExercise != null &&
        currentLoggedExerciseData != null &&
        !currentLoggedExerciseData!.isCompleted &&
        currentLoggedExerciseData!.loggedSets.length >= currentExercise!.sets) {
      _loggedExercisesData[_currentExerciseIndex] =
          _loggedExercisesData[_currentExerciseIndex].markAsCompleted(true);
      print(
          "MANAGER moveToNextExercise: Auto-marked '${currentExercise!.name}' as complete.");
    }

    if (_isResting) skipRest(); // Cancel rest if moving

    // Find the first uncompleted exercise starting from the beginning
    int nextIdx = -1;
    for (int i = 0; i < _plannedExercises.length; i++) {
      if (i < _loggedExercisesData.length &&
          !_loggedExercisesData[i].isCompleted) {
        // If this uncompleted exercise is the current one, we need to look *after* it
        if (i == _currentExerciseIndex) {
          continue; // Skip current, look for the *next* uncompleted
        }
        nextIdx = i;
        break;
      }
    }
    // If the loop above didn't find one (e.g. current was the only uncompleted), search specifically after current
    if (nextIdx == -1 || nextIdx <= _currentExerciseIndex) {
      nextIdx = -1; // reset
      for (int i = _currentExerciseIndex + 1;
          i < _plannedExercises.length;
          i++) {
        if (i < _loggedExercisesData.length &&
            !_loggedExercisesData[i].isCompleted) {
          nextIdx = i;
          break;
        }
      }
    }

    if (nextIdx != -1) {
      _currentExerciseIndex = nextIdx;
      // _currentSetIndexForLogging = 0; // Getter handles this for the new exercise
      _exerciseTimeUpSoundPlayed =
          false; // Reset for new exercise if it's timed
      print(
          "MANAGER: Moved to: ${_plannedExercises[_currentExerciseIndex].name} (index $_currentExerciseIndex). Next set index: $currentSetIndexForLogging");
      notifyListeners();
      return true;
    } else {
      bool allDone = _loggedExercisesData.every((ex) => ex.isCompleted);
      if (allDone && _plannedExercises.isNotEmpty) {
        print("MANAGER: All exercises are now completed!");
        // Optionally, set _currentExerciseIndex = _plannedExercises.length to indicate "past the end"
      } else {
        print("MANAGER: No further uncompleted exercises found.");
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
    print("MANAGER: Selecting index $index: ${_plannedExercises[index].name}.");
    _currentExerciseIndex = index;
    // _currentSetIndexForLogging = 0; // Getter handles this for selected exercise
    _exerciseTimeUpSoundPlayed =
        false; // Reset for selected exercise if it's timed
    if (_isResting) skipRest();
    notifyListeners();
    return true;
  }

  Map<String, dynamic>? endWorkout() {
    if (!_isWorkoutActive) {
      print("MANAGER: Workout NOT active. Cannot end.");
      return null;
    }
    String endedWorkoutName = _currentWorkoutName; // Capture before reset
    print(
        "MANAGER: Ending workout '$endedWorkoutName'. Duration: ${_formatDuration(_currentWorkoutDuration)}.");

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

    _resetSessionState(notify: false); // Reset state AFTER getting all data
    print(
        "MANAGER: Session '$endedWorkoutName' ended. Log prepared. isWorkoutActive is now $_isWorkoutActive.");
    notifyListeners(); // Single notify after all state changes
    return workoutLogData;
  }

  void _resetSessionState({bool notify = true}) {
    print("MANAGER: Resetting session state.");
    _isWorkoutActive = false;
    _workoutStartTime = null;
    _currentWorkoutDuration = Duration.zero;
    _currentWorkoutName = "";
    _currentRoutineId = null;
    _currentDayKey = null;
    _plannedExercises = [];
    _loggedExercisesData = [];
    _currentExerciseIndex = -1;
    // _currentSetIndexForLogging = 0;
    _isResting = false;
    _restTimeRemainingSeconds = 0;
    _currentRestTotalSeconds = 0;
    _restEndTimeSoundPlayed = false;
    _exerciseTimeUpSoundPlayed = false;

    _sessionDurationTimer?.cancel();
    _sessionDurationTimer = null;
    _restTimer?.cancel();
    _restTimer = null;
    print("MANAGER: Session state reset. isWorkoutActive: $_isWorkoutActive.");
    if (notify) {
      notifyListeners();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) return "$hours:$minutes:$seconds";
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    print("MANAGER: WorkoutSessionManager dispose called.");
    _sessionDurationTimer?.cancel();
    _restTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
