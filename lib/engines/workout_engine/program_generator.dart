import 'dart:math';

import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/generator_type.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/program_phase.dart';
import 'package:gymgenius/domain/enums/split_type.dart';
import 'package:gymgenius/domain/value_objects/workout_preferences.dart';

import 'package:gymgenius/engines/workout_engine/generators/workout_day_generator.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/overload/overload_rules.dart';
import 'package:gymgenius/engines/workout_engine/shared/workout_constants.dart';

class ProgramGenerator {
  ProgramGenerator({
    Random? random,
  })  : _random = random ?? Random(),
        _dayGenerator = WorkoutDayGenerator(
          random: random,
        );

  final Random _random;
  final WorkoutDayGenerator _dayGenerator;

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

    final workoutDays = _resolveWorkoutDays(
      training: training,
      workoutDaysCount: workoutDaysCount,
      useSpecifiedDays: useSpecifiedDays,
    );

    final weeklySchedule = <String, List<Exercise>>{
      for (final day in WorkoutConstants.daysOfWeek) day: <Exercise>[],
    };

    for (var i = 0; i < workoutDays.length && i < selectedSplit.length; i++) {
      weeklySchedule[workoutDays[i]] = _dayGenerator.generate(
        split: selectedSplit[i],
        profile: profile,
        previousProgram: previousProgram,
        excludeMuscles: excludeMuscles,
        intensityOverride: intensityOverride,
      );
    }

    final now = DateTime.now();

    final durationWeeks = OverloadRules.programDurationWeeks(
      training.experience.name,
      _random.nextInt(3),
    );

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
      programPhase: ProgramPhase.base,
      mesocycle: 1,
      microcycle: 1,
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

  List<String> _resolveWorkoutDays({
    required WorkoutPreferences training,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
  }) {
    if (useSpecifiedDays && training.preferredDays.isNotEmpty) {
      return training.preferredDays.map((e) => e.name).toList();
    }

    return WorkoutConstants.defaultWorkoutDays(
      workoutDaysCount,
    );
  }

  SplitType _splitType(
    List<MuscleSplit> splits,
  ) {
    final names = splits.map((e) => e.name.toLowerCase()).join(' ');

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

  String _programName(
    int workoutDays,
    List<MuscleSplit> splits,
  ) {
    const prefixes = [
      'Progressive',
      'Ultimate',
      'Complete',
      'Dynamic',
      'Performance',
    ];

    final prefix = prefixes[_random.nextInt(prefixes.length)];

    final splitNames = splits.take(workoutDays).map((e) => e.name).join('/');

    return '$prefix $workoutDays-Day $splitNames Split';
  }
}
