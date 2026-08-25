import 'package:gymgenius/domain/entities/food_item.dart';

import '../../models/meal_template.dart';
import '../../country_food_dataset.dart';
import 'foods/exports.dart';
import 'meals/exports.dart';

/// Cameroon food dataset — assembled from the category files in
/// foods/ and meals/. To add a new food or meal, edit the matching
/// category file directly; nothing here needs to change unless a
/// whole new category is introduced.
class CameroonDataset extends CountryFoodDataset {
  const CameroonDataset();

  @override
  String get countryCode => 'Cameroon';

  @override
  List<String> get aliases => const ['cameroon', 'cameroun', 'cm'];

  @override
  List<FoodItem> get foods => const [
        ...cameroonCarbohydrates,
        ...cameroonProteins,
        ...cameroonFats,
        ...cameroonVegetables,
        ...cameroonFruitsAndSweeteners,
      ];

  @override
  List<MealTemplate> get mealTemplates => const [
        ...cameroonBreakfastAndSnacks,
        ...cameroonRiceAndGrainDishes,
        ...cameroonBeansDishes,
        ...cameroonTraditionalAndSoups,
      ];
}

/// Kept as a type alias so any existing `CameroonFoodDataset` reference
/// elsewhere in the codebase keeps compiling without a rename pass.
typedef CameroonFoodDataset = CameroonDataset;
