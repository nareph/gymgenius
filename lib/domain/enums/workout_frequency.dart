enum WorkoutFrequency {
  oneToTwo,
  threeToFour,
  fivePlus,
}

extension WorkoutFrequencyExtension on WorkoutFrequency {
  String get displayName {
    switch (this) {
      case WorkoutFrequency.oneToTwo:
        return '1-2 days / week';
      case WorkoutFrequency.threeToFour:
        return '3-4 days / week';
      case WorkoutFrequency.fivePlus:
        return '5+ days / week';
    }
  }

  String get value {
    switch (this) {
      case WorkoutFrequency.oneToTwo:
        return '1-2';
      case WorkoutFrequency.threeToFour:
        return '3-4';
      case WorkoutFrequency.fivePlus:
        return '5-plus';
    }
  }

  static WorkoutFrequency fromValue(String value) {
    return WorkoutFrequency.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WorkoutFrequency.threeToFour,
    );
  }

  int toDays() {
    switch (this) {
      case WorkoutFrequency.oneToTwo:
        return 2;
      case WorkoutFrequency.threeToFour:
        return 4;
      case WorkoutFrequency.fivePlus:
        return 5;
    }
  }
}
