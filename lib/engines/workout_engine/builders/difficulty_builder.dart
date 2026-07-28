import 'package:gymgenius/domain/enums/exercise_difficulty.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';

class DifficultyBuilder {
  DifficultyBuilder._();

  static ExerciseDifficulty build(
    ExperienceLevel experience,
  ) {
    switch (experience) {
      case ExperienceLevel.beginner:
        return ExerciseDifficulty.beginner;

      case ExperienceLevel.intermediate:
        return ExerciseDifficulty.intermediate;

      case ExperienceLevel.advanced:
        return ExerciseDifficulty.advanced;
    }
  }
}
