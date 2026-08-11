import 'package:gymgenius/domain/enums/budget_level.dart';
import 'package:gymgenius/domain/enums/food_category.dart';

/// A single food entry from the Food Knowledge Base.
class FoodItem {
  final String id;
  final String name;
  final String country;
  final FoodCategory category;
  final double caloriesPer100g;
  final double proteinGPer100g;
  final double carbsGPer100g;
  final double fatGPer100g;
  final double? fiberGPer100g;
  final String defaultPortionLabel;
  final double defaultPortionGrams;
  final BudgetLevel minBudget;
  final List<String> allergens;
  final List<String> tags;

  const FoodItem({
    required this.id,
    required this.name,
    required this.country,
    required this.category,
    required this.caloriesPer100g,
    required this.proteinGPer100g,
    required this.carbsGPer100g,
    required this.fatGPer100g,
    this.fiberGPer100g,
    required this.defaultPortionLabel,
    required this.defaultPortionGrams,
    this.minBudget = BudgetLevel.low,
    this.allergens = const [],
    this.tags = const [],
  });

  double caloriesForGrams(double grams) => caloriesPer100g * grams / 100;
  double proteinForGrams(double grams) => proteinGPer100g * grams / 100;
  double carbsForGrams(double grams) => carbsGPer100g * grams / 100;
  double fatForGrams(double grams) => fatGPer100g * grams / 100;

  @override
  String toString() => 'FoodItem($name, ${caloriesPer100g.round()} kcal/100g)';
}
