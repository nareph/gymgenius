enum Laterality {
  bilateral,
  unilateral,
  alternating,
}

extension LateralityExtension on Laterality {
  String get displayName {
    switch (this) {
      case Laterality.bilateral:
        return 'Bilateral';
      case Laterality.unilateral:
        return 'Unilateral';
      case Laterality.alternating:
        return 'Alternating';
    }
  }

  String get value {
    switch (this) {
      case Laterality.bilateral:
        return 'bilateral';
      case Laterality.unilateral:
        return 'unilateral';
      case Laterality.alternating:
        return 'alternating';
    }
  }

  static Laterality fromValue(String value) {
    return Laterality.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Laterality.bilateral,
    );
  }
}
