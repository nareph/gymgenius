import 'package:gymgenius/domain/entities/food_item.dart';
import 'package:gymgenius/domain/enums/budget_level.dart';
import 'package:gymgenius/engines/nutrition_engine/food_knowledge_base/cameroon_dataset.dart';

/// Resolves country-specific food datasets and applies user constraints.
class FoodKnowledgeBase {
  final CameroonFoodDataset _cameroon;

  const FoodKnowledgeBase({
    CameroonFoodDataset cameroon = const CameroonFoodDataset(),
  }) : _cameroon = cameroon;

  /// Returns foods for [country], falling back to Cameroon.
  List<FoodItem> foodsForCountry(String country) {
    return _datasetFor(country).foods;
  }

  List<MealTemplate> mealTemplatesForCountry(String country) {
    return _datasetFor(country).mealTemplates;
  }

  String resolvedCountry(String country) {
    final normalized = country.trim().toLowerCase();
    if (normalized.contains('cameroon') ||
        normalized.contains('cameroun') ||
        normalized == 'cm') {
      return _cameroon.countryCode;
    }
    // Starter phase: unknown countries fall back to Cameroon.
    return _cameroon.countryCode;
  }

  /// Filters meal templates by budget, allergies/restrictions, and preferences.
  List<MealTemplate> filterTemplates({
    required String country,
    required BudgetLevel budget,
    List<String> restrictions = const [],
    List<String> preferredFoods = const [],
  }) {
    final templates = mealTemplatesForCountry(country);
    final normalizedRestrictions =
        restrictions.map((r) => r.toLowerCase().trim()).where((r) => r.isNotEmpty).toList();
    final preferred =
        preferredFoods.map((p) => p.toLowerCase().trim()).where((p) => p.isNotEmpty).toList();

    final filtered = templates.where((template) {
      if (!_budgetAllows(budget, template.minBudget)) return false;
      if (_conflictsWithRestrictions(template, normalizedRestrictions)) {
        return false;
      }
      return true;
    }).toList();

    if (preferred.isEmpty) return filtered;

    filtered.sort((a, b) {
      final aScore = _preferenceScore(a, preferred);
      final bScore = _preferenceScore(b, preferred);
      return bScore.compareTo(aScore);
    });
    return filtered;
  }

  CameroonFoodDataset _datasetFor(String country) {
    // Only Cameroon exists in v3.2 starter; always resolve to it.
    resolvedCountry(country);
    return _cameroon;
  }

  bool _budgetAllows(BudgetLevel userBudget, BudgetLevel minBudget) {
    return userBudget.index >= minBudget.index;
  }

  bool _conflictsWithRestrictions(
    MealTemplate template,
    List<String> restrictions,
  ) {
    if (restrictions.isEmpty) return false;

    for (final restriction in restrictions) {
      for (final allergen in template.allergens) {
        if (allergen.toLowerCase().contains(restriction) ||
            restriction.contains(allergen.toLowerCase())) {
          return true;
        }
      }
      for (final ingredient in template.ingredientNames) {
        final lower = ingredient.toLowerCase();
        if (lower.contains(restriction) || restriction.contains(lower)) {
          return true;
        }
      }
      // Common aliases
      if (restriction.contains('vegetarian') || restriction.contains('vegan')) {
        if (template.tags.contains('animal') ||
            template.ingredientIds.any((id) =>
                id.contains('chicken') ||
                id.contains('beef') ||
                id.contains('fish') ||
                id.contains('sardine') ||
                id.contains('egg'))) {
          return true;
        }
      }
      if (restriction.contains('peanut') || restriction.contains('groundnut')) {
        if (template.allergens.any((a) => a.contains('peanut'))) return true;
      }
      if (restriction.contains('fish') || restriction.contains('seafood')) {
        if (template.allergens.any((a) => a.contains('fish'))) return true;
      }
      if (restriction.contains('egg')) {
        if (template.allergens.any((a) => a.contains('egg'))) return true;
      }
    }
    return false;
  }

  int _preferenceScore(MealTemplate template, List<String> preferred) {
    var score = 0;
    final haystack =
        '${template.name} ${template.ingredientNames.join(' ')}'.toLowerCase();
    for (final p in preferred) {
      if (haystack.contains(p)) score += 2;
    }
    return score;
  }
}
