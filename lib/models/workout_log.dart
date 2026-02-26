// lib/models/workout_log.dart
import 'package:gymgenius/models/hive/workout_log_model.dart';
import 'package:gymgenius/models/logged_exercise.dart';
import 'package:gymgenius/utils/type_converter.dart';

class WorkoutLog {
  final String id;
  final String userId;
  final DateTime savedAt;
  final String workoutName;
  final String? routineId;
  final String? dayKey;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final List<LoggedExerciseData> exercises;
  final int totalPlannedExercises;
  final int totalCompletedExercises;
  final bool synced;

  WorkoutLog({
    required this.id,
    required this.userId,
    required this.savedAt,
    required this.workoutName,
    this.routineId,
    this.dayKey,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.exercises,
    required this.totalPlannedExercises,
    required this.totalCompletedExercises,
    this.synced = true,
  });

  // Convert from Hive WorkoutLogModel + workoutData
  factory WorkoutLog.fromHiveModel(WorkoutLogModel hiveModel) {
    // Use TypeConverter to safely convert to Map<String, dynamic>
    final data = TypeConverter.toSafeMap(hiveModel.workoutData);

    return WorkoutLog(
      id: hiveModel.id,
      userId: hiveModel.userId,
      savedAt: hiveModel.savedAt,
      workoutName: data['workoutName']?.toString() ?? 'Unnamed Workout',
      routineId: data['routineId']?.toString(),
      dayKey: data['dayKey']?.toString(),
      startTime: _parseDateTime(data['startTime']),
      endTime: _parseDateTime(data['endTime']),
      durationSeconds: data['durationSeconds'] is num
          ? (data['durationSeconds'] as num).toInt()
          : 0,
      exercises: _parseExercises(data['exercises']),
      totalPlannedExercises: data['totalPlannedExercises'] is num
          ? (data['totalPlannedExercises'] as num).toInt()
          : 0,
      totalCompletedExercises: data['totalCompletedExercises'] is num
          ? (data['totalCompletedExercises'] as num).toInt()
          : 0,
      synced: hiveModel.synced,
    );
  }

  static List<LoggedExerciseData> _parseExercises(dynamic exercisesData) {
    if (exercisesData == null) return [];

    final List<dynamic> exercisesList;
    if (exercisesData is List) {
      exercisesList = exercisesData;
    } else {
      exercisesList = [];
    }

    return exercisesList.map((ex) {
      final safeEx = TypeConverter.toSafeMap(ex);
      return LoggedExerciseData.fromMap(safeEx);
    }).toList();
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    } else if (value is DateTime) {
      return value;
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  // Convert to map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'workoutName': workoutName,
      'routineId': routineId,
      'dayKey': dayKey,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationSeconds': durationSeconds,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'totalPlannedExercises': totalPlannedExercises,
      'totalCompletedExercises': totalCompletedExercises,
    };
  }
}
