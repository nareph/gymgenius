import 'package:gymgenius/core/logger/logger_service.dart';

import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/workout_day.dart';

import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/models/workout_days_result.dart';

import 'package:gymgenius/engines/workout_engine/optimizers/local_program_optimizer.dart';
import 'package:gymgenius/engines/workout_engine/optimizers/program_optimizer.dart';

import 'package:gymgenius/engines/workout_engine/planner/split_planner.dart';
import 'package:gymgenius/engines/workout_engine/planner/workout_frequency_planner.dart';

import 'package:gymgenius/engines/workout_engine/program_generator.dart';
import 'package:gymgenius/engines/workout_engine/validators/program_validator.dart';

/// Orchestrates the complete Workout Engine generation pipeline.
///
/// Pipeline
///
/// WorkoutFrequencyPlanner
///          ↓
/// SplitPlanner
///          ↓
/// ProgramGenerator
///          ↓
/// LocalProgramOptimizer(s)
///          ↓
/// ProgramValidator
///
/// Every step is deterministic.
///
/// AI never decides the workout structure.
/// AI may only explain or suggest improvements.
class GenerationService {
  final ProgramGenerator _generator;

  final WorkoutFrequencyPlanner _frequencyPlanner;
  final SplitPlanner _splitPlanner;

  final List<ProgramOptimizer> _optimizers;

  final ProgramValidator _validator;

  static const _tag = 'GenerationService';

  GenerationService({
    ProgramGenerator? generator,
    WorkoutFrequencyPlanner? frequencyPlanner,
    SplitPlanner? splitPlanner,
    List<ProgramOptimizer>? optimizers,
    ProgramValidator? validator,
  })  : _generator = generator ?? ProgramGenerator(),
        _frequencyPlanner = frequencyPlanner ?? const WorkoutFrequencyPlanner(),
        _splitPlanner = splitPlanner ?? const SplitPlanner(),
        _optimizers = optimizers ??
            const [
              LocalProgramOptimizer(),
            ],
        _validator = validator ?? const ProgramValidator();

  Future<TrainingProgram> generate({
    required HealthProfile profile,
    TrainingProgram? previousProgram,
    Map<String, dynamic>? options,
  }) async {
    Log.debug(
      'GenerationService: Starting program generation',
      tag: _tag,
    );

    //------------------------------------------------------------
    // Workout frequency
    //------------------------------------------------------------

    final daysResult = _calculateWorkoutDays(profile);

    //------------------------------------------------------------
    // Split selection
    //------------------------------------------------------------

    final selectedSplit = _determineSplit(
      daysResult.count,
      profile,
    );

    //------------------------------------------------------------
    // Initial deterministic generation
    //------------------------------------------------------------

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
      'GenerationService: Local program generated (${program.weeklySchedule.length} days)',
      tag: _tag,
    );

    //------------------------------------------------------------
    // Optimizers
    //------------------------------------------------------------

    for (final optimizer in _optimizers) {
      if (!optimizer.isAvailable) continue;

      try {
        program = await optimizer.optimize(
          program: program,
          profile: profile,
          options: options,
        );

        Log.debug(
          'GenerationService: Optimized with ${optimizer.runtimeType}',
          tag: _tag,
        );
      } catch (e) {
        Log.warning(
          'GenerationService: Optimizer ${optimizer.runtimeType} failed',
          tag: _tag,
          error: e,
        );
      }
    }

    //------------------------------------------------------------
    // Validation
    //------------------------------------------------------------

    final valid = _validator.validate(program);

    if (!valid) {
      Log.warning(
        'GenerationService: Program validation failed.',
        tag: _tag,
      );
    }

    Log.debug(
      'GenerationService: Generation complete',
      tag: _tag,
    );

    return program;
  }

  //==============================================================
  // Private helpers
  //==============================================================

  WorkoutDaysResult _calculateWorkoutDays(
    HealthProfile profile,
  ) {
    return _frequencyPlanner.calculateWorkoutDays(
      frequency: profile.training.frequency,
      preferredDays:
          profile.training.preferredDays.map((d) => d.value).toList(),
    );
  }

  List<MuscleSplit> _determineSplit(
    int workoutDays,
    HealthProfile profile,
  ) {
    return _splitPlanner.plan(
      workoutDays: workoutDays,
      experience: profile.training.experience,
      focusMuscles: profile.training.focusAreas,
    );
  }

  List<MuscleGroup>? _parseExcludeMuscles(
    Map<String, dynamic>? options,
  ) {
    final raw = options?['avoidMuscles'];

    if (raw is! List) {
      return null;
    }

    return raw
        .map(
          (value) => MuscleGroupExtension.fromValue(
            value.toString(),
          ),
        )
        .toList();
  }
}
