// lib/providers/workout_session_manager.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Pour ChangeNotifier
import 'package:gymgenius/models/routine.dart'; // Pour RoutineExercise

// Modèle pour une série logguée (plus détaillé que LoggableSet de l'UI)
class LoggedSetData {
  final int setNumber;
  final String performedReps;
  final String performedWeightKg;
  final DateTime loggedAt;
  // Ajoutez d'autres champs si nécessaire, ex: notes, RPE

  LoggedSetData({
    required this.setNumber,
    required this.performedReps,
    required this.performedWeightKg,
    required this.loggedAt,
  });

  Map<String, dynamic> toMap() {
    // Pour la sauvegarde Firestore
    return {
      'setNumber': setNumber,
      'performedReps': performedReps,
      'performedWeightKg': performedWeightKg,
      'loggedAt': Timestamp.fromDate(loggedAt), // Firestore Timestamp
    };
  }
}

// Modèle pour un exercice loggué pendant la session
class LoggedExerciseData {
  final RoutineExercise originalExercise;
  final List<LoggedSetData> loggedSets;
  bool isCompleted; // Si toutes les séries cibles ont été loguées

  LoggedExerciseData({
    required this.originalExercise,
    this.loggedSets = const [],
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    // Pour la sauvegarde Firestore
    return {
      // Vous voudrez peut-être un ID d'exercice stable si vous en avez un
      // 'exerciseId': originalExercise.id, (si RoutineExercise avait un ID)
      'exerciseName': originalExercise.name,
      'targetSets': originalExercise.sets,
      'targetReps': originalExercise.reps,
      'targetWeight': originalExercise.weightSuggestionKg,
      'loggedSets': loggedSets.map((s) => s.toMap()).toList(),
      'isCompleted': isCompleted,
      // 'notes': ... (si vous ajoutez des notes par exercice)
    };
  }
}

class WorkoutSessionManager with ChangeNotifier {
  bool _isWorkoutActive = false;
  DateTime? _workoutStartTime;
  Timer? _sessionDurationTimer;
  Duration _currentWorkoutDuration = Duration.zero;

  List<RoutineExercise> _plannedExercises = [];
  List<LoggedExerciseData> _loggedExercisesData =
      []; // Pour stocker les données des exos loggués
  int _currentExerciseIndex = -1; // Index dans _plannedExercises

  // Pour le timer de repos entre les séries
  Timer? _restTimer;
  int _restTimeRemainingSeconds = 0;
  bool _isResting = false;
  int _currentSetIndexForLogging = 0; // Dans l'exercice actuel

  // Getters
  bool get isWorkoutActive => _isWorkoutActive;
  Duration get currentWorkoutDuration => _currentWorkoutDuration;
  DateTime? get workoutStartTime => _workoutStartTime;

  List<RoutineExercise> get plannedExercises => _plannedExercises;
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
  int get currentSetIndexForLogging =>
      _currentSetIndexForLogging; // Prochain set à logger pour l'exo actuel

  void startWorkout(List<RoutineExercise> exercisesForSession) {
    if (_isWorkoutActive) return; // Sécurité: ne pas démarrer si déjà actif

    _isWorkoutActive = true;
    _workoutStartTime = DateTime.now();
    _currentWorkoutDuration = Duration.zero;
    _plannedExercises = List.from(exercisesForSession); // Copie de la liste
    _loggedExercisesData = _plannedExercises
        .map((ex) => LoggedExerciseData(originalExercise: ex))
        .toList();

    if (_plannedExercises.isNotEmpty) {
      _currentExerciseIndex = 0;
      _currentSetIndexForLogging = 0;
    } else {
      _currentExerciseIndex = -1; // Pas d'exercices
    }

    _sessionDurationTimer?.cancel();
    _sessionDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentWorkoutDuration += const Duration(seconds: 1);
      notifyListeners();
    });

