import 'package:gymgenius/domain/entities/food_item.dart';
import 'models/meal_template.dart';

/// Contract every country's food dataset implements.
///
/// Adding a new country means: create `countries/<country>/`, split its
/// foods/meals into category files (mirroring `countries/cameroon/`),
/// implement this interface, and register it in
/// `country_dataset_registry.dart`. FoodKnowledgeBase itself never
/// needs to change.
abstract class CountryFoodDataset {
  const CountryFoodDataset();

  /// Canonical name returned by FoodKnowledgeBase.resolvedCountry() and
  /// used as the registry key.
  String get countryCode;

  /// Alternate spellings/codes this dataset should match against a
  /// user's free-text country answer (e.g. "Cameroun", "CM").
  List<String> get aliases => const [];

  List<FoodItem> get foods;
  List<MealTemplate> get mealTemplates;
}
