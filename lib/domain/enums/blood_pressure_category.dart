enum BloodPressureCategory {
  low,
  normal,
  elevated,
  highStage1,
  highStage2,
  crisis,
  unknown,
}

extension BloodPressureCategoryExtension on BloodPressureCategory {
  String get displayName {
    switch (this) {
      case BloodPressureCategory.low:
        return 'Low';
      case BloodPressureCategory.normal:
        return 'Normal';
      case BloodPressureCategory.elevated:
        return 'Elevated';
      case BloodPressureCategory.highStage1:
        return 'High (stage 1)';
      case BloodPressureCategory.highStage2:
        return 'High (stage 2)';
      case BloodPressureCategory.crisis:
        return 'Very high — seek care';
      case BloodPressureCategory.unknown:
        return 'Unknown';
    }
  }

  String get value {
    switch (this) {
      case BloodPressureCategory.low:
        return 'low';
      case BloodPressureCategory.normal:
        return 'normal';
      case BloodPressureCategory.elevated:
        return 'elevated';
      case BloodPressureCategory.highStage1:
        return 'high_stage_1';
      case BloodPressureCategory.highStage2:
        return 'high_stage_2';
      case BloodPressureCategory.crisis:
        return 'crisis';
      case BloodPressureCategory.unknown:
        return 'unknown';
    }
  }

  bool get requiresCaution =>
      this == BloodPressureCategory.highStage2 ||
      this == BloodPressureCategory.crisis ||
      this == BloodPressureCategory.low;

  static BloodPressureCategory fromValue(String value) {
    return BloodPressureCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BloodPressureCategory.unknown,
    );
  }
}
