import 'package:hive/hive.dart';

part 'weekly_workout_hive_model.g.dart';

@HiveType(typeId: 6)
class WeeklyWorkoutHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String programId;

  @HiveField(2)
  int weekNumber;

  @HiveField(3)
  String weekType;

  @HiveField(4)
  double volumeMultiplier;

  @HiveField(5)
  double intensityMultiplier;

  @HiveField(6)
  Map<String, dynamic> schedule;

  @HiveField(7)
  bool isActive;

  @HiveField(8)
  DateTime createdAt;

  WeeklyWorkoutHiveModel({
    required this.id,
    required this.programId,
    required this.weekNumber,
    required this.weekType,
    required this.volumeMultiplier,
    required this.intensityMultiplier,
    required this.schedule,
    required this.isActive,
    required this.createdAt,
  });
}
