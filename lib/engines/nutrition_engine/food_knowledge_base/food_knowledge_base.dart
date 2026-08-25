import 'package:gymgenius/domain/entities/food_item.dart';
import 'package:gymgenius/domain/enums/budget_level.dart';

import 'country_dataset_registry.dart';
import 'country_food_dataset.dart';
import 'countries/cameroon/cameroon_dataset.dart';
import 'models/meal_template.dart';

/// Resolves country-specific food datasets and applies user constraints.
///
/// Previously held a single hardcoded `CameroonFoodDataset` field and
/// always resolved to it — this version looks up the right dataset from
/// `countryFoodDatasets` (see country_dataset_registry.dart), falling
/// back to Cameroon when no match is found (same "starter phase"
/// behavior as before, just no longer hardcoded as the only option).
class FoodKnowledgeBase {
  final Map<String, CountryFoodDataset> _datasets;
  final CountryFoodDataset _fallback;

  const FoodKnowledgeBase({
    Map<String, CountryFoodDataset> datasets = countryFoodDatasets,
    CountryFoodDataset fallback = const CameroonDataset(),
  })  : _datasets = datasets,
        _fallback = fallback;

  /// Returns foods for [country], falling back to [_fallback] (Cameroon
  /// by default) when no registered dataset matches.
  List<FoodItem> foodsForCountry(String country) {
    return _datasetFor(country).foods;
  }

  List<MealTemplate> mealTemplatesForCountry(String country) {
    return _datasetFor(country).mealTemplates;
  }

  String resolvedCountry(String country) {
    return _datasetFor(country).countryCode;
  }

  /// Filters meal templates by budget, allergies/restrictions, and preferences.
  List<MealTemplate> filterTemplates({
    required String country,
    required BudgetLevel budget,
    List<String> restrictions = const [],
    List<String> preferredFoods = const [],
  }) {
    final templates = mealTemplatesForCountry(country);
    final normalizedRestrictions = restrictions
        .map((r) => r.toLowerCase().trim())
        .where((r) => r.isNotEmpty)
        .toList();
    final preferred = preferredFoods
        .map((p) => p.toLowerCase().trim())
        .where((p) => p.isNotEmpty)
        .toList();

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

  /// Finds the dataset whose countryCode or one of its aliases matches
  /// [country] (case-insensitive, substring match on aliases — mirrors
  /// the original "contains('cameroon') || contains('cameroun')"
  /// logic), or [_fallback] if nothing matches.
  CountryFoodDataset _datasetFor(String country) {
    final normalized = country.trim().toLowerCase();
    if (normalized.isEmpty) return _fallback;

    for (final dataset in _datasets.values) {
      if (dataset.countryCode.toLowerCase() == normalized) return dataset;
      for (final alias in dataset.aliases) {
        if (normalized.contains(alias.toLowerCase())) return dataset;
      }
    }
    return _fallback;
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
