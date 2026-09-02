// lib/engines/workout_engine/generators/workout_day_generator.dart

import 'dart:math';

import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/session_duration.dart';
import 'package:gymgenius/engines/workout_engine/builders/exercise_builder.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/selectors/exercise_selector.dart';
import 'package:gymgenius/engines/workout_engine/volume_calculator.dart';

/// Generates the list of exercises for a single workout day.
///
/// It uses the [ExerciseSelector] to select exercises from the canonical pool,
/// and then builds domain [Exercise] objects from the selected entries.
class WorkoutDayGenerator {
  final Random _random;
  final ExerciseSelector _selector;

  WorkoutDayGenerator({Random? random})
      : _random = random ?? Random(),
        _selector = ExerciseSelector(random: random);

  /// Generates exercises for one workout day.
  ///
  /// [desiredCountOverride] can be used to force a specific number of exercises
  /// (used by regeneration when preserving structure).
  ///
  /// [weeklyUsedExerciseIds] is a set of exercise IDs already used in other
  /// days of the same week; the selector will avoid reusing them.
  List<Exercise> generate({
    required MuscleSplit split,
    required HealthProfile profile,
    TrainingProgram? previousProgram,
    List<MuscleGroup>? excludeMuscles,
    String? intensityOverride,
    int? desiredCountOverride,
    Set<String> weeklyUsedExerciseIds = const {},
  }) {
    final desiredCount = desiredCountOverride ??
        VolumeCalculator.exerciseCountForSession(
          // `.value` (custom snake_case extension), not `.name` (Dart's
          // built-in enum identifier) — see note in the original fix.
          profile.training.sessionDuration.value,
          _random.nextInt(3),
          activityLevel: profile.training.activityLevel,
        );

    final entries = _selector.select(
      split: split,
      profile: profile,
      desiredCount: desiredCount,
      previousProgram: previousProgram,
      excludeMuscles: excludeMuscles,
      weeklyUsedExerciseIds: weeklyUsedExerciseIds,
    );

    final builder = const ExerciseBuilder();

    return entries
        .map(
          (entry) => builder.build(
            entry: entry,
            profile: profile,
            intensityOverride: intensityOverride,
          ),
        )
        .toList();
  }
}
