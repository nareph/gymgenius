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
/// Generates a complete [TrainingProgram] from:
///
/// • HealthProfile
/// • validated weekly workout splits
/// • workout frequency
/// • previous program
///
/// The generator does NOT decide which split should be used.
/// That responsibility belongs to the planner layer.
///
/// The generator receives the final validated split structure and simply
/// maps each split to the corresponding workout day.
///
/// Exercise selection and workout composition remain delegated to
/// [WorkoutDayGenerator].
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
    // Normalize the final split list
    //
    // The planner is responsible for producing a coherent list, but this
    // guard prevents an invalid list length from causing silent generation
    // gaps.
    //-----------------------------------------------------------------------

    final normalizedSplits = _normalizeSplits(
      selectedSplit,
      workoutDays.length,
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

    for (var i = 0;
        i < workoutDays.length && i < normalizedSplits.length;
        i++) {
      final day = workoutDays[i];
      final split = normalizedSplits[i];

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
        workoutDays: workoutDays.length,
        splits: normalizedSplits,
      ),
      goal: training.goal,
      split: _splitType(normalizedSplits),
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
      final preferredDays = training.preferredDays
          .map((day) => day.name)
          .where(WorkoutConstants.daysOfWeek.contains)
          .toList();

      if (preferredDays.isNotEmpty) {
        return preferredDays.take(7).toList();
      }
    }

    return WorkoutConstants.defaultWorkoutDays(
      workoutDaysCount.clamp(1, 7),
    );
  }

  //===========================================================================
  // Split normalization
  //===========================================================================

  /// Ensures the final split list contains exactly one split per generated
  /// workout day.
  ///
  /// In normal operation the planner already guarantees this. This method
  /// exists as a defensive boundary so the generator never silently creates
  /// empty workout days because the planner returned too few splits.
  List<MuscleSplit> _normalizeSplits(
    List<MuscleSplit> splits,
    int workoutDays,
  ) {
    if (workoutDays <= 0 || splits.isEmpty) {
      return const [];
    }

    final result = <MuscleSplit>[];

    for (var i = 0; i < workoutDays; i++) {
      result.add(
        splits[i % splits.length],
      );
    }

    return result;
  }

  //===========================================================================
  // Split type
  //===========================================================================

  SplitType _splitType(
    List<MuscleSplit> splits,
  ) {
    if (splits.isEmpty) {
      return SplitType.custom;
    }

    final names = splits.map((split) => split.name.toLowerCase()).join(' ');

    //-----------------------------------------------------------------------
    // Specialized focus split
    //-----------------------------------------------------------------------

    if (splits.every(
      (split) => split.name.startsWith('Focused:'),
    )) {
      return SplitType.custom;
    }

    //-----------------------------------------------------------------------
    // Push / Pull / Legs
    //-----------------------------------------------------------------------

    if (names.contains('push') &&
        names.contains('pull') &&
        names.contains('legs')) {
      return SplitType.pushPullLegs;
    }

    //-----------------------------------------------------------------------
    // Upper / Lower
    //-----------------------------------------------------------------------

    if (names.contains('upper') && names.contains('lower')) {
      return SplitType.upperLower;
    }

    //-----------------------------------------------------------------------
    // Traditional body-part split
    //-----------------------------------------------------------------------

    if (names.contains('chest') ||
        names.contains('back') ||
        names.contains('arms')) {
      return SplitType.broSplit;
    }

    return SplitType.custom;
  }

  //===========================================================================
  // Program name
  //===========================================================================

  String _programName({
    required int workoutDays,
    required List<MuscleSplit> splits,
  }) {
    if (splits.isEmpty) {
      return '$workoutDays-Day Custom Split';
    }

    final splitNames =
        splits.take(workoutDays).map((split) => split.name).join('/');

    return '$workoutDays-Day $splitNames Split';
  }
}
