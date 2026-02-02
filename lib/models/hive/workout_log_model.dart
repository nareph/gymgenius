// lib/models/hive/workout_log_model.dart

import 'package:hive/hive.dart';

part 'workout_log_model.g.dart';

@HiveType(typeId: 2)
class WorkoutLogModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime savedAt;

  @HiveField(3)
  Map<String, dynamic> workoutData;

  @HiveField(4)
  bool synced;

  WorkoutLogModel({
    required this.id,
    required this.userId,
    required this.savedAt,
    required this.workoutData,
    this.synced = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'savedAt': savedAt.millisecondsSinceEpoch,
      'workoutData': workoutData,
      'synced': synced,
    };
  }

  factory WorkoutLogModel.fromMap(Map<String, dynamic> map) {
    return WorkoutLogModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      savedAt: DateTime.fromMillisecondsSinceEpoch(map['savedAt'] as int),
      workoutData: map['workoutData'] as Map<String, dynamic>,
      synced: map['synced'] as bool? ?? true,
    );
  }
}