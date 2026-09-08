import 'package:hive/hive.dart';

part 'habit_log_hive_model.g.dart';

@HiveType(typeId: 23)
class HabitLogHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String habitId;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  bool completed;

  @HiveField(5)
  DateTime loggedAt;

  /// Nullable — existing logs saved before this field existed
  /// deserialize with value == null (no quantity recorded).
  @HiveField(6)
  double? value;

  HabitLogHiveModel({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.date,
    required this.completed,
    required this.loggedAt,
    this.value,
  });
}
