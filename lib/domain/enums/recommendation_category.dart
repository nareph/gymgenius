enum RecommendationCategory {
  workout,
  nutrition,
  recovery,
  lifestyle,
  motivation,
}

extension RecommendationCategoryExtension on RecommendationCategory {
  String get displayName {
    switch (this) {
      case RecommendationCategory.workout:
        return 'Workout';
      case RecommendationCategory.nutrition:
        return 'Nutrition';
      case RecommendationCategory.recovery:
        return 'Recovery';
      case RecommendationCategory.lifestyle:
        return 'Lifestyle';
      case RecommendationCategory.motivation:
        return 'Motivation';
    }
  }

  String get value {
    switch (this) {
      case RecommendationCategory.workout:
        return 'workout';
      case RecommendationCategory.nutrition:
        return 'nutrition';
      case RecommendationCategory.recovery:
        return 'recovery';
      case RecommendationCategory.lifestyle:
        return 'lifestyle';
      case RecommendationCategory.motivation:
        return 'motivation';
    }
  }

  static RecommendationCategory fromValue(String value) {
    return RecommendationCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RecommendationCategory.workout,
    );
  }
}
