import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';

class RepsBuilder {
  RepsBuilder._();

  static String build({
    required ExperienceLevel experience,
    required FitnessGoal goal,
    required ExerciseCategory category,
  }) {
    // Cardio / mobilité
    switch (category) {
      case ExerciseCategory.cardio:
        return '20-30 min';

      case ExerciseCategory.mobility:
        return '8-12 reps';

      case ExerciseCategory.compound:
      case ExerciseCategory.isolation:
        return _strengthReps(
          goal: goal,
          experience: experience,
        );
    }
  }

  static String _strengthReps({
    required FitnessGoal goal,
    required ExperienceLevel experience,
  }) {
    switch (goal) {
      case FitnessGoal.increaseStrength:
        switch (experience) {
          case ExperienceLevel.beginner:
            return '6-8';

          case ExperienceLevel.intermediate:
            return '5-8';

          case ExperienceLevel.advanced:
            return '3-6';
        }

      case FitnessGoal.buildMuscle:
        switch (experience) {
          case ExperienceLevel.beginner:
            return '10-12';

          case ExperienceLevel.intermediate:
            return '8-12';

          case ExperienceLevel.advanced:
            return '6-10';
        }

      case FitnessGoal.loseFat:
        return '12-15';

      case FitnessGoal.improveEndurance:
        return '15-20';

      case FitnessGoal.generalFitness:
        return '8-12';
    }
  }
}
