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

  /// Question ids the user genuinely answered during onboarding. Nullable
  /// (rather than defaulted to `[]` at the Hive level) so that records
  /// saved BEFORE this field existed still deserialize correctly — Hive
  /// leaves it null for those, and `HealthMapper.toDomain` treats null as
  /// "unknown/legacy profile" (see mapper note).
  @HiveField(17)
  List<String>? answeredQuestionIds;

  /// Muscle groups to avoid. Nullable so profiles saved before this field
  /// still deserialize (Hive leaves it null; mapper treats null as empty).
  @HiveField(18)
  List<String>? avoidedMuscles;

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
  });
}
