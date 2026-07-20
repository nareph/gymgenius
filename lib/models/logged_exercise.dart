// lib/models/logged_exercise.dart
import 'package:gymgenius/models/exercise.dart';
import 'package:gymgenius/utils/type_converter.dart';

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

  /// Converts this object into a map suitable for storage.
  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'performedReps': performedReps,
      'performedWeightKg': performedWeightKg,
      'loggedAt': loggedAt.millisecondsSinceEpoch,
    };
  }

  /// Factory constructor to create LoggedSetData from a map
  factory LoggedSetData.fromMap(Map<String, dynamic> map) {
    final safeMap = TypeConverter.toSafeMap(map);
    return LoggedSetData(
      setNumber: safeMap['setNumber'] is num
          ? (safeMap['setNumber'] as num).toInt()
          : 0,
      performedReps: safeMap['performedReps']?.toString() ?? '',
      performedWeightKg: safeMap['performedWeightKg']?.toString() ?? '',
      loggedAt: safeMap['loggedAt'] is num
          ? DateTime.fromMillisecondsSinceEpoch(
              (safeMap['loggedAt'] as num).toInt())
          : DateTime.now(),
    );
  }
}

/// Represents a full exercise, including its planned details and all the sets logged against it.
class LoggedExerciseData {
  final Exercise originalExercise;
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

  /// Converts this object into a map suitable for local storage,
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

  /// Factory constructor to create LoggedExerciseData from a map
  factory LoggedExerciseData.fromMap(Map<String, dynamic> map) {
    final safeMap = TypeConverter.toSafeMap(map);

    List<LoggedSetData> loggedSets = [];
    if (safeMap['loggedSets'] is List) {
      loggedSets = (safeMap['loggedSets'] as List).map((setMap) {
        final safeSetMap = TypeConverter.toSafeMap(setMap);
        return LoggedSetData.fromMap(safeSetMap);
      }).toList();
    }

    // Reconstruct Exercise from map
    final exerciseMap = {
      'id': safeMap['exerciseId'] as String?,
      'name': safeMap['exerciseName'] as String?,
      'sets': safeMap['targetSets'] as int?,
      'reps': safeMap['targetReps'] as String?,
      'description': safeMap['description'] as String?,
      'weightSuggestionKg': safeMap['targetWeight'] as String?,
      'restBetweenSetsSeconds': safeMap['targetRest'] as int?,
      'usesWeight': safeMap['usesWeight'] as bool?,
      'isTimed': safeMap['isTimed'] as bool?,
      'targetDurationSeconds': safeMap['targetDurationSeconds'] as int?,
    };

    return LoggedExerciseData(
      originalExercise: Exercise.fromMap(exerciseMap),
      loggedSets: loggedSets,
      isCompleted: safeMap['isCompleted'] is bool
          ? (safeMap['isCompleted'] as bool)
          : false,
    );
  }
}
