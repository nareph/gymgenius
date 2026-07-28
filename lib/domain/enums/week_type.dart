enum WeekType {
  normal,
  deload,
  peak,
  test,
}

extension WeekTypeExtension on WeekType {
  String get displayName {
    switch (this) {
      case WeekType.normal:
        return 'Normal Training';
      case WeekType.deload:
        return 'Deload Week';
      case WeekType.peak:
        return 'Peak Week';
      case WeekType.test:
        return 'Test Week';
    }
  }

  String get value {
    switch (this) {
      case WeekType.normal:
        return 'normal';
      case WeekType.deload:
        return 'deload';
      case WeekType.peak:
        return 'peak';
      case WeekType.test:
        return 'test';
    }
  }

  static WeekType fromValue(String value) {
    return WeekType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WeekType.normal,
    );
  }
}
