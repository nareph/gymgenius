enum MealObjective {
  highProtein,
  highEnergy,
  recovery,
  light,
}

extension MealObjectiveExtension on MealObjective {
  String get displayName {
    switch (this) {
      case MealObjective.highProtein:
        return 'High protein';
      case MealObjective.highEnergy:
        return 'High energy';
      case MealObjective.recovery:
        return 'Recovery';
      case MealObjective.light:
        return 'Light';
    }
  }

  String get value {
    switch (this) {
      case MealObjective.highProtein:
        return 'high_protein';
      case MealObjective.highEnergy:
        return 'high_energy';
      case MealObjective.recovery:
        return 'recovery';
      case MealObjective.light:
        return 'light';
    }
  }

  static MealObjective fromValue(String value) {
    return MealObjective.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MealObjective.highEnergy,
    );
  }
}
