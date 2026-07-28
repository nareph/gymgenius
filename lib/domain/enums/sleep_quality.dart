enum SleepQuality {
  poor,
  fair,
  good,
  excellent,
}

extension SleepQualityExtension on SleepQuality {
  String get displayName {
    switch (this) {
      case SleepQuality.poor:
        return 'Poor';
      case SleepQuality.fair:
        return 'Fair';
      case SleepQuality.good:
        return 'Good';
      case SleepQuality.excellent:
        return 'Excellent';
    }
  }

  String get value {
    switch (this) {
      case SleepQuality.poor:
        return 'poor';
      case SleepQuality.fair:
        return 'fair';
      case SleepQuality.good:
        return 'good';
      case SleepQuality.excellent:
        return 'excellent';
    }
  }

  static SleepQuality fromValue(String value) {
    return SleepQuality.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SleepQuality.good,
    );
  }
}
