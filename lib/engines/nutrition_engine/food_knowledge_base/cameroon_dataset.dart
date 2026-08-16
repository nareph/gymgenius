import 'package:gymgenius/domain/entities/food_item.dart';
import 'package:gymgenius/domain/enums/budget_level.dart';
import 'package:gymgenius/domain/enums/food_category.dart';
import 'package:gymgenius/domain/enums/meal_objective.dart';
import 'package:gymgenius/domain/value_objects/macro_targets.dart';

/// Template meal used by the MealPlanner (before portion scaling).
class MealTemplate {
  final String id;
  final String name;
  final MealObjective objective;
  final List<String> ingredientIds;
  final List<String> ingredientNames;
  final MacroTargets baseMacros;
  final BudgetLevel minBudget;
  final List<String> allergens;
  final List<String> tags;

  const MealTemplate({
    required this.id,
    required this.name,
    required this.objective,
    required this.ingredientIds,
    required this.ingredientNames,
    required this.baseMacros,
    this.minBudget = BudgetLevel.low,
    this.allergens = const [],
    this.tags = const [],
  });
}

/// Cameroon starter Food Knowledge Base.
class CameroonFoodDataset {
  const CameroonFoodDataset();

  String get countryCode => 'Cameroon';

  List<FoodItem> get foods => _foods;

  List<MealTemplate> get mealTemplates => _meals;

