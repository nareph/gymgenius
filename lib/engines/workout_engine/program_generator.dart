import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/generator_type.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/split_type.dart';
import 'package:gymgenius/domain/value_objects/workout_preferences.dart';

import 'package:gymgenius/engines/workout_engine/generators/workout_day_generator.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/overload/overload_rules.dart';
import 'package:gymgenius/engines/workout_engine/shared/workout_constants.dart';

/// ---------------------------------------------------------------------------
/// ProgramGenerator
/// ---------------------------------------------------------------------------
///
/// Generates a complete TrainingProgram from:
///
/// • HealthProfile
/// • selected workout splits
/// • workout frequency
/// • previous program
///
/// The generator itself does not receive or manage Random.
///
/// Exercise selection and workout composition are delegated to
/// WorkoutDayGenerator.
///
/// The generator is therefore a pure orchestration layer.
/// ---------------------------------------------------------------------------
class ProgramGenerator {
  ProgramGenerator({
    WorkoutDayGenerator? dayGenerator,
  }) : _dayGenerator = dayGenerator ?? WorkoutDayGenerator();

  final WorkoutDayGenerator _dayGenerator;

  //===========================================================================
  // Program generation
  //===========================================================================

  TrainingProgram generate({
    required HealthProfile profile,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
    TrainingProgram? previousProgram,
    List<MuscleGroup>? excludeMuscles,
    String? intensityOverride,
  }) {
    final training = profile.training;

    //-----------------------------------------------------------------------
    // Resolve workout days
    //-----------------------------------------------------------------------

    final workoutDays = _resolveWorkoutDays(
      training: training,
      workoutDaysCount: workoutDaysCount,
      useSpecifiedDays: useSpecifiedDays,
    );

    //-----------------------------------------------------------------------
    // Initialize weekly schedule
    //-----------------------------------------------------------------------

    final weeklySchedule = <String, List<Exercise>>{
      for (final day in WorkoutConstants.daysOfWeek) day: <Exercise>[],
    };

    //-----------------------------------------------------------------------
    // Generate each workout day
    //-----------------------------------------------------------------------

    for (var i = 0; i < workoutDays.length && i < selectedSplit.length; i++) {
      final day = workoutDays[i];
      final split = selectedSplit[i];

      weeklySchedule[day] = _dayGenerator.generate(
        split: split,
        profile: profile,
        previousProgram: previousProgram,
        excludeMuscles: excludeMuscles,
        intensityOverride: intensityOverride,
      );
    }

    //-----------------------------------------------------------------------
    // Program duration
    //-----------------------------------------------------------------------

    final durationWeeks = OverloadRules.programDurationWeeks(
      training.experience.name,
      0,
    );

    //-----------------------------------------------------------------------
    // Program metadata
    //-----------------------------------------------------------------------

    final now = DateTime.now();

    return TrainingProgram(
      id: '',
      userId: profile.userId,
      name: _programName(
        workoutDaysCount,
        selectedSplit,
      ),
      goal: training.goal,
      split: _splitType(selectedSplit),
      experience: training.experience,
      durationWeeks: durationWeeks,
      weeklySchedule: weeklySchedule,
      generatorType: GeneratorType.local,
      generatorVersion: '3.1.0',
      createdAt: now,
      expiresAt: now.add(
        Duration(days: durationWeeks * 7),
      ),
    );
  }

  //===========================================================================
  // Workout days
  //===========================================================================

  List<String> _resolveWorkoutDays({
    required WorkoutPreferences training,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
  }) {
    if (useSpecifiedDays && training.preferredDays.isNotEmpty) {
      return training.preferredDays.map((day) => day.name).toList();
    }

    return WorkoutConstants.defaultWorkoutDays(
      workoutDaysCount,
    );
  }

  //===========================================================================
  // Split type
  //===========================================================================

  SplitType _splitType(
    List<MuscleSplit> splits,
  ) {
    final names = splits.map((split) => split.name.toLowerCase()).join(' ');

    if (names.contains('push') &&
        names.contains('pull') &&
        names.contains('legs')) {
      return SplitType.pushPullLegs;
    }

    if (names.contains('upper') && names.contains('lower')) {
      return SplitType.upperLower;
    }

    if (names.contains('chest') || names.contains('back')) {
      return SplitType.broSplit;
    }

    return SplitType.custom;
  }

  //===========================================================================
  // Program name
  //===========================================================================

  String _programName(
    int workoutDays,
    List<MuscleSplit> splits,
  ) {
    final splitNames =
        splits.take(workoutDays).map((split) => split.name).join('/');

    return '$workoutDays-Day $splitNames Split';
  }
}
