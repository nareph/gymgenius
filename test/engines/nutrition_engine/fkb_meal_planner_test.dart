import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/enums/budget_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/meal_type.dart';
import 'package:gymgenius/domain/value_objects/macro_targets.dart';
import 'package:gymgenius/engines/nutrition_engine/food_knowledge_base/food_knowledge_base.dart';
import 'package:gymgenius/engines/nutrition_engine/planners/meal_planner.dart';

import 'calorie_macro_test.dart';

void main() {
  group('FoodKnowledgeBase', () {
    const fkb = FoodKnowledgeBase();

    test('falls back unknown country to Cameroon', () {
      expect(fkb.resolvedCountry('France'), 'Cameroon');
      expect(fkb.resolvedCountry('Cameroun'), 'Cameroon');
      expect(fkb.foodsForCountry('Nigeria'), isNotEmpty);
    });

    test('filters peanut-restricted meals', () {
      final filtered = fkb.filterTemplates(
        country: 'Cameroon',
        budget: BudgetLevel.high,
        restrictions: const ['peanut'],
      );
      expect(filtered, isNotEmpty);
      expect(
        filtered.every((m) => !m.allergens.contains('peanut')),
        isTrue,
      );
    });

    test('low budget excludes medium-budget meals', () {
      final low = fkb.filterTemplates(
        country: 'Cameroon',
        budget: BudgetLevel.low,
      );
      final high = fkb.filterTemplates(
        country: 'Cameroon',
        budget: BudgetLevel.high,
      );
      expect(low.length, lessThan(high.length));
      expect(
        low.every((m) => m.minBudget == BudgetLevel.low),
        isTrue,
      );
    });
  });

  group('MealPlanner', () {
    const planner = MealPlanner();

    test('training day includes pre/post workout slots when evening training', () {
      final profile = buildTestProfile(goal: FitnessGoal.buildMuscle);
      final withTrainingTime = profile.copyWith(
        lifestyle: profile.lifestyle.copyWith(trainingTime: 18),
      );
      final meals = planner.plan(
        profile: withTrainingTime,
        targets: const MacroTargets(
          calories: 2800,
          proteinG: 160,
          carbsG: 320,
          fatG: 80,
          waterMl: 3000,
        ),
        isTrainingDay: true,
      );

      expect(meals.length, greaterThanOrEqualTo(4));
      expect(meals.any((m) => m.type == MealType.preWorkout), isTrue);
      expect(meals.any((m) => m.type == MealType.postWorkout), isTrue);
      expect(meals.every((m) => m.ingredients.isNotEmpty), isTrue);
    });

    test('rest day has four standard meals without workout slots', () {
      final profile = buildTestProfile();
      final meals = planner.plan(
        profile: profile,
        targets: const MacroTargets(
          calories: 2400,
          proteinG: 140,
          carbsG: 280,
          fatG: 70,
          waterMl: 2800,
        ),
        isTrainingDay: false,
      );

      expect(meals.length, 4);
      expect(meals.any((m) => m.type == MealType.preWorkout), isFalse);
      expect(meals.map((m) => m.type).toSet().length, meals.length);
    });

    test('respects fish restriction', () {
      final profile = buildTestProfile(restrictions: const ['fish']);
      final meals = planner.plan(
        profile: profile,
        targets: const MacroTargets(
          calories: 2500,
          proteinG: 150,
          carbsG: 300,
          fatG: 70,
        ),
        isTrainingDay: true,
      );

      for (final meal in meals) {
        final blob = meal.ingredients.join(' ').toLowerCase();
        expect(blob.contains('fish'), isFalse);
        expect(blob.contains('sardine'), isFalse);
      }
    });
  });
}
