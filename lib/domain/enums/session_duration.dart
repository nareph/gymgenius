// lib/domain/enums/session_duration.dart

enum SessionDuration {
  short30,
  medium45,
  standard60,
  long75,
  veryLong90,
}

extension SessionDurationExtension on SessionDuration {
  String get displayName {
    switch (this) {
      case SessionDuration.short30:
        return '30 minutes or less';
      case SessionDuration.medium45:
        return 'Around 45 minutes';
      case SessionDuration.standard60:
        return 'Around 60 minutes';
      case SessionDuration.long75:
        return '75-90 minutes';
      case SessionDuration.veryLong90:
        return 'More than 90 minutes';
    }
  }

  String get value {
    switch (this) {
      case SessionDuration.short30:
        return 'short_30_max';
      case SessionDuration.medium45:
        return 'medium_45';
      case SessionDuration.standard60:
        return 'standard_60';
      case SessionDuration.long75:
        return 'long_75_90';
      case SessionDuration.veryLong90:
        return 'very_long_90_plus';
    }
  }

  static SessionDuration fromValue(String value) {
    return SessionDuration.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SessionDuration.standard60,
    );
  }

  int get minutes {
    switch (this) {
      case SessionDuration.short30:
        return 30;
      case SessionDuration.medium45:
        return 45;
      case SessionDuration.standard60:
        return 60;
      case SessionDuration.long75:
        return 75;
      case SessionDuration.veryLong90:
        return 90;
    }
  }
}
