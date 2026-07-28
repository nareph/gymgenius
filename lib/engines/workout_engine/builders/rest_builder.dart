import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';

class RestBuilder {
  RestBuilder._();

  static int build({
    required FitnessGoal goal,
    required ExerciseCategory category,
  }) {
    switch (category) {
      // =========================
      // Compound exercises
      // =========================
      case ExerciseCategory.compound:
        switch (goal) {
          case FitnessGoal.increaseStrength:
            return 180;

          case FitnessGoal.buildMuscle:
            return 90;

          case FitnessGoal.loseFat:
            return 60;

          case FitnessGoal.improveEndurance:
            return 45;

          case FitnessGoal.generalFitness:
            return 75;
        }

      // =========================
      // Isolation exercises
      // =========================
      case ExerciseCategory.isolation:
        switch (goal) {
          case FitnessGoal.increaseStrength:
            return 90;

          case FitnessGoal.buildMuscle:
            return 60;

          case FitnessGoal.loseFat:
            return 45;

          case FitnessGoal.improveEndurance:
            return 30;

          case FitnessGoal.generalFitness:
            return 45;
        }

      // =========================
      // Cardio
      // =========================
      case ExerciseCategory.cardio:
        switch (goal) {
          case FitnessGoal.improveEndurance:
            return 15;

          case FitnessGoal.loseFat:
            return 20;

          default:
            return 30;
        }

      // =========================
      // Mobility
      // =========================
      case ExerciseCategory.mobility:
        return 15;
    }
  }
}
