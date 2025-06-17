import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymgenius/models/routine.dart'; // Dépend de RoutineExercise

/// Represents a single set of an exercise that has been performed and logged by the user.
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

  /// Converts this object into a map suitable for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'performedReps': performedReps,
      'performedWeightKg': performedWeightKg,
      'loggedAt': Timestamp.fromDate(loggedAt),
    };
  }
}

/// Represents a full exercise, including its planned details and all the sets logged against it.
class LoggedExerciseData {
  final RoutineExercise originalExercise;
  final List<LoggedSetData> loggedSets;
  final bool isCompleted;

  LoggedExerciseData({
    required this.originalExercise,
    this.loggedSets = const [],
    this.isCompleted = false,
  });

  /// Returns a new instance with an added set.
  LoggedExerciseData addSet(LoggedSetData set) {
    return LoggedExerciseData(
      originalExercise: originalExercise,
      loggedSets: List.from(loggedSets)..add(set),
      isCompleted: isCompleted,
    );
  }

  /// Returns a new instance with an updated completion status.
  LoggedExerciseData markAsCompleted(bool completedStatus) {
    return LoggedExerciseData(
      originalExercise: originalExercise,
      loggedSets: loggedSets,
      isCompleted: completedStatus,
    );
  }

  /// Converts this object into a map suitable for Firestore,
  /// containing both the planned and performed data for the exercise.
  Map<String, dynamic> toMap() {
    return {
      // Original plan data
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

      // Logged data
      'loggedSets': loggedSets.map((s) => s.toMap()).toList(),
      'isCompleted': isCompleted,
    };
  }
}
