enum HydrationLevel {
  poor,
  fair,
  good,
  excellent,
}

extension HydrationLevelExtension on HydrationLevel {
  String get displayName {
    switch (this) {
      case HydrationLevel.poor:
        return 'Poor';
      case HydrationLevel.fair:
        return 'Fair';
      case HydrationLevel.good:
        return 'Good';
      case HydrationLevel.excellent:
        return 'Excellent';
    }
  }

  String get value {
    switch (this) {
      case HydrationLevel.poor:
        return 'poor';
      case HydrationLevel.fair:
        return 'fair';
      case HydrationLevel.good:
        return 'good';
      case HydrationLevel.excellent:
        return 'excellent';
    }
  }

  static HydrationLevel fromValue(String value) {
    return HydrationLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HydrationLevel.good,
    );
  }
}
