enum NutritionStatus {
  onTarget,
  surplus,
  deficit,
  recoverySupport,
  trainingDayBoost,
}

extension NutritionStatusExtension on NutritionStatus {
  String get displayName {
    switch (this) {
      case NutritionStatus.onTarget:
        return 'On target';
      case NutritionStatus.surplus:
        return 'Calorie surplus';
      case NutritionStatus.deficit:
        return 'Calorie deficit';
      case NutritionStatus.recoverySupport:
        return 'Recovery support';
      case NutritionStatus.trainingDayBoost:
        return 'Training day boost';
    }
  }

  String get value {
    switch (this) {
      case NutritionStatus.onTarget:
        return 'on_target';
      case NutritionStatus.surplus:
        return 'surplus';
      case NutritionStatus.deficit:
        return 'deficit';
      case NutritionStatus.recoverySupport:
        return 'recovery_support';
      case NutritionStatus.trainingDayBoost:
        return 'training_day_boost';
    }
  }

  static NutritionStatus fromValue(String value) {
    return NutritionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NutritionStatus.onTarget,
    );
  }
}
