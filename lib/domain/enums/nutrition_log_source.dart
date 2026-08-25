/// How a nutrition log entry was created (tiered fallback system).
enum NutritionLogSource {
  /// Tier 1 — logged a suggested [Meal] from today's plan as-is.
  template,

  /// Tier 2 — logged an existing [MealTemplate] from the food knowledge
  /// base's full catalog (not necessarily suggested for today).
  database,

  /// Tier 3 — composed from individual [FoodItem] portions.
  composed,

  /// Tier 4 — free-form name with user-entered macros.
  manual,
}

extension NutritionLogSourceExtension on NutritionLogSource {
  String get value {
    switch (this) {
      case NutritionLogSource.template:
        return 'template';
      case NutritionLogSource.database:
        return 'database';
      case NutritionLogSource.composed:
        return 'composed';
      case NutritionLogSource.manual:
        return 'manual';
    }
  }

  String get displayName {
    switch (this) {
      case NutritionLogSource.template:
        return 'Suggested meal';
      case NutritionLogSource.database:
        return 'Saved meal';
      case NutritionLogSource.composed:
        return 'Custom composition';
      case NutritionLogSource.manual:
        return 'Manual entry';
    }
  }

  static NutritionLogSource fromValue(String value) {
    return NutritionLogSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NutritionLogSource.manual,
    );
  }
}
