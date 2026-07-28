// lib/engines/workout_engine/utils/overload_helper.dart

import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/engines/workout_engine/builders/reps_builder.dart';
import 'package:gymgenius/engines/workout_engine/builders/rest_builder.dart';
import 'package:gymgenius/engines/workout_engine/builders/sets_builder.dart';

class OverloadHelper {
  OverloadHelper._();

  static int sets({
    required ExperienceLevel experience,
    required ExerciseCategory category,
    required FitnessGoal goal,
  }) {
    return SetsBuilder.build(
      experience,
      category: category,
      goal: goal,
    );
  }

  static String reps({
    required ExperienceLevel experience,
    required ExerciseCategory category,
    required FitnessGoal goal,
  }) {
    return RepsBuilder.build(
      experience: experience,
      goal: goal,
      category: category,
    );
  }

  static int restSeconds({
    required FitnessGoal goal,
    required ExerciseCategory category,
  }) {
    return RestBuilder.build(
      goal: goal,
      category: category,
    );
  }
}
