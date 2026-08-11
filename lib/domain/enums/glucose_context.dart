enum GlucoseContext {
  fasting,
  postMeal,
  other,
}

extension GlucoseContextExtension on GlucoseContext {
  String get displayName {
    switch (this) {
      case GlucoseContext.fasting:
        return 'Fasting';
      case GlucoseContext.postMeal:
        return 'After meal';
      case GlucoseContext.other:
        return 'Other';
    }
  }

  String get value {
    switch (this) {
      case GlucoseContext.fasting:
        return 'fasting';
      case GlucoseContext.postMeal:
        return 'post_meal';
      case GlucoseContext.other:
        return 'other';
    }
  }

  static GlucoseContext fromValue(String value) {
    return GlucoseContext.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GlucoseContext.other,
    );
  }
}
