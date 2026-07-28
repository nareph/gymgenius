// lib/domain/enums/activity_level.dart

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extraActive,
}

extension ActivityLevelExtension on ActivityLevel {
  String get displayName {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary (desk job, little exercise)';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active (1-2 days/week)';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active (3-4 days/week)';
      case ActivityLevel.veryActive:
        return 'Very Active (5-6 days/week)';
      case ActivityLevel.extraActive:
        return 'Extra Active (athlete, manual labor)';
    }
  }

  String get value {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'sedentary';
      case ActivityLevel.lightlyActive:
        return 'lightly_active';
      case ActivityLevel.moderatelyActive:
        return 'moderately_active';
      case ActivityLevel.veryActive:
        return 'very_active';
      case ActivityLevel.extraActive:
        return 'extra_active';
    }
  }

  static ActivityLevel fromValue(String value) {
    return ActivityLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ActivityLevel.moderatelyActive,
    );
  }
}
