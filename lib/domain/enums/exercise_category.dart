enum ExerciseCategory {
  compound,
  isolation,
  cardio,
  mobility,
}

extension ExerciseCategoryExtension on ExerciseCategory {
  String get displayName {
    switch (this) {
      case ExerciseCategory.compound:
        return 'Compound';
      case ExerciseCategory.isolation:
        return 'Isolation';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.mobility:
        return 'Mobility';
    }
  }

  String get value {
    switch (this) {
      case ExerciseCategory.compound:
        return 'compound';
      case ExerciseCategory.isolation:
        return 'isolation';
      case ExerciseCategory.cardio:
        return 'cardio';
      case ExerciseCategory.mobility:
        return 'mobility';
    }
  }

  static ExerciseCategory fromValue(String value) {
    return ExerciseCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExerciseCategory.compound,
    );
  }
}
