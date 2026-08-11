import 'package:gymgenius/domain/entities/meal.dart';
import 'package:gymgenius/domain/enums/nutrition_status.dart';
import 'package:gymgenius/domain/value_objects/macro_targets.dart';

/// Deterministic daily nutrition recommendation produced by the Nutrition Engine.
class NutritionPlan {
  final String userId;
  final DateTime date;
  final MacroTargets targets;
  final double maintenanceCalories;
  final NutritionStatus status;
  final List<Meal> meals;
  final String country;
  final bool isTrainingDay;
  final List<String> reasons;
  final String generatedBy;

  const NutritionPlan({
    required this.userId,
    required this.date,
    required this.targets,
    required this.maintenanceCalories,
    required this.status,
    required this.meals,
    required this.country,
    required this.isTrainingDay,
    this.reasons = const [],
    this.generatedBy = 'nutrition_engine_v1',
  });

  int get dailyCalories => targets.calories;
  int get proteinG => targets.proteinG;
  int get carbsG => targets.carbsG;
  int get fatG => targets.fatG;
  int? get hydrationMl => targets.waterMl;

  int get mealCount => meals.length;

  @override
  String toString() =>
      'NutritionPlan($date, ${targets.calories} kcal, meals=${meals.length})';
}
