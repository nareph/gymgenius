import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:gymgenius/data/datasources/local/hive/boxes/hive_boxes.dart';
import 'package:gymgenius/data/datasources/local/hive/models/meal_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/nutrition_plan_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/nutrition_profile_hive_model.dart';
import 'package:gymgenius/data/repositories/nutrition_repository_impl.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/engines/nutrition_engine/nutrition_engine.dart';

import 'calorie_macro_test.dart';

void main() {
  group('Nutrition persistence', () {
    test('savePlan then read back returns the same targets/meals', () async {
      final tmpDir = await Directory.systemTemp.createTemp(
        'gymgenius_nutrition_test_',
      );

      Hive.init(tmpDir.path);

      Hive.registerAdapter(NutritionProfileHiveModelAdapter());
      Hive.registerAdapter(MealHiveModelAdapter());
      Hive.registerAdapter(NutritionPlanHiveModelAdapter());

      await Hive.openBox<NutritionProfileHiveModel>(HiveBoxes.nutritionProfiles);
      await Hive.openBox<NutritionPlanHiveModel>(HiveBoxes.nutritionPlans);

      final repo = NutritionRepositoryImpl();
      final engine = NutritionEngine(nutritionRepository: repo);

      final profile = buildTestProfile();
      final date = DateTime(2026, 8, 11);

      final plan = engine.computeDailyPlanSync(
        profile: profile,
        isTrainingDay: true,
        date: date,
      );

      await repo.savePlan(plan);

      final reloaded = await repo.getPlanForDate(profile.userId, date);
      expect(reloaded, isNotNull);
      expect(reloaded!.dailyCalories, plan.dailyCalories);
      expect(reloaded.mealCount, plan.mealCount);
      expect(reloaded.country, plan.country);

      await Hive.close();
      await tmpDir.delete(recursive: true);
    });
  });
}

