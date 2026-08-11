// lib/engines/workout_engine/validators/program_validator.dart

import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/core/logger/logger_service.dart';

/// Validates a fully-built TrainingProgram made of domain objects
/// (`Exercise`, not `Map<String, dynamic>`).
///
/// This replaces the old Map-based validator, which only made sense when
/// programs came straight from Gemini as raw JSON to parse. Now that
/// WorkoutDayGenerator / ExerciseBuilder always produce proper Exercise
/// entities before this runs, validation checks the domain objects
/// directly instead of re-parsing loosely-typed maps.
///
/// Validation failures are logged, not thrown — a locally-generated
/// program should never crash the app; GenerationService always has a
/// program to fall back on even if this reports issues.
class ProgramValidator {
  const ProgramValidator();

  static const _tag = 'ProgramValidator';

  /// Returns true if [program] is safe to show to the user.
  bool validate(TrainingProgram program) {
    var isValid = true;

    if (program.weeklySchedule.isEmpty) {
      Log.warning('Program has an empty weekly schedule', tag: _tag);
      return false;
    }

    for (final entry in program.weeklySchedule.entries) {
      final day = entry.key;
      final exercises = entry.value;

      // Defense in depth: ExerciseSelector should already prevent
      // duplicates within a day, but the validator catches it too in
      // case a future optimizer (local or Gemini) reintroduces one.
      final seenNames = <String>{};
      for (final exercise in exercises) {
        if (!seenNames.add(exercise.name)) {
          Log.warning('Duplicate exercise "${exercise.name}" on $day',
              tag: _tag);
          isValid = false;
        }

        if (exercise.sets <= 0) {
          Log.warning(
              'Exercise "${exercise.name}" on $day has invalid sets: ${exercise.sets}',
              tag: _tag);
          isValid = false;
        }

        if (exercise.reps.trim().isEmpty) {
          Log.warning('Exercise "${exercise.name}" on $day has empty reps',
              tag: _tag);
          isValid = false;
        }

        if (exercise.isTimed && exercise.targetDurationSeconds == null) {
          Log.warning(
              'Timed exercise "${exercise.name}" on $day is missing targetDurationSeconds',
              tag: _tag);
          isValid = false;
        }

        if (exercise.restSeconds < 0) {
          Log.warning(
              'Exercise "${exercise.name}" on $day has negative rest: ${exercise.restSeconds}s',
              tag: _tag);
          isValid = false;
        }
      }
    }

    if (program.durationWeeks <= 0) {
      Log.warning('Program has invalid durationWeeks: ${program.durationWeeks}',
          tag: _tag);
      isValid = false;
    }

    return isValid;
  }
}
