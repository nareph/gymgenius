// ============================================================
// FILE: lib/data/datasources/local/hive/models/workout_log_hive_model.dart
// ============================================================

import 'package:hive/hive.dart';

part 'workout_log_hive_model.g.dart';

@HiveType(typeId: 7)
class WorkoutLogHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String programId;

  @HiveField(3)
  int week;

  @HiveField(4)
  String day;

  @HiveField(5)
  DateTime startedAt;

  @HiveField(6)
  DateTime endedAt;

  @HiveField(7)
  int durationSeconds;

  @HiveField(8)
  int? caloriesEstimate;

  @HiveField(9)
  double? volume;

  @HiveField(10)
  double? averageRPE;

  @HiveField(11)
  int completionScore;

  @HiveField(12)
  List<Map<String, dynamic>> exercises;

  @HiveField(13)
  DateTime savedAt;

  WorkoutLogHiveModel({
    required this.id,
    required this.userId,
    required this.programId,
    required this.week,
    required this.day,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    this.caloriesEstimate,
    this.volume,
    this.averageRPE,
    required this.completionScore,
    required this.exercises,
    required this.savedAt,
  });
}
