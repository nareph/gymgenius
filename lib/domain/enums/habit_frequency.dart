enum HabitFrequency {
  daily,
  weekly,
}

extension HabitFrequencyExtension on HabitFrequency {
  String get displayName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
    }
  }

  String get value {
    switch (this) {
      case HabitFrequency.daily:
        return 'daily';
      case HabitFrequency.weekly:
        return 'weekly';
    }
  }

  static HabitFrequency fromValue(String value) {
    return HabitFrequency.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HabitFrequency.daily,
    );
  }
}
