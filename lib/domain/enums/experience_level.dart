// lib/domain/enums/experience_level.dart

enum ExperienceLevel {
  beginner,
  intermediate,
  advanced,
}

extension ExperienceLevelExtension on ExperienceLevel {
  String get displayName {
    switch (this) {
      case ExperienceLevel.beginner:
        return 'Beginner (0–6 months)';
      case ExperienceLevel.intermediate:
        return 'Intermediate (6 months – 2 years)';
      case ExperienceLevel.advanced:
        return 'Advanced (2+ years)';
    }
  }

  String get value {
    switch (this) {
      case ExperienceLevel.beginner:
        return 'beginner';
      case ExperienceLevel.intermediate:
        return 'intermediate';
      case ExperienceLevel.advanced:
        return 'advanced';
    }
  }

  static ExperienceLevel fromValue(String value) {
    return ExperienceLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExperienceLevel.beginner,
    );
  }
}