  static const List<FoodItem> _foods = [
    // ============================================================
    // 1. CARBOHYDRATES (Glucides)
    // ============================================================
    FoodItem(
      id: 'cm_rice',
      name: 'White rice (cooked)',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 130,
      proteinGPer100g: 2.7,
      carbsGPer100g: 28,
      fatGPer100g: 0.3,
      fiberGPer100g: 0.4,
      defaultPortionLabel: '1 cup',
      defaultPortionGrams: 158,
      tags: ['staple'],
    ),
    FoodItem(
      id: 'cm_plantain_boiled',
      name: 'Boiled plantain',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 122,
      proteinGPer100g: 1.3,
      carbsGPer100g: 31,
      fatGPer100g: 0.4,
      fiberGPer100g: 2.3,
      defaultPortionLabel: '1 medium',
      defaultPortionGrams: 180,
      tags: ['staple'],
    ),
    FoodItem(
      id: 'cm_plantain_fried',
      name: 'Fried plantain (ripe)',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 210,
      proteinGPer100g: 1.5,
      carbsGPer100g: 35,
      fatGPer100g: 8,
      fiberGPer100g: 2.0,
      defaultPortionLabel: '1 serving',
      defaultPortionGrams: 150,
      tags: ['staple', 'street_food'],
    ),
    FoodItem(
      id: 'cm_cassava',
      name: 'Boiled cassava',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 160,
      proteinGPer100g: 1.4,
      carbsGPer100g: 38,
      fatGPer100g: 0.3,
      fiberGPer100g: 1.8,
      defaultPortionLabel: '1 serving',
      defaultPortionGrams: 200,
      tags: ['staple'],
    ),
    FoodItem(
      id: 'cm_cassava_bobolo',
      name: 'Bobolo / Miondo (cassava stick)',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 150,
      proteinGPer100g: 1.5,
      carbsGPer100g: 35,
      fatGPer100g: 0.5,
      fiberGPer100g: 2.0,
      defaultPortionLabel: '1 piece',
      defaultPortionGrams: 150,
      tags: ['staple', 'traditional'],
    ),
    FoodItem(
      id: 'cm_fufu',
      name: 'Water fufu',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 170,
      proteinGPer100g: 1.2,
      carbsGPer100g: 40,
      fatGPer100g: 0.2,
      defaultPortionLabel: '1 ball',
      defaultPortionGrams: 200,
      tags: ['staple', 'traditional'],
    ),
    FoodItem(
      id: 'cm_sweet_potato',
      name: 'Sweet potato (boiled)',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 90,
      proteinGPer100g: 2.0,
      carbsGPer100g: 21,
      fatGPer100g: 0.2,
      fiberGPer100g: 3.0,
      defaultPortionLabel: '1 medium',
      defaultPortionGrams: 150,
      tags: ['staple'],
    ),
    FoodItem(
      id: 'cm_yam',
      name: 'Boiled yam',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 118,
      proteinGPer100g: 1.5,
      carbsGPer100g: 28,
      fatGPer100g: 0.2,
      defaultPortionLabel: '1 serving',
      defaultPortionGrams: 180,
      tags: ['staple'],
    ),
    FoodItem(
      id: 'cm_maize_boiled',
      name: 'Corn / maize (boiled)',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 96,
      proteinGPer100g: 3.4,
      carbsGPer100g: 21,
      fatGPer100g: 1.5,
      fiberGPer100g: 2.0,
      defaultPortionLabel: '1 cob',
      defaultPortionGrams: 150,
      tags: ['staple'],
    ),
    FoodItem(
      id: 'cm_cocoyam',
      name: 'Cocoyam (boiled)',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 112,
      proteinGPer100g: 1.5,
      carbsGPer100g: 26,
      fatGPer100g: 0.2,
      defaultPortionLabel: '1 serving',
      defaultPortionGrams: 180,
      tags: ['traditional'],
    ),
    FoodItem(
      id: 'cm_irish_potato',
      name: 'Irish potato (boiled)',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 87,
      proteinGPer100g: 1.9,
      carbsGPer100g: 20,
      fatGPer100g: 0.1,
      defaultPortionLabel: '2 medium',
      defaultPortionGrams: 200,
    ),
    FoodItem(
      id: 'cm_bread',
      name: 'Local bread',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 265,
      proteinGPer100g: 9,
      carbsGPer100g: 49,
      fatGPer100g: 3.2,
      defaultPortionLabel: '2 slices',
      defaultPortionGrams: 70,
      tags: ['breakfast'],
    ),
    FoodItem(
      id: 'cm_beignets',
      name: 'Beignets (doughnuts)',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 380,
      proteinGPer100g: 6,
      carbsGPer100g: 45,
      fatGPer100g: 20,
      defaultPortionLabel: '1 large piece',
      defaultPortionGrams: 60,
      tags: ['breakfast', 'street_food'],
    ),
    FoodItem(
      id: 'cm_corn_flour',
      name: 'Corn flour (maize meal)',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 365,
      proteinGPer100g: 7,
      carbsGPer100g: 76,
      fatGPer100g: 1.5,
      defaultPortionLabel: '1 cup (80g)',
      defaultPortionGrams: 80,
      tags: ['staple', 'flour'],
    ),

    // ============================================================
    // 2. PROTEINS (Protéines)
    // ============================================================
    FoodItem(
      id: 'cm_eggs',
      name: 'Eggs',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 155,
      proteinGPer100g: 13,
      carbsGPer100g: 1.1,
      fatGPer100g: 11,
      defaultPortionLabel: '2 eggs',
      defaultPortionGrams: 100,
      allergens: ['egg'],
      tags: ['animal'],
    ),
    FoodItem(
      id: 'cm_chicken',
      name: 'Grilled chicken',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 165,
      proteinGPer100g: 31,
      carbsGPer100g: 0,
      fatGPer100g: 3.6,
      defaultPortionLabel: '1 serving',
      defaultPortionGrams: 150,
      minBudget: BudgetLevel.medium,
      tags: ['animal'],
    ),
    FoodItem(
      id: 'cm_chicken_dg',
      name: 'Chicken (DG style)',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 200,
      proteinGPer100g: 28,
      carbsGPer100g: 2,
      fatGPer100g: 10,
      defaultPortionLabel: '1 piece',
      defaultPortionGrams: 120,
      minBudget: BudgetLevel.medium,
      tags: ['animal', 'traditional'],
    ),
    FoodItem(
      id: 'cm_beef',
      name: 'Beef',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 250,
      proteinGPer100g: 26,
      carbsGPer100g: 0,
      fatGPer100g: 15,
      defaultPortionLabel: '1 serving',
      defaultPortionGrams: 120,
      minBudget: BudgetLevel.medium,
      tags: ['animal'],
    ),
    FoodItem(
      id: 'cm_beef_kondre',
      name: 'Kondré (beef tripe / cow skin)',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 180,
      proteinGPer100g: 22,
      carbsGPer100g: 0,
      fatGPer100g: 10,
      defaultPortionLabel: '1 serving',
      defaultPortionGrams: 150,
      minBudget: BudgetLevel.medium,
      tags: ['animal', 'traditional'],
    ),
    FoodItem(
      id: 'cm_fish',
      name: 'Fresh fish (tilapia)',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 128,
      proteinGPer100g: 26,
      carbsGPer100g: 0,
      fatGPer100g: 2.7,
      defaultPortionLabel: '1 fillet',
      defaultPortionGrams: 150,
      allergens: ['fish'],
      tags: ['animal'],
    ),
    FoodItem(
      id: 'cm_smoked_fish',
      name: 'Smoked fish',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 180,
      proteinGPer100g: 32,
      carbsGPer100g: 0,
      fatGPer100g: 5,
      defaultPortionLabel: '1 piece',
      defaultPortionGrams: 80,
      allergens: ['fish'],
      tags: ['animal', 'traditional'],
    ),
    FoodItem(
      id: 'cm_sardines',
      name: 'Sardines (canned)',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 208,
      proteinGPer100g: 25,
      carbsGPer100g: 0,
      fatGPer100g: 11,
      defaultPortionLabel: '1 tin',
      defaultPortionGrams: 100,
      allergens: ['fish'],
      tags: ['animal'],
    ),
    FoodItem(
      id: 'cm_beans',
      name: 'Beans (cooked)',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 127,
      proteinGPer100g: 8.7,
      carbsGPer100g: 22.8,
      fatGPer100g: 0.5,
      fiberGPer100g: 6.4,
      defaultPortionLabel: '1 cup',
      defaultPortionGrams: 180,
      tags: ['plant', 'staple'],
    ),
    FoodItem(
      id: 'cm_koki_beans',
      name: 'Black-eyed peas (for koki)',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 116,
      proteinGPer100g: 7.7,
      carbsGPer100g: 20.8,
      fatGPer100g: 0.5,
      defaultPortionLabel: '1 cup',
      defaultPortionGrams: 170,
      tags: ['plant', 'traditional'],
    ),
    FoodItem(
      id: 'cm_soy_flour',
      name: 'Soy flour (full fat)',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 405,
      proteinGPer100g: 36,
      carbsGPer100g: 31,
      fatGPer100g: 19,
      defaultPortionLabel: '1 tbsp (20g)',
      defaultPortionGrams: 20,
      tags: ['plant', 'flour'],
    ),
    FoodItem(
      id: 'cm_groundnuts',
      name: 'Groundnuts / peanuts',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 567,
      proteinGPer100g: 26,
      carbsGPer100g: 16,
      fatGPer100g: 49,
      defaultPortionLabel: '1 handful',
      defaultPortionGrams: 30,
      allergens: ['peanut'],
      tags: ['plant'],
    ),
    FoodItem(
      id: 'cm_fermented_milk',
      name: 'Fermented milk / Pendidam (lait caillé)',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 60,
      proteinGPer100g: 3.2,
      carbsGPer100g: 4.5,
      fatGPer100g: 3.0,
      defaultPortionLabel: '1 glass',
      defaultPortionGrams: 200,
      tags: ['dairy', 'breakfast'],
    ),
    FoodItem(
      id: 'cm_nido_powder',
      name: 'Nido milk powder (full cream)',
      country: 'Cameroon',
      category: FoodCategory.protein,
      caloriesPer100g: 496,
      proteinGPer100g: 26,
      carbsGPer100g: 38,
      fatGPer100g: 26,
      defaultPortionLabel: '1 tbsp (10g)',
      defaultPortionGrams: 10,
      tags: ['dairy'],
    ),

    // ============================================================
    // 3. FATS (Lipides)
    // ============================================================
    FoodItem(
      id: 'cm_avocado',
      name: 'Avocado',
      country: 'Cameroon',
      category: FoodCategory.fat,
      caloriesPer100g: 160,
      proteinGPer100g: 2,
      carbsGPer100g: 8.5,
      fatGPer100g: 15,
      fiberGPer100g: 6.7,
      defaultPortionLabel: '1/2 fruit',
      defaultPortionGrams: 70,
      tags: ['plant'],
    ),
    FoodItem(
      id: 'cm_palm_oil',
      name: 'Palm oil',
      country: 'Cameroon',
      category: FoodCategory.fat,
      caloriesPer100g: 884,
      proteinGPer100g: 0,
      carbsGPer100g: 0,
      fatGPer100g: 100,
      defaultPortionLabel: '1 tbsp',
      defaultPortionGrams: 14,
      tags: ['cooking'],
    ),
    FoodItem(
      id: 'cm_peanut_paste',
      name: 'Peanut paste',
      country: 'Cameroon',
      category: FoodCategory.fat,
      caloriesPer100g: 588,
      proteinGPer100g: 25,
      carbsGPer100g: 20,
      fatGPer100g: 50,
      defaultPortionLabel: '1 tbsp',
      defaultPortionGrams: 16,
      allergens: ['peanut'],
    ),
    FoodItem(
      id: 'cm_peanut_oil',
      name: 'Peanut oil',
      country: 'Cameroon',
      category: FoodCategory.fat,
      caloriesPer100g: 884,
      proteinGPer100g: 0,
      carbsGPer100g: 0,
      fatGPer100g: 100,
      defaultPortionLabel: '1 tbsp (10g)',
      defaultPortionGrams: 10,
      tags: ['cooking'],
    ),
    FoodItem(
      id: 'cm_ogbono',
      name: 'Ogbono (wild mango seeds)',
      country: 'Cameroon',
      category: FoodCategory.fat,
      caloriesPer100g: 500,
      proteinGPer100g: 10,
      carbsGPer100g: 20,
      fatGPer100g: 45,
      defaultPortionLabel: '1 tbsp (15g)',
      defaultPortionGrams: 15,
      tags: ['traditional', 'soup'],
    ),

    // ============================================================
    // 4. VEGETABLES (Légumes)
    // ============================================================
    FoodItem(
      id: 'cm_spinach',
      name: 'Spinach / leafy greens',
      country: 'Cameroon',
      category: FoodCategory.vegetable,
      caloriesPer100g: 23,
      proteinGPer100g: 2.9,
      carbsGPer100g: 3.6,
      fatGPer100g: 0.4,
      fiberGPer100g: 2.2,
      defaultPortionLabel: '1 cup cooked',
      defaultPortionGrams: 180,
    ),
    FoodItem(
      id: 'cm_eru_leaves',
      name: 'Eru leaves',
      country: 'Cameroon',
      category: FoodCategory.vegetable,
      caloriesPer100g: 35,
      proteinGPer100g: 3.5,
      carbsGPer100g: 5,
      fatGPer100g: 0.5,
      defaultPortionLabel: '1 serving',
      defaultPortionGrams: 150,
      tags: ['traditional'],
    ),
    FoodItem(
      id: 'cm_ndole_leaves',
      name: 'Ndolé leaves',
      country: 'Cameroon',
      category: FoodCategory.vegetable,
      caloriesPer100g: 40,
      proteinGPer100g: 4,
      carbsGPer100g: 5,
      fatGPer100g: 0.5,
      defaultPortionLabel: '1 serving',
      defaultPortionGrams: 150,
      tags: ['traditional'],
    ),
    FoodItem(
      id: 'cm_okra',
      name: 'Okra',
      country: 'Cameroon',
      category: FoodCategory.vegetable,
      caloriesPer100g: 33,
      proteinGPer100g: 1.9,
      carbsGPer100g: 7.5,
      fatGPer100g: 0.2,
      defaultPortionLabel: '1 cup',
      defaultPortionGrams: 100,
    ),
    FoodItem(
      id: 'cm_cabbage',
      name: 'Cabbage',
      country: 'Cameroon',
      category: FoodCategory.vegetable,
      caloriesPer100g: 25,
      proteinGPer100g: 1.3,
      carbsGPer100g: 5.8,
      fatGPer100g: 0.1,
      defaultPortionLabel: '1 cup',
      defaultPortionGrams: 90,
    ),
    FoodItem(
      id: 'cm_tomato',
      name: 'Tomato',
      country: 'Cameroon',
      category: FoodCategory.vegetable,
      caloriesPer100g: 18,
      proteinGPer100g: 0.9,
      carbsGPer100g: 3.9,
      fatGPer100g: 0.2,
      defaultPortionLabel: '1 medium',
      defaultPortionGrams: 120,
    ),
    FoodItem(
      id: 'cm_carrot',
      name: 'Carrot',
      country: 'Cameroon',
      category: FoodCategory.vegetable,
      caloriesPer100g: 41,
      proteinGPer100g: 0.9,
      carbsGPer100g: 10,
      fatGPer100g: 0.2,
      defaultPortionLabel: '1 medium',
      defaultPortionGrams: 60,
    ),
    FoodItem(
      id: 'cm_onion',
      name: 'Onion',
      country: 'Cameroon',
      category: FoodCategory.vegetable,
      caloriesPer100g: 40,
      proteinGPer100g: 1.1,
      carbsGPer100g: 9.3,
      fatGPer100g: 0.1,
      defaultPortionLabel: '1 medium',
      defaultPortionGrams: 110,
    ),
    FoodItem(
      id: 'cm_hot_pepper',
      name: 'Hot pepper (piment)',
      country: 'Cameroon',
      category: FoodCategory.vegetable,
      caloriesPer100g: 30,
      proteinGPer100g: 1.5,
      carbsGPer100g: 6,
      fatGPer100g: 0.3,
      defaultPortionLabel: '1 piece',
      defaultPortionGrams: 10,
      tags: ['spice'],
    ),

    // ============================================================
    // 5. FRUITS & SWEETENERS (Fruits & Sucreries)
    // ============================================================
    FoodItem(
      id: 'cm_banana',
      name: 'Banana',
      country: 'Cameroon',
      category: FoodCategory.fruit,
      caloriesPer100g: 89,
      proteinGPer100g: 1.1,
      carbsGPer100g: 23,
      fatGPer100g: 0.3,
      defaultPortionLabel: '1 medium',
      defaultPortionGrams: 120,
      tags: ['snack'],
    ),
    FoodItem(
      id: 'cm_mango',
      name: 'Mango',
      country: 'Cameroon',
      category: FoodCategory.fruit,
      caloriesPer100g: 60,
      proteinGPer100g: 0.8,
      carbsGPer100g: 15,
      fatGPer100g: 0.4,
      defaultPortionLabel: '1 fruit',
      defaultPortionGrams: 200,
      tags: ['snack'],
    ),
    FoodItem(
      id: 'cm_papaya',
      name: 'Papaya',
      country: 'Cameroon',
      category: FoodCategory.fruit,
      caloriesPer100g: 43,
      proteinGPer100g: 0.5,
      carbsGPer100g: 11,
      fatGPer100g: 0.3,
      defaultPortionLabel: '1 cup',
      defaultPortionGrams: 150,
      tags: ['snack'],
    ),
    FoodItem(
      id: 'cm_pineapple',
      name: 'Pineapple',
      country: 'Cameroon',
      category: FoodCategory.fruit,
      caloriesPer100g: 50,
      proteinGPer100g: 0.5,
      carbsGPer100g: 13,
      fatGPer100g: 0.1,
      defaultPortionLabel: '1 cup',
      defaultPortionGrams: 165,
      tags: ['snack'],
    ),
    FoodItem(
      id: 'cm_orange',
      name: 'Orange',
      country: 'Cameroon',
      category: FoodCategory.fruit,
      caloriesPer100g: 47,
      proteinGPer100g: 0.9,
      carbsGPer100g: 12,
      fatGPer100g: 0.1,
      defaultPortionLabel: '1 fruit',
      defaultPortionGrams: 130,
      tags: ['snack'],
    ),
    FoodItem(
      id: 'cm_watermelon',
      name: 'Watermelon',
      country: 'Cameroon',
      category: FoodCategory.fruit,
      caloriesPer100g: 30,
      proteinGPer100g: 0.6,
      carbsGPer100g: 7.6,
      fatGPer100g: 0.2,
      defaultPortionLabel: '1 cup',
      defaultPortionGrams: 150,
      tags: ['snack'],
    ),
    FoodItem(
      id: 'cm_sugar',
      name: 'Granulated sugar',
      country: 'Cameroon',
      category: FoodCategory.carbohydrate,
      caloriesPer100g: 387,
      proteinGPer100g: 0,
      carbsGPer100g: 100,
      fatGPer100g: 0,
      defaultPortionLabel: '1 tbsp (15g)',
      defaultPortionGrams: 15,
      tags: ['sweetener'],
    ),
  ];

