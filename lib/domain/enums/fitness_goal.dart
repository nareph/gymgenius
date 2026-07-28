// lib/domain/enums/fitness_goal.dart

enum FitnessGoal {
  buildMuscle,
  increaseStrength,
  loseFat,
  improveEndurance,
  generalFitness,
}

extension FitnessGoalExtension on FitnessGoal {
  String get displayName {
    switch (this) {
      case FitnessGoal.buildMuscle:
        return 'Build Muscle / Hypertrophy';
      case FitnessGoal.increaseStrength:
        return 'Increase Strength';
      case FitnessGoal.loseFat:
        return 'Lose Fat / Get Lean';
      case FitnessGoal.improveEndurance:
        return 'Improve Cardiovascular Endurance';
      case FitnessGoal.generalFitness:
        return 'General Fitness / Well-being';
    }
  }

  String get value {
    switch (this) {
      case FitnessGoal.buildMuscle:
        return 'build_muscle';
      case FitnessGoal.increaseStrength:
        return 'increase_strength';
      case FitnessGoal.loseFat:
        return 'lose_fat';
      case FitnessGoal.improveEndurance:
        return 'improve_endurance';
      case FitnessGoal.generalFitness:
        return 'general_fitness';
    }
  }

  static FitnessGoal fromValue(String value) {
    return FitnessGoal.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FitnessGoal.generalFitness,
    );
  }
}
