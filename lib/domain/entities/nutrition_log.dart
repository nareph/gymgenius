import 'package:gymgenius/domain/entities/logged_food_portion.dart';
import 'package:gymgenius/domain/enums/meal_type.dart';
import 'package:gymgenius/domain/enums/nutrition_log_source.dart';
import 'package:gymgenius/domain/value_objects/macro_targets.dart';

/// A single logged meal or snack entry for macro tracking.
class NutritionLog {
  final String id;
  final String userId;
  final String name;
  final NutritionLogSource source;
  final MealType mealType;
  final MacroTargets macros;
  final DateTime loggedAt;
  final String? templateId;
  final String? planMealId;
  final List<LoggedFoodPortion> portions;
  final String? note;

  const NutritionLog({
    required this.id,
    required this.userId,
    required this.name,
    required this.source,
    required this.mealType,
    required this.macros,
    required this.loggedAt,
    this.templateId,
    this.planMealId,
    this.portions = const [],
    this.note,
  });

  DateTime get dayKey => DateTime(loggedAt.year, loggedAt.month, loggedAt.day);

  bool get isValid =>
      userId.isNotEmpty &&
      name.trim().isNotEmpty &&
      macros.calories > 0 &&
      (source != NutritionLogSource.composed || portions.any((p) => p.isValid));

  @override
  String toString() =>
      'NutritionLog($name, ${source.value}, ${macros.calories} kcal)';
}
