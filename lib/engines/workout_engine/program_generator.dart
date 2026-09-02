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
/// The generator receives the final validated split structure and maps each
/// split to the corresponding workout day.
///
/// Exercise selection and workout composition remain delegated to
/// [WorkoutDayGenerator].
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

    if (workoutDays.isEmpty) {
      return _buildProgram(
        profile: profile,
        training: training,
        workoutDays: const [],
        splits: const [],
        weeklySchedule: {
          for (final day in WorkoutConstants.daysOfWeek) day: <Exercise>[],
        },
      );
    }

    //-----------------------------------------------------------------------
    // Validate split/day cardinality
    //
    // The planner is responsible for generating exactly one split per workout
    // day. We do not silently recycle an existing split when the lengths do
    // not match.
    //-----------------------------------------------------------------------

    final normalizedSplits = _normalizeSplits(
      selectedSplit,
      workoutDays.length,
    );

    if (normalizedSplits.isEmpty) {
      return _buildProgram(
        profile: profile,
        training: training,
        workoutDays: workoutDays,
        splits: const [],
        weeklySchedule: {
          for (final day in WorkoutConstants.daysOfWeek) day: <Exercise>[],
        },
      );
    }

    //-----------------------------------------------------------------------
    // Initialize weekly schedule
    //-----------------------------------------------------------------------

    final weeklySchedule = <String, List<Exercise>>{
      for (final day in WorkoutConstants.daysOfWeek) day: <Exercise>[],
    };

    //-----------------------------------------------------------------------
    // Track used canonical exercise IDs across the complete week.
    //
    // This prevents:
    //
    // Monday    -> exercise A
    // Tuesday   -> exercise B
    // Wednesday -> exercise A
    //
    // whenever another suitable candidate exists.
    //-----------------------------------------------------------------------

    final weeklyUsedExerciseIds = <String>{};

    //-----------------------------------------------------------------------
    // Generate each workout day
    //-----------------------------------------------------------------------

    for (var i = 0;
        i < workoutDays.length && i < normalizedSplits.length;
        i++) {
      final day = workoutDays[i];
      final split = normalizedSplits[i];

      final dayExercises = _dayGenerator.generate(
        split: split,
        profile: profile,
        previousProgram: previousProgram,
        excludeMuscles: excludeMuscles,
        intensityOverride: intensityOverride,
        weeklyUsedExerciseIds: weeklyUsedExerciseIds,
      );

      weeklySchedule[day] = dayExercises;

      //---------------------------------------------------------------------
      // Register canonical exercise IDs for subsequent days.
      //---------------------------------------------------------------------

      for (final exercise in dayExercises) {
        weeklyUsedExerciseIds.add(
          exercise.id,
        );
      }
    }

    return _buildProgram(
      profile: profile,
      training: training,
      workoutDays: workoutDays,
      splits: normalizedSplits,
      weeklySchedule: weeklySchedule,
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
          .where(
            WorkoutConstants.daysOfWeek.contains,
          )
          .toList();

      if (preferredDays.isNotEmpty) {
        return preferredDays.take(7).toList();
      }
    }

    final count = workoutDaysCount.clamp(1, 7);

    return WorkoutConstants.defaultWorkoutDays(
      count,
    );
  }

  //===========================================================================
  // Split normalization / validation
  //===========================================================================

  /// Validates the split list against the number of workout days.
  ///
  /// The planner should always return exactly one split per workout day.
  ///
  /// We intentionally do NOT recycle splits with modulo because doing so can
  /// silently transform:
  ///
  ///     6 splits / 7 days
  ///
  /// into:
  ///
  ///     split1 / split2 / ... / split6 / split1
  ///
  /// which would hide a planner bug.
  List<MuscleSplit> _normalizeSplits(
    List<MuscleSplit> splits,
    int workoutDays,
  ) {
    if (workoutDays <= 0) {
      return const [];
    }

    if (splits.length != workoutDays) {
      return const [];
    }

    return List<MuscleSplit>.unmodifiable(
      splits,
    );
  }

  //===========================================================================
  // Program construction
  //===========================================================================

  TrainingProgram _buildProgram({
    required HealthProfile profile,
    required WorkoutPreferences training,
    required List<String> workoutDays,
    required List<MuscleSplit> splits,
    required Map<String, List<Exercise>> weeklySchedule,
  }) {
    final durationWeeks = OverloadRules.programDurationWeeks(
      training.experience.name,
      0,
    );

    final now = DateTime.now();

    return TrainingProgram(
      id: '',
      userId: profile.userId,
      name: _programName(
        workoutDays: workoutDays.length,
        splits: splits,
      ),
      goal: training.goal,
      split: _splitType(splits),
      experience: training.experience,
      durationWeeks: durationWeeks,
      weeklySchedule: weeklySchedule,
      generatorType: GeneratorType.local,
      generatorVersion: '3.1.0',
      createdAt: now,
      expiresAt: now.add(
        Duration(
          days: durationWeeks * 7,
        ),
      ),
    );
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

    final normalizedNames = splits
        .map(
          (split) => split.name.toLowerCase(),
        )
        .toList();

    final names = normalizedNames.join(' ');

    //-----------------------------------------------------------------------
    // Focused / specialized program
    //-----------------------------------------------------------------------

    if (splits.every(
      (split) => split.name.toLowerCase().startsWith('focused:'),
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

    final splitNames = splits
        .take(workoutDays)
        .map(
          (split) => split.name,
        )
        .join('/');

    return '$workoutDays-Day $splitNames Split';
  }
}
