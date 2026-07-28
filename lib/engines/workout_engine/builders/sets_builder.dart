import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';

class SetsBuilder {
  SetsBuilder._();

  static int build(
    ExperienceLevel experience, {
    ExerciseCategory? category,
    FitnessGoal? goal,
  }) {
    // Les exercices composés reçoivent généralement plus de volume.
    if (category == ExerciseCategory.compound) {
      switch (experience) {
        case ExperienceLevel.beginner:
          return 3;

        case ExperienceLevel.intermediate:
          return 4;

        case ExperienceLevel.advanced:
          return 5;
      }
    }

    // Les exercices d'isolation.
    if (category == ExerciseCategory.isolation) {
      switch (experience) {
        case ExperienceLevel.beginner:
          return 2;

        case ExperienceLevel.intermediate:
          return 3;

        case ExperienceLevel.advanced:
          return 4;
      }
    }

    // Cardio
    if (category == ExerciseCategory.cardio) {
      return 1;
    }

    // Mobilité
    if (category == ExerciseCategory.mobility) {
      return 2;
    }

    // Ajustement léger selon l'objectif
    // (utilise uniquement les 5 valeurs réelles de FitnessGoal)
    if (goal != null) {
      switch (goal) {
        case FitnessGoal.increaseStrength:
          return 5;

        case FitnessGoal.buildMuscle:
          return 4;

        case FitnessGoal.loseFat:
          return 3;

        case FitnessGoal.improveEndurance:
          return 3;

        case FitnessGoal.generalFitness:
          break;
      }
    }

    // Valeur par défaut
    switch (experience) {
      case ExperienceLevel.beginner:
        return 3;

      case ExperienceLevel.intermediate:
        return 4;

      case ExperienceLevel.advanced:
        return 4;
    }
  }
}
