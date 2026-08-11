import 'package:hive/hive.dart';

part 'daily_checkin_hive_model.g.dart';

@HiveType(typeId: 14)
class DailyCheckInHiveModel extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  double weightKg;

  @HiveField(3)
  double sleepHours;

  /// Stored as string value from [SorenessLevel.value].
  @HiveField(4)
  String sorenessLevel;

  /// Stored as string value from [EnergyLevel.value].
  @HiveField(5)
  String energyLevel;

  @HiveField(6)
  int mood;

  DailyCheckInHiveModel({
    required this.userId,
    required this.date,
    required this.weightKg,
    required this.sleepHours,
    required this.sorenessLevel,
    required this.energyLevel,
    required this.mood,
  });
}