  static const List<MealTemplate> _meals = [
    // ============================================================
    // ORIGINAL MEALS (kept as-is)
    // ============================================================
    MealTemplate(
      id: 'cm_meal_eggs_bread',
      name: 'Eggs with bread and avocado',
      objective: MealObjective.highProtein,
      ingredientIds: ['cm_eggs', 'cm_bread', 'cm_avocado'],
      ingredientNames: ['Eggs', 'Local bread', 'Avocado'],
      baseMacros:
          MacroTargets(calories: 450, proteinG: 22, carbsG: 35, fatG: 24),
      allergens: ['egg'],
      tags: ['breakfast'],
    ),
    MealTemplate(
      id: 'cm_meal_rice_chicken',
      name: 'Rice and grilled chicken with vegetables',
      objective: MealObjective.highProtein,
      ingredientIds: ['cm_rice', 'cm_chicken', 'cm_tomato', 'cm_cabbage'],
      ingredientNames: ['White rice', 'Grilled chicken', 'Tomato', 'Cabbage'],
      baseMacros:
          MacroTargets(calories: 620, proteinG: 45, carbsG: 60, fatG: 12),
      minBudget: BudgetLevel.medium,
      tags: ['lunch', 'dinner'],
    ),
    MealTemplate(
      id: 'cm_meal_beans_plantain',
      name: 'Beans and plantain',
      objective: MealObjective.highEnergy,
      ingredientIds: ['cm_beans', 'cm_plantain_boiled'],
      ingredientNames: ['Beans', 'Boiled plantain'],
      baseMacros:
          MacroTargets(calories: 550, proteinG: 20, carbsG: 95, fatG: 4),
      tags: ['lunch', 'dinner', 'staple'],
    ),
    MealTemplate(
      id: 'cm_meal_ndole',
      name: 'Ndolé with plantain',
      objective: MealObjective.highEnergy,
      ingredientIds: [
        'cm_ndole_leaves',
        'cm_groundnuts',
        'cm_beef',
        'cm_plantain_boiled',
      ],
      ingredientNames: ['Ndolé leaves', 'Groundnuts', 'Beef', 'Plantain'],
      baseMacros:
          MacroTargets(calories: 700, proteinG: 35, carbsG: 55, fatG: 35),
      minBudget: BudgetLevel.medium,
      allergens: ['peanut'],
      tags: ['traditional', 'dinner'],
    ),
    MealTemplate(
      id: 'cm_meal_eru_fufu',
      name: 'Water fufu and Eru',
      objective: MealObjective.highEnergy,
      ingredientIds: [
        'cm_fufu',
        'cm_eru_leaves',
        'cm_smoked_fish',
        'cm_beef',
      ],
      ingredientNames: ['Water fufu', 'Eru', 'Smoked fish', 'Beef'],
      baseMacros:
          MacroTargets(calories: 750, proteinG: 40, carbsG: 70, fatG: 28),
      minBudget: BudgetLevel.medium,
      allergens: ['fish'],
      tags: ['traditional', 'dinner'],
    ),
    MealTemplate(
      id: 'cm_meal_fish_sweet_potato',
      name: 'Fish with sweet potatoes',
      objective: MealObjective.recovery,
      ingredientIds: ['cm_fish', 'cm_sweet_potato', 'cm_spinach'],
      ingredientNames: ['Fresh fish', 'Sweet potato', 'Spinach'],
      baseMacros:
          MacroTargets(calories: 480, proteinG: 40, carbsG: 45, fatG: 8),
      allergens: ['fish'],
      tags: ['lunch', 'dinner', 'recovery'],
    ),
    MealTemplate(
      id: 'cm_meal_beans_avocado',
      name: 'Beans with avocado',
      objective: MealObjective.recovery,
      ingredientIds: ['cm_beans', 'cm_avocado', 'cm_tomato'],
      ingredientNames: ['Beans', 'Avocado', 'Tomato'],
      baseMacros:
          MacroTargets(calories: 420, proteinG: 18, carbsG: 40, fatG: 18),
      tags: ['lunch', 'recovery'],
    ),
    MealTemplate(
      id: 'cm_meal_koki',
      name: 'Koki with boiled plantain',
      objective: MealObjective.highEnergy,
      ingredientIds: ['cm_koki_beans', 'cm_palm_oil', 'cm_plantain_boiled'],
      ingredientNames: ['Black-eyed peas', 'Palm oil', 'Plantain'],
      baseMacros:
          MacroTargets(calories: 580, proteinG: 18, carbsG: 70, fatG: 22),
      tags: ['traditional', 'lunch'],
    ),
    MealTemplate(
      id: 'cm_meal_fruit_eggs',
      name: 'Fruit plate with boiled eggs',
      objective: MealObjective.light,
      ingredientIds: ['cm_banana', 'cm_papaya', 'cm_eggs'],
      ingredientNames: ['Banana', 'Papaya', 'Eggs'],
      baseMacros:
          MacroTargets(calories: 320, proteinG: 15, carbsG: 40, fatG: 10),
      allergens: ['egg'],
      tags: ['snack', 'breakfast'],
    ),
    MealTemplate(
      id: 'cm_meal_sardines_potato',
      name: 'Sardines with Irish potatoes',
      objective: MealObjective.highProtein,
      ingredientIds: ['cm_sardines', 'cm_irish_potato', 'cm_onion'],
      ingredientNames: ['Sardines', 'Irish potato', 'Onion'],
      baseMacros:
          MacroTargets(calories: 500, proteinG: 30, carbsG: 45, fatG: 18),
      allergens: ['fish'],
      tags: ['lunch', 'dinner'],
    ),
    MealTemplate(
      id: 'cm_meal_achu',
      name: 'Achu (cocoyam yellow soup)',
      objective: MealObjective.highEnergy,
      ingredientIds: ['cm_cocoyam', 'cm_beef', 'cm_fish', 'cm_palm_oil'],
      ingredientNames: ['Cocoyam', 'Beef', 'Fish', 'Palm oil'],
      baseMacros:
          MacroTargets(calories: 720, proteinG: 38, carbsG: 60, fatG: 30),
      minBudget: BudgetLevel.medium,
      allergens: ['fish'],
      tags: ['traditional', 'dinner'],
    ),
    MealTemplate(
      id: 'cm_meal_veggie_soup',
      name: 'Vegetable soup with eggs',
      objective: MealObjective.light,
      ingredientIds: ['cm_spinach', 'cm_okra', 'cm_tomato', 'cm_eggs'],
      ingredientNames: ['Spinach', 'Okra', 'Tomato', 'Eggs'],
      baseMacros:
          MacroTargets(calories: 280, proteinG: 18, carbsG: 15, fatG: 14),
      allergens: ['egg'],
      tags: ['light', 'dinner'],
    ),

    // ============================================================
    // NEW ADDITIONS (Cameroonian classics & Power Porridge)
    // ============================================================

    // --------------------------------------------
    // 1. BOUILLIE DE MAÏS POWER (Your custom porridge)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_power_porridge',
      name: 'Bouillie de maïs Power (Maize Power Porridge)',
      objective: MealObjective.highProtein,
      ingredientIds: [
        'cm_corn_flour', // 80g
        'cm_soy_flour', // 20g
        'cm_nido_powder', // 40g
        'cm_eggs', // 2 eggs ≈ 100g
        'cm_peanut_paste', // 30g
        'cm_peanut_oil', // 10g
        'cm_sugar', // 15g
      ],
      ingredientNames: [
        'Corn flour',
        'Soy flour',
        'Nido powder',
        'Eggs',
        'Peanut paste',
        'Peanut oil',
        'Sugar'
      ],
      baseMacros: MacroTargets(
        calories: 720,
        proteinG: 43,
        carbsG: 106,
        fatG: 52,
      ),
      minBudget: BudgetLevel.low,
      allergens: ['egg', 'peanut'],
      tags: ['breakfast', 'mass_gain', 'porridge', 'post_workout'],
    ),

