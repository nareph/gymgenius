// lib/domain/entities/nutrition_profile.dart

import 'package:gymgenius/domain/value_objects/macro_targets.dart';

/// Domain Entity representing the user's current nutrition profile.
class NutritionProfile {
  final String userId;
  final DateTime date;
  final MacroTargets targets;
  final String country;
  final List<String> preferredFoods;
  final List<String> restrictedFoods;

  const NutritionProfile({
    required this.userId,
    required this.date,
    required this.targets,
    required this.country,
    required this.preferredFoods,
    required this.restrictedFoods,
  });

  @override
  String toString() => 'NutritionProfile($date, ${targets.calories} kcal)';
}
