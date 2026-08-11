enum MealType {
  breakfast,
  lunch,
  snack,
  preWorkout,
  postWorkout,
  dinner,
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.snack:
        return 'Snack';
      case MealType.preWorkout:
        return 'Pre-workout';
      case MealType.postWorkout:
        return 'Post-workout';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  String get value {
    switch (this) {
      case MealType.breakfast:
        return 'breakfast';
      case MealType.lunch:
        return 'lunch';
      case MealType.snack:
        return 'snack';
      case MealType.preWorkout:
        return 'pre_workout';
      case MealType.postWorkout:
        return 'post_workout';
      case MealType.dinner:
        return 'dinner';
    }
  }

  static MealType fromValue(String value) {
    return MealType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MealType.snack,
    );
  }
}
