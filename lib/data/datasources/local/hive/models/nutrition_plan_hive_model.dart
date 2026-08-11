import 'package:hive/hive.dart';
import 'meal_hive_model.dart';

part 'nutrition_plan_hive_model.g.dart';

@HiveType(typeId: 11)
class NutritionPlanHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  int calories;

  @HiveField(4)
  int proteinG;

  @HiveField(5)
  int carbsG;

  @HiveField(6)
  int fatG;

  @HiveField(7)
  int? waterMl;

  @HiveField(8)
  double maintenanceCalories;

  @HiveField(9)
  String status;

  @HiveField(10)
  List<MealHiveModel> meals;

  @HiveField(11)
  String country;

  @HiveField(12)
  bool isTrainingDay;

  @HiveField(13)
  List<String> reasons;

  @HiveField(14)
  String generatedBy;

  NutritionPlanHiveModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.waterMl,
    required this.maintenanceCalories,
    required this.status,
    required this.meals,
    required this.country,
    required this.isTrainingDay,
    required this.reasons,
    required this.generatedBy,
  });
}
