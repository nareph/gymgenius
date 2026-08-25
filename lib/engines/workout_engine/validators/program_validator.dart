import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';

/// Validates a fully-built [TrainingProgram].
///
/// The validator performs structural validation and, when focus areas are
/// supplied, verifies that the generated program does not introduce primary
/// muscles outside the user's explicitly requested focus.
///
/// This validator does not throw. It reports failures through the logger and
/// returns false so callers can decide how to handle an invalid program.
class ProgramValidator {
  const ProgramValidator();

  static const _tag = 'ProgramValidator';

  /// Basic structural validation.
  bool validate(TrainingProgram program) {
    var isValid = true;

    if (program.weeklySchedule.isEmpty) {
      Log.warning(
        'Program has an empty weekly schedule',
        tag: _tag,
      );
      return false;
    }

    for (final entry in program.weeklySchedule.entries) {
      final day = entry.key;
      final exercises = entry.value;

      final seenNames = <String>{};

      for (final exercise in exercises) {
        if (!seenNames.add(exercise.name)) {
          Log.warning(
            'Duplicate exercise "${exercise.name}" on $day',
            tag: _tag,
          );
          isValid = false;
        }

        if (exercise.sets <= 0) {
          Log.warning(
            'Exercise "${exercise.name}" on $day has invalid sets: '
            '${exercise.sets}',
            tag: _tag,
          );
          isValid = false;
        }

        if (exercise.reps.trim().isEmpty) {
          Log.warning(
            'Exercise "${exercise.name}" on $day has empty reps',
            tag: _tag,
          );
          isValid = false;
        }

        if (exercise.isTimed && exercise.targetDurationSeconds == null) {
          Log.warning(
            'Timed exercise "${exercise.name}" on $day is missing '
            'targetDurationSeconds',
            tag: _tag,
          );
          isValid = false;
        }

        if (exercise.restSeconds < 0) {
          Log.warning(
            'Exercise "${exercise.name}" on $day has negative rest: '
            '${exercise.restSeconds}s',
            tag: _tag,
          );
          isValid = false;
        }
      }
    }

    if (program.durationWeeks <= 0) {
      Log.warning(
        'Program has invalid durationWeeks: ${program.durationWeeks}',
        tag: _tag,
      );
      isValid = false;
    }

    return isValid;
  }

  /// Validates a program against strict user focus areas.
  ///
  /// The focus areas represent explicit user intent:
  ///
  ///     "I want to work only these muscles."
  ///
  /// Therefore an exercise whose primary target muscles are completely
  /// outside [focusMuscles] is considered incompatible.
  ///
  /// Secondary muscles are deliberately ignored here. A compound exercise
  /// may naturally involve additional muscles without making them primary
  /// targets of the workout.
  ///
  /// Returns true when all generated exercises respect the requested focus.
  bool validateFocus({
    required TrainingProgram program,
    required List<MuscleGroup> focusMuscles,
  }) {
    if (focusMuscles.isEmpty) {
      return true;
    }

    final allowed = focusMuscles.toSet();
    var isValid = true;

    for (final entry in program.weeklySchedule.entries) {
      final day = entry.key;

      for (final exercise in entry.value) {
        final primaryTargets = _exercisePrimaryMuscles(exercise);

        if (primaryTargets.isEmpty) {
          Log.warning(
            'Exercise "${exercise.name}" on $day has no primary '
            'muscle information while strict focus validation is enabled.',
            tag: _tag,
          );
          isValid = false;
          continue;
        }

        if (!primaryTargets.any(allowed.contains)) {
          Log.warning(
            'Exercise "${exercise.name}" on $day targets '
            '${primaryTargets.map((m) => m.displayName).join(', ')} '
            'but requested focus is '
            '${allowed.map((m) => m.displayName).join(', ')}.',
            tag: _tag,
          );
          isValid = false;
        }
      }
    }

    return isValid;
  }

  /// Performs structural validation and strict-focus validation together.
  ///
  /// [focusMuscles] should contain the already-resolved focus list from
  /// [ProfileCoherence.resolveFocusAreas].
  bool validateWithFocus({
    required TrainingProgram program,
    required List<MuscleGroup> focusMuscles,
  }) {
    final structureValid = validate(program);

    if (!structureValid) {
      return false;
    }

    if (focusMuscles.isEmpty) {
      return true;
    }

    return validateFocus(
      program: program,
      focusMuscles: focusMuscles,
    );
  }

  /// Attempts to read the primary muscle information exposed by the domain
  /// Exercise entity.
  ///
  /// The validator deliberately keeps this isolated so only this adapter
  /// needs to change if the Exercise entity's muscle field is renamed.
  List<MuscleGroup> _exercisePrimaryMuscles(
    dynamic exercise,
  ) {
    final targets = exercise.targetMuscles;

    if (targets is List<MuscleGroup>) {
      return List<MuscleGroup>.from(targets);
    }

    if (targets is Iterable) {
      return targets.whereType<MuscleGroup>().toList();
    }

    return const [];
  }
}
