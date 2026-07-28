import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/workout_day.dart';
import 'package:gymgenius/domain/enums/workout_frequency.dart';
import 'package:gymgenius/engines/workout_engine/program_generator.dart';
import 'package:gymgenius/engines/workout_engine/optimizers/program_optimizer.dart';
import 'package:gymgenius/engines/workout_engine/optimizers/local_program_optimizer.dart';
import 'package:gymgenius/engines/workout_engine/validators/program_validator.dart';
import 'package:gymgenius/engines/workout_engine/generators/split_generator.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/models/workout_days_result.dart';
import 'package:gymgenius/engines/workout_engine/shared/workout_constants.dart';
import 'package:gymgenius/engines/workout_engine/overload/overload_rules.dart';
import 'package:gymgenius/core/logger/logger_service.dart';

/// Orchestrates the complete program generation pipeline.
///
/// 1. Generates a valid program locally (always)
/// 2. Optimizes the program (LOCAL rules only — see note below)
/// 3. Validates the final program
///
/// NOTE ON AI: Per the Workout Engine spec ("Artificial Intelligence may
/// improve explanations or personalization, but it never replaces the
/// core decision logic" / module doc Rule 3: "AI does not decide training
/// structure. AI only explains system decisions"), this pipeline is
/// 100% deterministic end to end. Gemini/AI has been deliberately removed
/// from the optimizer chain — it must never mutate `weeklySchedule`
/// directly. A future AI Coach module may READ the finished program and
/// produce human-readable suggestions, but applying any suggested change
/// must go back through RegenerationService (type: 'singleExercise'),
/// which only ever selects from the local ExercisePool — never from raw
/// AI-generated exercise data.
class GenerationService {
  final ProgramGenerator _generator;
  final List<ProgramOptimizer> _optimizers;
  final ProgramValidator _validator;
  static const _tag = 'GenerationService';

  GenerationService({
    ProgramGenerator? generator,
    List<ProgramOptimizer>? optimizers,
    ProgramValidator? validator,
  })  : _generator = generator ?? ProgramGenerator(),
        _optimizers = optimizers ??
            [
              const LocalProgramOptimizer(),
            ],
        _validator = validator ?? const ProgramValidator();

  /// Generates a training program.
  ///
  /// [options] may contain regeneration hints:
  /// - `avoidMuscles`: List<'String'> of MuscleGroup values to exclude from
  ///   exercise selection entirely (e.g. an injury).
  /// - `intensity`: 'harder' or 'easier', shifts the effective experience
  ///   level used for sets/reps by one step for this generation only.
  ///
  /// (`focusMuscles`, `keepStructure`, and single-day/single-exercise
  /// regeneration are handled one level up, in RegenerationService.)
  Future<TrainingProgram> generate({
    required HealthProfile profile,
    TrainingProgram? previousProgram,
    Map<String, dynamic>? options,
  }) async {
    Log.debug('GenerationService: Starting program generation');

    // Step 1: Calculate workout days
    final daysResult = _calculateWorkoutDays(profile);

    // Step 2: Determine split
    final selectedSplit = _determineSplit(daysResult.count, profile);

    // Step 3: Generate initial program (local, deterministic)
    var program = _generator.generate(
      profile: profile,
      selectedSplit: selectedSplit,
      workoutDaysCount: daysResult.count,
      useSpecifiedDays: daysResult.useSpecifiedDays,
      previousProgram: previousProgram,
      excludeMuscles: _parseExcludeMuscles(options),
      intensityOverride: options?['intensity'] as String?,
    );

    Log.debug(
        'GenerationService: Local program generated (${program.weeklySchedule.length} days)');

    // Step 4: Apply optimizers (local-only, deterministic)
    for (final optimizer in _optimizers) {
      if (optimizer.isAvailable) {
        try {
          program = await optimizer.optimize(
            program: program,
            profile: profile,
            options: options,
          );
          Log.debug(
              'GenerationService: Optimized with ${optimizer.runtimeType}');
        } catch (e) {
          Log.warning(
              'GenerationService: Optimizer ${optimizer.runtimeType} failed',
              error: e);
        }
      }
    }

    // Step 5: Validate final program
    final isValid = _validator.validate(program);
    if (!isValid) {
      Log.warning(
          'GenerationService: Program failed validation checks (see '
          'ProgramValidator warnings above) — returning it anyway per the '
          '"never block the user" safety principle, but this should be '
          'investigated.',
          tag: _tag);
    }

    Log.debug('GenerationService: Program generation complete');
    return program;
  }

  // ============================================================
  // Private helpers
  // ============================================================

  WorkoutDaysResult _calculateWorkoutDays(HealthProfile profile) {
    final frequency = _frequencyValue(profile.training.frequency);
    final preferredDays =
        profile.training.preferredDays.map((d) => d.value).toList();
    return SplitGenerator.calculateWorkoutDays(
      frequency: frequency,
      preferredDays: preferredDays,
    );
  }

  List<MuscleSplit> _determineSplit(int daysCount, HealthProfile profile) {
    final experience = profile.training.experience.value;
    return SplitGenerator.determineMuscleSplit(daysCount, experience);
  }

  List<MuscleGroup>? _parseExcludeMuscles(Map<String, dynamic>? options) {
    final raw = options?['avoidMuscles'];
    if (raw is! List) return null;
    return raw
        .map((v) => MuscleGroupExtension.fromValue(v.toString()))
        .toList();
  }

  String _frequencyValue(WorkoutFrequency frequency) {
    switch (frequency) {
      case WorkoutFrequency.oneToTwo:
        return '1-2';
      case WorkoutFrequency.threeToFour:
        return '3-4';
      case WorkoutFrequency.fivePlus:
        return '5-plus';
    }
  }
}
