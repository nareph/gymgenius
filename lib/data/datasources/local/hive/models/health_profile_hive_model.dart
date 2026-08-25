import 'package:hive/hive.dart';

part 'health_profile_hive_model.g.dart';

@HiveType(typeId: 4)
class HealthProfileHiveModel extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  int age;

  @HiveField(2)
  String gender;

  @HiveField(3)
  double heightCm;

  @HiveField(4)
  double currentWeightKg;

  @HiveField(5)
  double? targetWeightKg;

  @HiveField(6)
  String goal;

  @HiveField(7)
  String experience;

  @HiveField(8)
  String activityLevel;

  @HiveField(9)
  int workoutDaysPerWeek;

  @HiveField(10)
  int workoutDurationMinutes;

  @HiveField(11)
  List<String> preferredWorkoutDays;

  @HiveField(12)
  List<String> availableEquipment;

  @HiveField(13)
  List<String> focusAreas;

  @HiveField(14)
  String country;

  @HiveField(15)
  DateTime createdAt;

  @HiveField(16)
  DateTime updatedAt;

  @HiveField(17)
  List<String>? answeredQuestionIds;

  @HiveField(18)
  List<String>? avoidedMuscles;

  /// BudgetLevel.value string (e.g. 'medium'). Nullable so profiles
  /// saved before this field existed still deserialize — mapper treats
  /// null as BudgetLevel.medium, matching the previous hardcoded default.
  @HiveField(19)
  String? budget;

  /// Nullable so profiles saved before this field existed still
  /// deserialize — mapper treats null as an empty list.
  @HiveField(20)
  List<String>? foodPreferences;

  @HiveField(21)
  List<String>? foodRestrictions;

  HealthProfileHiveModel({
    required this.userId,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.currentWeightKg,
    this.targetWeightKg,
    required this.goal,
    required this.experience,
    required this.activityLevel,
    required this.workoutDaysPerWeek,
    required this.workoutDurationMinutes,
    required this.preferredWorkoutDays,
    required this.availableEquipment,
    required this.focusAreas,
    required this.country,
    required this.createdAt,
    required this.updatedAt,
    this.answeredQuestionIds,
    this.avoidedMuscles,
    this.budget,
    this.foodPreferences,
    this.foodRestrictions,
  });
}
