enum StressLevel {
  veryLow,
  low,
  moderate,
  high,
  veryHigh,
}

extension StressLevelExtension on StressLevel {
  String get displayName {
    switch (this) {
      case StressLevel.veryLow:
        return 'Very Low';
      case StressLevel.low:
        return 'Low';
      case StressLevel.moderate:
        return 'Moderate';
      case StressLevel.high:
        return 'High';
      case StressLevel.veryHigh:
        return 'Very High';
    }
  }

  String get value {
    switch (this) {
      case StressLevel.veryLow:
        return 'very_low';
      case StressLevel.low:
        return 'low';
      case StressLevel.moderate:
        return 'moderate';
      case StressLevel.high:
        return 'high';
      case StressLevel.veryHigh:
        return 'very_high';
    }
  }

  static StressLevel fromValue(String value) {
    return StressLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StressLevel.moderate,
    );
  }
}
