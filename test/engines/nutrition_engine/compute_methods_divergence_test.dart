import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/engines/nutrition_engine/nutrition_engine.dart';

import 'calorie_macro_test.dart';

void main() {
  group('NutritionEngine computeDailyPlan divergence', () {
    test('computeDailyPlan(persist:false) matches computeDailyPlanSync', () async {
      final engine = NutritionEngine();
      final profile = buildTestProfile();
      final date = DateTime(2026, 8, 11);

      final syncPlan = engine.computeDailyPlanSync(
        profile: profile,
        isTrainingDay: true,
        date: date,
      );

      final asyncPlan = await engine.computeDailyPlan(
        profile: profile,
        isTrainingDay: true,
        date: date,
        persist: false,
      );

      expect(asyncPlan.dailyCalories, syncPlan.dailyCalories);
      expect(asyncPlan.proteinG, syncPlan.proteinG);
      expect(asyncPlan.carbsG, syncPlan.carbsG);
      expect(asyncPlan.fatG, syncPlan.fatG);
      expect(asyncPlan.mealCount, syncPlan.mealCount);
      expect(asyncPlan.meals.first.name, syncPlan.meals.first.name);
      expect(asyncPlan.reasons, syncPlan.reasons);
    });
  });
}

