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

class WorkoutDayGenerator {
  final Random _random;
  final ExerciseSelector _selector;

  WorkoutDayGenerator({Random? random})
      : _random = random ?? Random(),
        _selector = ExerciseSelector(random: random);

  /// [desiredCountOverride], when provided, replaces the session-duration
  /// based exercise count — used by RegenerationService's single-exercise
  /// path (asks for exactly 1 replacement) and keepStructure path (asks
  /// for exactly as many exercises as the day previously had).
  List<Exercise> generate({
    required MuscleSplit split,
    required HealthProfile profile,
    TrainingProgram? previousProgram,
    List<MuscleGroup>? excludeMuscles,
    String? intensityOverride,
    int? desiredCountOverride,
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
