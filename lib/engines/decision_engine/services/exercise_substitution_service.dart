import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/engines/workout_engine/providers/exercise_replacement_provider.dart';

/// Replaces incompatible exercises with equivalent alternatives.
///
/// This service belongs to the Decision Engine.
///
/// It does NOT know how to search for alternatives.
/// That responsibility belongs to the Workout Engine through
/// [ExerciseReplacementProvider].
///
/// Responsibilities:
///
/// • iterate through today's exercises
/// • ask the provider for compatible replacements
/// • preserve workout structure
/// • avoid duplicate substitutions
///
/// If no suitable alternative exists, the original exercise is kept.
class ExerciseSubstitutionService {
  final ExerciseReplacementProvider _replacementProvider;

  const ExerciseSubstitutionService({
    required ExerciseReplacementProvider replacementProvider,
  }) : _replacementProvider = replacementProvider;

  TodayWorkout substituteExercises(
    TodayWorkout workout,
    HealthProfile profile,
  ) {
    final usedNames =
        workout.finalExercises.map((exercise) => exercise.name).toSet();

    final substitutedExercises = workout.finalExercises.map((exercise) {
      final replacement = _replacementProvider.findReplacement(
        exercise: exercise,
        profile: profile,
        excludeNames: usedNames,
      );

      // No compatible replacement found.
      if (replacement == null) {
        return exercise;
      }

      // Same exercise -> already compatible.
      if (replacement.name == exercise.name) {
        return exercise;
      }

      usedNames
        ..remove(exercise.name)
        ..add(replacement.name);

      return replacement;
    }).toList();

    return workout.copyWith(
      finalExercises: substitutedExercises,
      isAdapted: true,
    );
  }
}
