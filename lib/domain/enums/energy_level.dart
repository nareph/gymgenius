enum EnergyLevel {
  veryLow,
  low,
  moderate,
  high,
  veryHigh,
}

extension EnergyLevelExtension on EnergyLevel {
  String get displayName {
    switch (this) {
      case EnergyLevel.veryLow:
        return 'Very Low';
      case EnergyLevel.low:
        return 'Low';
      case EnergyLevel.moderate:
        return 'Moderate';
      case EnergyLevel.high:
        return 'High';
      case EnergyLevel.veryHigh:
        return 'Very High';
    }
  }

  String get value {
    switch (this) {
      case EnergyLevel.veryLow:
        return 'very_low';
      case EnergyLevel.low:
        return 'low';
      case EnergyLevel.moderate:
        return 'moderate';
      case EnergyLevel.high:
        return 'high';
      case EnergyLevel.veryHigh:
        return 'very_high';
    }
  }

  static EnergyLevel fromValue(String value) {
    return EnergyLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EnergyLevel.moderate,
    );
  }
}