    print("Workout Started with ${_plannedExercises.length} exercises.");
    notifyListeners();
  }

  void logSetForCurrentExercise(String reps, String weight) {
    if (currentExercise == null || currentLoggedExerciseData == null) return;

    final loggedSet = LoggedSetData(
      setNumber: _currentSetIndexForLogging + 1, // Le numéro du set est base 1
      performedReps: reps,
      performedWeightKg: weight,
      loggedAt: DateTime.now(),
    );

    // Ajoute le set loggué à l'exercice actuel dans _loggedExercisesData
    _loggedExercisesData[_currentExerciseIndex].loggedSets.add(loggedSet);

    print(
        "Logged set ${_currentSetIndexForLogging + 1} for ${currentExercise!.name}: Reps $reps, Weight $weight kg");

    // Vérifier si l'exercice est complété
    if (_loggedExercisesData[_currentExerciseIndex].loggedSets.length >=
        currentExercise!.sets) {
      _loggedExercisesData[_currentExerciseIndex].isCompleted = true;
      print("${currentExercise!.name} marked as completed.");
    }

    // Préparer pour le prochain set ou démarrer le repos
    if (!_loggedExercisesData[_currentExerciseIndex].isCompleted) {
      _currentSetIndexForLogging++;
      // Démarrer le repos si applicable
      if (currentExercise!.restBetweenSetsSeconds > 0) {
        startRestTimer(currentExercise!.restBetweenSetsSeconds);
      }
    } else {
      // Si l'exercice est complété, on ne démarre pas de timer de repos pour cet exercice
      // La logique pour passer à l'exercice suivant sera gérée par l'UI ou une autre méthode
    }
    notifyListeners();
  }

  void startRestTimer(int durationSeconds) {
    _restTimer?.cancel();
    _isResting = true;
    _restTimeRemainingSeconds = durationSeconds;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restTimeRemainingSeconds > 0) {
        _restTimeRemainingSeconds--;
      } else {
        _isResting = false;
        timer.cancel();
        // Optionnel: notification que le repos est terminé
        print("Rest finished for ${currentExercise?.name}");
      }
      notifyListeners();
    });
  }

  void skipRest() {
    _restTimer?.cancel();
    _isResting = false;
    _restTimeRemainingSeconds = 0;
    notifyListeners();
  }

  bool moveToNextExercise() {
    if (!_isWorkoutActive || currentExercise == null) return false;

    // S'assurer que l'exercice actuel est bien marqué comme complété s'il a toutes ses séries
    // (normalement fait dans logSetForCurrentExercise)
    if (currentLoggedExerciseData != null &&
        currentLoggedExerciseData!.loggedSets.length >= currentExercise!.sets &&
        !currentLoggedExerciseData!.isCompleted) {
      _loggedExercisesData[_currentExerciseIndex].isCompleted = true;
    }

    // Trouver le prochain exercice non complété
    int nextIndex = -1;
    for (int i = _currentExerciseIndex + 1; i < _plannedExercises.length; i++) {
      if (!_loggedExercisesData[i].isCompleted) {
        nextIndex = i;
        break;
      }
    }

    if (nextIndex != -1) {
      _currentExerciseIndex = nextIndex;
      _currentSetIndexForLogging = 0; // Réinitialiser pour le nouvel exercice
      _isResting = false; // Arrêter tout repos potentiel
      _restTimer?.cancel();
      print(
          "Moved to next exercise: ${_plannedExercises[_currentExerciseIndex].name}");
      notifyListeners();
      return true;
    } else {
      // Plus d'exercices non complétés après l'actuel. Vérifier s'il y en a avant (si on a skip)
      for (int i = 0; i < _currentExerciseIndex; i++) {
        if (!_loggedExercisesData[i].isCompleted) {
          _currentExerciseIndex = i;
          _currentSetIndexForLogging = 0;
          _isResting = false;
          _restTimer?.cancel();
          print(
              "Moved to an earlier uncompleted exercise: ${_plannedExercises[_currentExerciseIndex].name}");
          notifyListeners();
          return true;
        }
      }
      // Si on arrive ici, soit tous les exercices sont faits, soit l'exercice actuel est le dernier
      print(
          "No more exercises to move to, or all subsequent exercises are completed.");
      // Si tous sont complétés, on pourrait mettre _currentExerciseIndex hors limites pour le signaler
      if (_loggedExercisesData.every((ex) => ex.isCompleted)) {
        _currentExerciseIndex = _plannedExercises.length; // Indique la fin
        print("All exercises in the session are completed!");
      }
      notifyListeners();
      return false; // Pas pu bouger
    }
  }

  // Méthode pour sélectionner un exercice spécifique (par exemple si l'utilisateur tape sur un exercice dans la liste)
  bool selectExercise(int index) {
    if (!_isWorkoutActive || index < 0 || index >= _plannedExercises.length)
      return false;

    _currentExerciseIndex = index;
    // Si l'exercice sélectionné est déjà complété, on ne réinitialise pas currentSetIndexForLogging
    // S'il n'est pas complété, on le met au premier set non loggué ou à 0
    if (!_loggedExercisesData[index].isCompleted) {
      _currentSetIndexForLogging = _loggedExercisesData[index]
          .loggedSets
          .length; // Prochain set à logger
    }

    _isResting = false;
    _restTimer?.cancel();
    print(
        "Selected exercise: ${_plannedExercises[_currentExerciseIndex].name}");
    notifyListeners();
    return true;
  }

  Map<String, dynamic>? endWorkout() {
    if (!_isWorkoutActive) return null;

    _sessionDurationTimer?.cancel();
    _restTimer?.cancel();

    final Map<String, dynamic> workoutLogData = {
      // 'userId': sera ajouté au moment de la sauvegarde Firestore
      // 'routineId': à ajouter si pertinent
      // 'routineName': à ajouter si pertinent
      'workoutDate': Timestamp.fromDate(_workoutStartTime!),
      'durationInSeconds': _currentWorkoutDuration.inSeconds,
      // 'dayOfWeek': à déterminer à partir du contexte de la routine
      'completedExercises':
          _loggedExercisesData.map((exData) => exData.toMap()).toList(),
    };

    _resetSessionState();
    print("Workout Ended. Log data prepared.");
    notifyListeners();
    return workoutLogData;
  }

  void _resetSessionState() {
    _isWorkoutActive = false;
    _workoutStartTime = null;
    _currentWorkoutDuration = Duration.zero;
    _plannedExercises = [];
    _loggedExercisesData = [];
    _currentExerciseIndex = -1;
    _currentSetIndexForLogging = 0;
    _isResting = false;
    _restTimeRemainingSeconds = 0;
    _sessionDurationTimer?.cancel();
    _restTimer?.cancel();
  }

  @override
  void dispose() {
    // S'assurer que tous les timers sont annulés
    _sessionDurationTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
}
