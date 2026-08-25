import 'package:gymgenius/domain/enums/budget_level.dart';
import 'package:gymgenius/domain/enums/meal_objective.dart';
import 'package:gymgenius/domain/value_objects/macro_targets.dart';
import '../../../models/meal_template.dart';

const List<MealTemplate> cameroonRiceAndGrainDishes = [
  MealTemplate(
    id: 'cm_meal_rice_chicken',
    name: 'Rice and grilled chicken with vegetables',
    objective: MealObjective.highProtein,
    ingredientIds: ['cm_rice', 'cm_chicken', 'cm_tomato', 'cm_cabbage'],
    ingredientNames: ['White rice', 'Grilled chicken', 'Tomato', 'Cabbage'],
    baseMacros: MacroTargets(calories: 620, proteinG: 45, carbsG: 60, fatG: 12),
    minBudget: BudgetLevel.medium,
    tags: ['lunch', 'dinner'],
  ),
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
    baseMacros: MacroTargets(calories: 450, proteinG: 9, carbsG: 80, fatG: 10),
    tags: ['lunch', 'dinner', 'staple', 'festive'],
  ),
  MealTemplate(
    id: 'cm_meal_bifaga',
    name: 'Bifaga (Rice sautéed with smoked fish & morue)',
    objective: MealObjective.highProtein,
    ingredientIds: [
      'cm_rice',
      'cm_smoked_fish',
      'cm_morue',
      'cm_onion',
      'cm_tomato',
      'cm_palm_oil'
    ],
    ingredientNames: [
      'Rice',
      'Smoked fish',
      'Morue',
      'Onion',
      'Tomato',
      'Palm oil'
    ],
    baseMacros: MacroTargets(calories: 520, proteinG: 34, carbsG: 55, fatG: 17),
    minBudget: BudgetLevel.medium,
    allergens: ['fish'],
    tags: ['lunch', 'dinner', 'traditional'],
  ),
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
    baseMacros: MacroTargets(calories: 520, proteinG: 32, carbsG: 55, fatG: 16),
    minBudget: BudgetLevel.medium,
    allergens: ['fish'],
    tags: ['lunch', 'dinner', 'staple'],
  ),
  MealTemplate(
    id: 'cm_meal_rice_peanut_sauce',
    name: 'White rice with peanut sauce (Riz sauce arachide)',
    objective: MealObjective.highEnergy,
    ingredientIds: [
      'cm_rice',
      'cm_peanut_paste',
      'cm_tomato',
      'cm_onion',
      'cm_chicken'
    ],
    ingredientNames: ['Rice', 'Peanut paste', 'Tomato', 'Onion', 'Chicken'],
    baseMacros: MacroTargets(calories: 650, proteinG: 30, carbsG: 55, fatG: 32),
    minBudget: BudgetLevel.medium,
    allergens: ['peanut'],
    tags: ['lunch', 'dinner', 'traditional'],
  ),
  MealTemplate(
    id: 'cm_meal_corn_chaff',
    name: 'Corn Chaff (maize and beans)',
    objective: MealObjective.highEnergy,
    ingredientIds: [
      'cm_maize_boiled',
      'cm_beans',
      'cm_palm_oil',
      'cm_onion',
      'cm_hot_pepper'
    ],
    ingredientNames: [
      'Boiled corn',
      'Beans',
      'Palm oil',
      'Onion',
      'Hot pepper'
    ],
    baseMacros: MacroTargets(calories: 520, proteinG: 20, carbsG: 65, fatG: 18),
    tags: ['street_food', 'lunch', 'dinner', 'staple'],
  ),
];
