// lib/engines/workout_engine/workout_engine.dart
import 'dart:math';

import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/models/workout_days_result.dart';
import 'package:gymgenius/engines/workout_engine/models/workout_profile.dart';
import 'package:gymgenius/engines/workout_engine/program_generator.dart';
import 'package:gymgenius/engines/workout_engine/program_validator.dart';
import 'package:gymgenius/engines/workout_engine/split_generator.dart';

/// Central deterministic engine for workout programming.
///
/// Stateless — all inputs are passed explicitly, no side effects.
class WorkoutEngine {
  WorkoutEngine({int? seed})
      : _programGenerator = ProgramGenerator(
          random: seed != null ? Random(seed) : Random(),
        );

  final ProgramGenerator _programGenerator;

  WorkoutDaysResult calculateWorkoutDays({
    String? frequency,
    List<String>? preferredDays,
  }) {
    return SplitGenerator.calculateWorkoutDays(
      frequency: frequency,
      preferredDays: preferredDays,
    );
  }

  List<MuscleSplit> determineMuscleSplit(
    int workoutDaysCount,
    String experience,
  ) {
    return SplitGenerator.determineMuscleSplit(workoutDaysCount, experience);
  }

  /// Generates a training program using deterministic rules (local mode).
  Map<String, dynamic> generateTrainingProgram({
    required WorkoutProfile profile,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
  }) {
    final program = _programGenerator.generate(
      profile: profile,
      selectedSplit: selectedSplit,
      workoutDaysCount: workoutDaysCount,
      useSpecifiedDays: useSpecifiedDays,
    );
    return validateAndNormalize(program);
  }

  Map<String, dynamic> validateAndNormalize(Map<String, dynamic> program) {
    return ProgramValidator.validateAndNormalize(program);
  }
}
