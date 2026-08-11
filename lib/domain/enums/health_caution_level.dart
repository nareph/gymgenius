enum HealthCautionLevel {
  none,
  info,
  caution,
  urgent,
}

extension HealthCautionLevelExtension on HealthCautionLevel {
  String get displayName {
    switch (this) {
      case HealthCautionLevel.none:
        return 'None';
      case HealthCautionLevel.info:
        return 'Info';
      case HealthCautionLevel.caution:
        return 'Caution';
      case HealthCautionLevel.urgent:
        return 'Urgent';
    }
  }

  String get value {
    switch (this) {
      case HealthCautionLevel.none:
        return 'none';
      case HealthCautionLevel.info:
        return 'info';
      case HealthCautionLevel.caution:
        return 'caution';
      case HealthCautionLevel.urgent:
        return 'urgent';
    }
  }

  static HealthCautionLevel fromValue(String value) {
    return HealthCautionLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HealthCautionLevel.none,
    );
  }
}
