enum GlucoseCategory {
  low,
  normal,
  elevated,
  high,
  unknown,
}

extension GlucoseCategoryExtension on GlucoseCategory {
  String get displayName {
    switch (this) {
      case GlucoseCategory.low:
        return 'Low';
      case GlucoseCategory.normal:
        return 'Normal';
      case GlucoseCategory.elevated:
        return 'Elevated';
      case GlucoseCategory.high:
        return 'High';
      case GlucoseCategory.unknown:
        return 'Unknown';
    }
  }

  String get value {
    switch (this) {
      case GlucoseCategory.low:
        return 'low';
      case GlucoseCategory.normal:
        return 'normal';
      case GlucoseCategory.elevated:
        return 'elevated';
      case GlucoseCategory.high:
        return 'high';
      case GlucoseCategory.unknown:
        return 'unknown';
    }
  }

  bool get requiresCaution =>
      this == GlucoseCategory.low || this == GlucoseCategory.high;

  static GlucoseCategory fromValue(String value) {
    return GlucoseCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GlucoseCategory.unknown,
    );
  }
}