    // --------------------------------------------
    // 2. POULET DG (Direc't General Chicken)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_poulet_dg',
      name: 'Poulet DG (DG Chicken with plantains)',
      objective: MealObjective.highEnergy,
      ingredientIds: [
        'cm_chicken_dg',
        'cm_plantain_fried',
        'cm_carrot',
        'cm_tomato',
        'cm_palm_oil',
        'cm_onion',
      ],
      ingredientNames: [
        'DG Chicken',
        'Fried plantain',
        'Carrot',
        'Tomato',
        'Palm oil',
        'Onion'
      ],
      baseMacros:
          MacroTargets(calories: 780, proteinG: 42, carbsG: 65, fatG: 38),
      minBudget: BudgetLevel.medium,
      tags: ['traditional', 'lunch', 'dinner', 'special'],
    ),

    // --------------------------------------------
    // 3. CORN CHAFF (Maïs + Haricots)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_corn_chaff',
      name: 'Corn Chaff (maize and beans)',
      objective: MealObjective.highEnergy,
      ingredientIds: [
        'cm_maize_boiled',
        'cm_beans',
        'cm_palm_oil',
        'cm_onion',
        'cm_hot_pepper',
      ],
      ingredientNames: [
        'Boiled corn',
        'Beans',
        'Palm oil',
        'Onion',
        'Hot pepper'
      ],
      baseMacros:
          MacroTargets(calories: 520, proteinG: 20, carbsG: 65, fatG: 18),
      tags: ['street_food', 'lunch', 'dinner', 'staple'],
    ),

    // --------------------------------------------
    // 4. BEIGNETS & FERMENTED MILK (Petit-déjeuner)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_beignets_lait',
      name: 'Beignets with fermented milk (Pendidam)',
      objective: MealObjective.highEnergy,
      ingredientIds: ['cm_beignets', 'cm_fermented_milk'],
      ingredientNames: ['Beignets', 'Fermented milk'],
      baseMacros:
          MacroTargets(calories: 420, proteinG: 12, carbsG: 45, fatG: 22),
      allergens: ['dairy'],
      tags: ['breakfast', 'street_food', 'snack'],
    ),

    // --------------------------------------------
    // 5. KONDRÉ WITH BOBOLO
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_kondre_bobolo',
      name: 'Kondré (cow skin stew) with Bobolo',
      objective: MealObjective.highProtein,
      ingredientIds: [
        'cm_beef_kondre',
        'cm_cassava_bobolo',
        'cm_palm_oil',
        'cm_tomato',
        'cm_onion',
      ],
      ingredientNames: ['Kondré', 'Bobolo', 'Palm oil', 'Tomato', 'Onion'],
      baseMacros:
          MacroTargets(calories: 680, proteinG: 35, carbsG: 60, fatG: 30),
      minBudget: BudgetLevel.medium,
      tags: ['traditional', 'dinner', 'lunch'],
    ),

    // --------------------------------------------
    // 6. SMOKED FISH & MIONDO
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_smoked_fish_miondo',
      name: 'Smoked fish with Miondo',
      objective: MealObjective.recovery,
      ingredientIds: ['cm_smoked_fish', 'cm_cassava_bobolo', 'cm_spinach'],
      ingredientNames: ['Smoked fish', 'Miondo', 'Spinach'],
      baseMacros:
          MacroTargets(calories: 480, proteinG: 38, carbsG: 50, fatG: 12),
      minBudget: BudgetLevel.low,
      allergens: ['fish'],
      tags: ['traditional', 'dinner', 'recovery'],
    ),

    // ============================================================
    // NOUVEAUX PLATS CAMEROUNAIS (Jollof, Riz, Viandes, etc.)
    // ============================================================

    // --------------------------------------------
    // 7. JOLLOF RICE (Riz au gras / Riz Jollof)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_jollof_rice',
      name: 'Jollof Rice (Riz au gras)',
      objective: MealObjective.highEnergy,
      ingredientIds: [
        'cm_rice',
        'cm_tomato',
        'cm_onion',
        'cm_hot_pepper',
        'cm_palm_oil'
      ],
      ingredientNames: ['Rice', 'Tomato', 'Onion', 'Hot pepper', 'Palm oil'],
      baseMacros:
          MacroTargets(calories: 450, proteinG: 9, carbsG: 80, fatG: 10),
      tags: ['lunch', 'dinner', 'staple', 'festive'],
    ),

    // --------------------------------------------
    // 8. RIZ SAUTÉ À LA VIANDE (Bifaga / Sauté de bœuf)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_rice_beef_saute',
      name: 'Riz sauté à la viande (Bifaga)',
      objective: MealObjective.highProtein,
      ingredientIds: [
        'cm_rice',
        'cm_beef',
        'cm_onion',
        'cm_tomato',
        'cm_carrot',
        'cm_palm_oil'
      ],
      ingredientNames: [
        'Rice',
        'Beef',
        'Onion',
        'Tomato',
        'Carrot',
        'Palm oil'
      ],
      baseMacros:
          MacroTargets(calories: 580, proteinG: 28, carbsG: 55, fatG: 24),
      minBudget: BudgetLevel.medium,
      tags: ['lunch', 'dinner', 'traditional'],
    ),

    // --------------------------------------------
    // 9. RIZ SAUCE TOMATE AVEC POISSON
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_rice_tomato_fish',
      name: 'Riz sauce tomate avec poisson',
      objective: MealObjective.highProtein,
      ingredientIds: [
        'cm_rice',
        'cm_fish',
        'cm_tomato',
        'cm_onion',
        'cm_palm_oil'
      ],
      ingredientNames: ['Rice', 'Fresh fish', 'Tomato', 'Onion', 'Palm oil'],
      baseMacros:
          MacroTargets(calories: 520, proteinG: 32, carbsG: 55, fatG: 16),
      minBudget: BudgetLevel.medium,
      allergens: ['fish'],
      tags: ['lunch', 'dinner', 'staple'],
    ),

    // --------------------------------------------
    // 10. RIZ SAUTÉ À L'ARACHIDE (Riz à la pâte d'arachide)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_rice_peanut_sauce',
      name: 'Riz sauté à l\'arachide',
      objective: MealObjective.highEnergy,
      ingredientIds: [
        'cm_rice',
        'cm_peanut_paste',
        'cm_tomato',
        'cm_onion',
        'cm_chicken'
      ],
      ingredientNames: ['Rice', 'Peanut paste', 'Tomato', 'Onion', 'Chicken'],
      baseMacros:
          MacroTargets(calories: 650, proteinG: 30, carbsG: 55, fatG: 32),
      minBudget: BudgetLevel.medium,
      allergens: ['peanut'],
      tags: ['lunch', 'dinner', 'traditional'],
    ),

    // --------------------------------------------
    // 11. SANGHA (Sangah)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_sangah',
      name: 'Sangah (Feuilles de manioc, maïs, huile de palme)',
      objective: MealObjective.highEnergy,
      ingredientIds: [
        'cm_cassava',
        'cm_maize_boiled',
        'cm_palm_oil',
        'cm_spinach'
      ],
      ingredientNames: ['Cassava', 'Maize', 'Palm oil', 'Spinach'],
      baseMacros:
          MacroTargets(calories: 400, proteinG: 8, carbsG: 45, fatG: 20),
      tags: ['traditional', 'dinner', 'vegetarian'],
    ),

    // --------------------------------------------
    // 12. MBONGO TCHOBI (Ragoût noir)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_mbongo_tchobi',
      name: 'Mbongo Tchobi (Ragoût noir aux épices)',
      objective: MealObjective.highProtein,
      ingredientIds: [
        'cm_beef',
        'cm_fish',
        'cm_onion',
        'cm_tomato',
        'cm_hot_pepper'
      ],
      ingredientNames: ['Beef', 'Fish', 'Onion', 'Tomato', 'Hot pepper'],
      baseMacros:
          MacroTargets(calories: 450, proteinG: 35, carbsG: 14, fatG: 28),
      minBudget: BudgetLevel.medium,
      allergens: ['fish'],
      tags: ['traditional', 'dinner', 'spicy'],
    ),

    // --------------------------------------------
    // 13. PÈPÈ SOUP (Soupe pimentée)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_pepe_soup',
      name: 'Pèpè Soup (Soupe pimentée au poisson/viande)',
      objective: MealObjective.recovery,
      ingredientIds: ['cm_fish', 'cm_onion', 'cm_hot_pepper', 'cm_tomato'],
      ingredientNames: ['Fish', 'Onion', 'Hot pepper', 'Tomato'],
      baseMacros:
          MacroTargets(calories: 280, proteinG: 28, carbsG: 9, fatG: 14),
      minBudget: BudgetLevel.low,
      allergens: ['fish'],
      tags: ['soup', 'dinner', 'spicy', 'recovery'],
    ),

    // --------------------------------------------
    // 14. KWEM (Purée de feuilles de manioc)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_kwem',
      name: 'Kwem (Purée de feuilles de manioc)',
      objective: MealObjective.light,
      ingredientIds: ['cm_cassava', 'cm_spinach', 'cm_palm_oil', 'cm_onion'],
      ingredientNames: ['Cassava', 'Spinach', 'Palm oil', 'Onion'],
      baseMacros:
          MacroTargets(calories: 350, proteinG: 12, carbsG: 30, fatG: 18),
      tags: ['traditional', 'vegetarian', 'dinner'],
    ),

    // --------------------------------------------
    // 15. SOYA (Brochettes)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_soya_brochettes',
      name: 'Soya (Brochettes de bœuf ou poulet)',
      objective: MealObjective.highProtein,
      ingredientIds: ['cm_beef', 'cm_onion', 'cm_hot_pepper'],
      ingredientNames: ['Beef', 'Onion', 'Hot pepper'],
      baseMacros:
          MacroTargets(calories: 320, proteinG: 30, carbsG: 5, fatG: 20),
      minBudget: BudgetLevel.medium,
      tags: ['street_food', 'snack', 'high_protein'],
    ),

    // --------------------------------------------
    // 16. POISSON BRAISÉ + PLANTAIN
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_grilled_fish_plantain',
      name: 'Poisson braisé avec plantain',
      objective: MealObjective.recovery,
      ingredientIds: [
        'cm_fish',
        'cm_plantain_boiled',
        'cm_onion',
        'cm_hot_pepper'
      ],
      ingredientNames: [
        'Grilled fish',
        'Boiled plantain',
        'Onion',
        'Hot pepper'
      ],
      baseMacros:
          MacroTargets(calories: 480, proteinG: 35, carbsG: 40, fatG: 14),
      allergens: ['fish'],
      tags: ['street_food', 'dinner', 'recovery'],
    ),

    // ============================================================
    // PLATS À BASE DE HARICOTS (Rice & Beans, etc.)
    // ============================================================

    // --------------------------------------------
    // 17. RIZ + HARICOTS (classique camerounais)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_rice_beans',
      name: 'Riz + Haricots (Rice and Beans)',
      objective: MealObjective.highEnergy,
      ingredientIds: [
        'cm_rice',
        'cm_beans',
        'cm_palm_oil',
        'cm_onion',
        'cm_hot_pepper'
      ],
      ingredientNames: ['Rice', 'Beans', 'Palm oil', 'Onion', 'Hot pepper'],
      baseMacros:
          MacroTargets(calories: 520, proteinG: 18, carbsG: 78, fatG: 12),
      tags: ['lunch', 'dinner', 'staple', 'vegetarian'],
    ),

    // --------------------------------------------
    // 18. HARICOTS + IGNANE
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_beans_yam',
      name: 'Haricots + Igname (Beans and Yam)',
      objective: MealObjective.highEnergy,
      ingredientIds: ['cm_beans', 'cm_yam', 'cm_palm_oil', 'cm_onion'],
      ingredientNames: ['Beans', 'Yam', 'Palm oil', 'Onion'],
      baseMacros:
          MacroTargets(calories: 540, proteinG: 19, carbsG: 85, fatG: 10),
      tags: ['lunch', 'dinner', 'staple', 'vegetarian'],
    ),

    // --------------------------------------------
    // 19. HARICOTS + MACARONI (pâtes)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_beans_macaroni',
      name: 'Haricots + Macaroni (Beans and Pasta)',
      objective: MealObjective.highEnergy,
      ingredientIds: [
        'cm_beans',
        'cm_rice',
        'cm_palm_oil',
        'cm_onion',
        'cm_tomato'
      ],
      ingredientNames: ['Beans', 'Pasta', 'Palm oil', 'Onion', 'Tomato'],
      baseMacros:
          MacroTargets(calories: 500, proteinG: 17, carbsG: 80, fatG: 10),
      tags: ['lunch', 'dinner', 'staple', 'vegetarian'],
    ),

    // --------------------------------------------
    // 20. HARICOT SAUCE TOMATE AVEC VIANDE
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_beans_tomato_beef',
      name: 'Haricot sauce tomate avec viande (Beans stew with beef)',
      objective: MealObjective.highProtein,
      ingredientIds: [
        'cm_beans',
        'cm_beef',
        'cm_tomato',
        'cm_onion',
        'cm_palm_oil'
      ],
      ingredientNames: ['Beans', 'Beef', 'Tomato', 'Onion', 'Palm oil'],
      baseMacros:
          MacroTargets(calories: 580, proteinG: 32, carbsG: 45, fatG: 26),
      minBudget: BudgetLevel.medium,
      tags: ['lunch', 'dinner', 'traditional'],
    ),

    // --------------------------------------------
    // 21. HARICOT SAUCE TOMATE AVEC POISSON
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_beans_tomato_fish',
      name: 'Haricot sauce tomate avec poisson (Beans stew with fish)',
      objective: MealObjective.highProtein,
      ingredientIds: [
        'cm_beans',
        'cm_fish',
        'cm_tomato',
        'cm_onion',
        'cm_palm_oil'
      ],
      ingredientNames: ['Beans', 'Fish', 'Tomato', 'Onion', 'Palm oil'],
      baseMacros:
          MacroTargets(calories: 520, proteinG: 33, carbsG: 40, fatG: 18),
      minBudget: BudgetLevel.medium,
      allergens: ['fish'],
      tags: ['lunch', 'dinner', 'traditional'],
    ),

    // --------------------------------------------
    // 22. HARICOTS + FARINE DE MAÏS (Bouillie / Pâte)
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_beans_corn_meal',
      name: 'Haricots + Farine de maïs (Beans with corn meal)',
      objective: MealObjective.highEnergy,
      ingredientIds: ['cm_beans', 'cm_corn_flour', 'cm_palm_oil', 'cm_onion'],
      ingredientNames: ['Beans', 'Corn flour', 'Palm oil', 'Onion'],
      baseMacros:
          MacroTargets(calories: 500, proteinG: 18, carbsG: 75, fatG: 12),
      tags: ['lunch', 'dinner', 'staple', 'vegetarian'],
    ),

    // --------------------------------------------
    // 23. HARICOTS + FUFU
    // --------------------------------------------
    MealTemplate(
      id: 'cm_meal_beans_fufu',
      name: 'Haricots + Fufu (Beans with fufu)',
      objective: MealObjective.highEnergy,
      ingredientIds: ['cm_beans', 'cm_fufu', 'cm_palm_oil', 'cm_onion'],
      ingredientNames: ['Beans', 'Fufu', 'Palm oil', 'Onion'],
      baseMacros:
          MacroTargets(calories: 540, proteinG: 17, carbsG: 80, fatG: 10),
      tags: ['lunch', 'dinner', 'staple', 'vegetarian'],
    ),
  ];
}
