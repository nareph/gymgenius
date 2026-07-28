// lib/domain/repositories/nutrition_repository.dart

import 'package:gymgenius/domain/entities/nutrition_profile.dart';

/// Contract for nutrition persistence operations.
abstract interface class NutritionRepository {
  Future<NutritionProfile?> getCurrentNutritionProfile(String userId);
  Future<void> saveNutritionProfile(NutritionProfile profile);
  Future<void> deleteNutritionProfile(String userId);
}
