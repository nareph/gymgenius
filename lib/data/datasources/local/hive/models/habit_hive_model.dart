import 'package:hive/hive.dart';

part 'habit_hive_model.g.dart';

@HiveType(typeId: 22)
class HabitHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String frequency;

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  /// Nullable so habits saved before this field existed still
  /// deserialize (Hive leaves it null; mapper treats null as "plain
  /// yes/no habit", matching the previous behavior exactly).
  @HiveField(7)
  String? unit;

  HabitHiveModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.frequency,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.unit,
  });
}
