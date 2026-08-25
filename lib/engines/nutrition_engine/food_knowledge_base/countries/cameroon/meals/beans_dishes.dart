import 'package:gymgenius/domain/enums/budget_level.dart';
import 'package:gymgenius/domain/enums/meal_objective.dart';
import 'package:gymgenius/domain/value_objects/macro_targets.dart';
import '../../../models/meal_template.dart';

const List<MealTemplate> cameroonBeansDishes = [
  MealTemplate(
    id: 'cm_meal_beans_plantain',
    name: 'Beans and plantain',
    objective: MealObjective.highEnergy,
    ingredientIds: ['cm_beans', 'cm_plantain_boiled'],
    ingredientNames: ['Beans', 'Boiled plantain'],
    baseMacros: MacroTargets(calories: 550, proteinG: 20, carbsG: 95, fatG: 4),
    tags: ['lunch', 'dinner', 'staple'],
  ),
  MealTemplate(
    id: 'cm_meal_beans_avocado',
    name: 'Beans with avocado',
    objective: MealObjective.recovery,
    ingredientIds: ['cm_beans', 'cm_avocado', 'cm_tomato'],
    ingredientNames: ['Beans', 'Avocado', 'Tomato'],
    baseMacros: MacroTargets(calories: 420, proteinG: 18, carbsG: 40, fatG: 18),
    tags: ['lunch', 'recovery'],
  ),
  MealTemplate(
    id: 'cm_meal_koki',
    name: 'Koki with boiled plantain',
    objective: MealObjective.highEnergy,
    ingredientIds: ['cm_koki_beans', 'cm_palm_oil', 'cm_plantain_boiled'],
    ingredientNames: ['Black-eyed peas', 'Palm oil', 'Plantain'],
    baseMacros: MacroTargets(calories: 580, proteinG: 18, carbsG: 70, fatG: 22),
    tags: ['traditional', 'lunch'],
  ),
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
    baseMacros: MacroTargets(calories: 520, proteinG: 18, carbsG: 78, fatG: 12),
    tags: ['lunch', 'dinner', 'staple', 'vegetarian'],
  ),
  MealTemplate(
    id: 'cm_meal_beans_yam',
    name: 'Haricots + Igname (Beans and Yam)',
    objective: MealObjective.highEnergy,
    ingredientIds: ['cm_beans', 'cm_yam', 'cm_palm_oil', 'cm_onion'],
    ingredientNames: ['Beans', 'Yam', 'Palm oil', 'Onion'],
    baseMacros: MacroTargets(calories: 540, proteinG: 19, carbsG: 85, fatG: 10),
    tags: ['lunch', 'dinner', 'staple', 'vegetarian'],
  ),
  MealTemplate(
    id: 'cm_meal_beans_macaroni',
    name: 'Haricots + Macaroni (Beans and Pasta)',
    objective: MealObjective.highEnergy,
    ingredientIds: [
      'cm_beans',
      'cm_macaroni',
      'cm_palm_oil',
      'cm_onion',
      'cm_tomato'
    ],
    ingredientNames: ['Beans', 'Pasta', 'Palm oil', 'Onion', 'Tomato'],
    baseMacros: MacroTargets(calories: 500, proteinG: 17, carbsG: 80, fatG: 10),
    tags: ['lunch', 'dinner', 'staple', 'vegetarian'],
  ),
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
    baseMacros: MacroTargets(calories: 580, proteinG: 32, carbsG: 45, fatG: 26),
    minBudget: BudgetLevel.medium,
    tags: ['lunch', 'dinner', 'traditional'],
  ),
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
    baseMacros: MacroTargets(calories: 520, proteinG: 33, carbsG: 40, fatG: 18),
    minBudget: BudgetLevel.medium,
    allergens: ['fish'],
    tags: ['lunch', 'dinner', 'traditional'],
  ),
  MealTemplate(
    id: 'cm_meal_beans_corn_meal',
    name: 'Haricots + Farine de maïs (Beans with corn meal)',
    objective: MealObjective.highEnergy,
    ingredientIds: ['cm_beans', 'cm_corn_flour', 'cm_palm_oil', 'cm_onion'],
    ingredientNames: ['Beans', 'Corn flour', 'Palm oil', 'Onion'],
    baseMacros: MacroTargets(calories: 500, proteinG: 18, carbsG: 75, fatG: 12),
    tags: ['lunch', 'dinner', 'staple', 'vegetarian'],
  ),
  MealTemplate(
    id: 'cm_meal_beans_fufu',
    name: 'Haricots + Fufu (Beans with fufu)',
    objective: MealObjective.highEnergy,
    ingredientIds: ['cm_beans', 'cm_fufu', 'cm_palm_oil', 'cm_onion'],
    ingredientNames: ['Beans', 'Fufu', 'Palm oil', 'Onion'],
    baseMacros: MacroTargets(calories: 540, proteinG: 17, carbsG: 80, fatG: 10),
    tags: ['lunch', 'dinner', 'staple', 'vegetarian'],
  ),
];
