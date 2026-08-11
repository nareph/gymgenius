// lib/domain/repositories/nutrition_repository.dart

import 'package:gymgenius/domain/entities/nutrition_plan.dart';
import 'package:gymgenius/domain/entities/nutrition_profile.dart';

/// Contract for nutrition persistence operations.
abstract interface class NutritionRepository {
  Future<NutritionProfile?> getCurrentNutritionProfile(String userId);
  Future<void> saveNutritionProfile(NutritionProfile profile);
  Future<void> deleteNutritionProfile(String userId);

  Future<NutritionPlan?> getPlanForDate(String userId, DateTime date);
  Future<void> savePlan(NutritionPlan plan);
  Future<void> deletePlansForUser(String userId);
}
