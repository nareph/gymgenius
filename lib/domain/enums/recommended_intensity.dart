enum RecommendedIntensity {
  rest,
  light,
  moderate,
  high,
  max,
}

extension RecommendedIntensityExtension on RecommendedIntensity {
  String get displayName {
    switch (this) {
      case RecommendedIntensity.rest:
        return 'Rest Day';
      case RecommendedIntensity.light:
        return 'Light Intensity';
      case RecommendedIntensity.moderate:
        return 'Moderate Intensity';
      case RecommendedIntensity.high:
        return 'High Intensity';
      case RecommendedIntensity.max:
        return 'Maximum Intensity';
    }
  }

  String get value {
    switch (this) {
      case RecommendedIntensity.rest:
        return 'rest';
      case RecommendedIntensity.light:
        return 'light';
      case RecommendedIntensity.moderate:
        return 'moderate';
      case RecommendedIntensity.high:
        return 'high';
      case RecommendedIntensity.max:
        return 'max';
    }
  }

  static RecommendedIntensity fromValue(String value) {
    return RecommendedIntensity.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RecommendedIntensity.moderate,
    );
  }
}
