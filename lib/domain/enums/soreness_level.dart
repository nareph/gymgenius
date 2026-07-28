enum SorenessLevel {
  none,
  mild,
  moderate,
  severe,
}

extension SorenessLevelExtension on SorenessLevel {
  String get displayName {
    switch (this) {
      case SorenessLevel.none:
        return 'None';
      case SorenessLevel.mild:
        return 'Mild';
      case SorenessLevel.moderate:
        return 'Moderate';
      case SorenessLevel.severe:
        return 'Severe';
    }
  }

  String get value {
    switch (this) {
      case SorenessLevel.none:
        return 'none';
      case SorenessLevel.mild:
        return 'mild';
      case SorenessLevel.moderate:
        return 'moderate';
      case SorenessLevel.severe:
        return 'severe';
    }
  }

  static SorenessLevel fromValue(String value) {
    return SorenessLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SorenessLevel.none,
    );
  }
}
