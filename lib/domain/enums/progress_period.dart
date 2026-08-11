/// Time window used when computing progress metrics.
enum ProgressPeriod {
  daily,
  weekly,
  monthly,
}

extension ProgressPeriodExtension on ProgressPeriod {
  String get displayName {
    switch (this) {
      case ProgressPeriod.daily:
        return 'Daily';
      case ProgressPeriod.weekly:
        return 'Weekly';
      case ProgressPeriod.monthly:
        return 'Monthly';
    }
  }

  String get value {
    switch (this) {
      case ProgressPeriod.daily:
        return 'daily';
      case ProgressPeriod.weekly:
        return 'weekly';
      case ProgressPeriod.monthly:
        return 'monthly';
    }
  }

  static ProgressPeriod fromValue(String value) {
    return ProgressPeriod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProgressPeriod.weekly,
    );
  }

  /// Default lookback duration for this period.
  Duration get lookback {
    switch (this) {
      case ProgressPeriod.daily:
        return const Duration(days: 7);
      case ProgressPeriod.weekly:
        return const Duration(days: 28);
      case ProgressPeriod.monthly:
        return const Duration(days: 90);
    }
  }
}
