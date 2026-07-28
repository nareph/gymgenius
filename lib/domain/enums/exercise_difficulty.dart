enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced,
}

extension ExerciseDifficultyExtension on ExerciseDifficulty {
  String get displayName {
    switch (this) {
      case ExerciseDifficulty.beginner:
        return 'Beginner';
      case ExerciseDifficulty.intermediate:
        return 'Intermediate';
      case ExerciseDifficulty.advanced:
        return 'Advanced';
    }
  }

  String get value {
    switch (this) {
      case ExerciseDifficulty.beginner:
        return 'beginner';
      case ExerciseDifficulty.intermediate:
        return 'intermediate';
      case ExerciseDifficulty.advanced:
        return 'advanced';
    }
  }

  static ExerciseDifficulty fromValue(String value) {
    return ExerciseDifficulty.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExerciseDifficulty.beginner,
    );
  }
}
