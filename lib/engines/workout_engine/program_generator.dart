// lib/engines/workout_engine/program_generator.dart

import 'dart:math';

import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/models/workout_profile.dart';
import 'package:gymgenius/engines/workout_engine/overload_rules.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';
import 'package:gymgenius/engines/workout_engine/shared/workout_constants.dart';
import 'package:gymgenius/engines/workout_engine/volume_calculator.dart';

class ProgramGenerator {
  ProgramGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  Map<String, dynamic> generate({
    required WorkoutProfile profile,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
  }) {
    final workoutDays = _resolveWorkoutDays(
      profile: profile,
      workoutDaysCount: workoutDaysCount,
      useSpecifiedDays: useSpecifiedDays,
    );

    final weeklySchedule = <String, List<Map<String, dynamic>>>{};
    for (final day in WorkoutConstants.daysOfWeek) {
      weeklySchedule[day] = [];
    }

    for (int i = 0; i < workoutDays.length && i < selectedSplit.length; i++) {
      weeklySchedule[workoutDays[i]] = _generateWorkoutDay(
        split: selectedSplit[i],
        profile: profile,
      );
    }

    return {
      'name': _generateProgramName(
        workoutDaysCount: workoutDaysCount,
        selectedSplit: selectedSplit,
      ),
      'durationInWeeks': OverloadRules.programDurationWeeks(
        profile.experience,
        _random.nextInt(3),
      ),
      'weeklySchedule': weeklySchedule,
    };
  }

  List<String> _resolveWorkoutDays({
    required WorkoutProfile profile,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
  }) {
    if (useSpecifiedDays && profile.workoutDays != null) {
      return profile.workoutDays!.map((d) => d.toLowerCase()).toList();
    }
    return WorkoutConstants.defaultWorkoutDays(workoutDaysCount);
  }

  List<Map<String, dynamic>> _generateWorkoutDay({
    required MuscleSplit split,
    required WorkoutProfile profile,
  }) {
    final exerciseCount = VolumeCalculator.exerciseCountForSession(
      profile.sessionDuration,
      _random.nextInt(3),
    );

    final allowedEquipment = profile.getEquipmentTypes();
    final focusMuscles = profile.focusAreas;

    // Retrieve exercises filtered and sorted by focus
    var allExercises = ExercisePool.getExercises(
      splitName: split.name,
      allowedEquipment: allowedEquipment,
      focusMuscles: focusMuscles,
    );

    // Fallback if no exercises found
    if (allExercises.isEmpty) {
      final fallback = ExercisePool.getExercises(
        splitName: split.name,
        allowedEquipment: [EquipmentType.bodyweight],
        focusMuscles: focusMuscles,
      );
      if (fallback.isNotEmpty) {
        allExercises = fallback;
      } else {
        // Ultimate fallback: generic exercise
        return [_createGenericExercise(split, profile)];
      }
    }

    // Select exercises
    List<Map<String, dynamic>> selected;
    if (focusMuscles != null && focusMuscles.isNotEmpty) {
      // Take top exercises (already sorted by score), take more for variety
      final top = allExercises.take(exerciseCount * 2).toList();
      top.shuffle(_random);
      selected = top.take(exerciseCount).toList();
    } else {
      final shuffled = List<Map<String, dynamic>>.from(allExercises)
        ..shuffle(_random);
      selected = shuffled.take(exerciseCount).toList();
    }

    return selected.map((exMap) {
      return _buildExerciseFromPoolEntry(exMap, split, profile);
    }).toList();
  }

  Map<String, dynamic> _buildExerciseFromPoolEntry(
    Map<String, dynamic> exerciseMap,
    MuscleSplit split,
    WorkoutProfile profile,
  ) {
    final sets = OverloadRules.setsForExperience(
      profile.experience,
      _random.nextInt(2),
    );
    final reps = OverloadRules.repsForExperience(
      profile.experience,
      exerciseMap['type'] as String?,
      profile.goal,
    );

    final description = exerciseMap['description'] as String? ??
        _generateDescription(
          exerciseName: exerciseMap['name'] as String,
          muscles: split.muscles,
          splitTheme: split.theme,
        );

    return {
      'name': exerciseMap['name'] as String,
      'sets': sets,
      'reps': reps,
      'weightSuggestionKg': exerciseMap['weightSuggestion'] ?? 'Bodyweight',
      'restBetweenSetsSeconds': 60 + _random.nextInt(60),
      'description': description,
      'usesWeight': exerciseMap['usesWeight'] as bool? ?? false,
      'isTimed': exerciseMap['isTimed'] as bool? ?? false,
    };
  }

  Map<String, dynamic> _createGenericExercise(
      MuscleSplit split, WorkoutProfile profile) {
    return {
      'name': 'Bodyweight Squat',
      'sets': 3,
      'reps': '8-12',
      'weightSuggestionKg': 'Bodyweight',
      'restBetweenSetsSeconds': 60,
      'description':
          '**Target: Legs | Split: ${split.theme}**\n\n1. Stand with feet apart.\n2. Squat down.\n3. Stand up.',
      'usesWeight': false,
      'isTimed': false,
    };
  }

  String _generateDescription({
    required String exerciseName,
    required List<String> muscles,
    required String splitTheme,
  }) {
    final primaryMuscles = muscles.take(3).join(', ');
    return '**Target: $primaryMuscles | Split: $splitTheme**\n\n'
        '1. Position yourself correctly for $exerciseName.\n'
        '2. Engage your core and maintain proper posture.\n'
        '3. Execute the movement with control, focusing on the target muscles.\n'
        '4. Complete the full range of motion.\n'
        '5. Return to starting position with control.';
  }

  String _generateProgramName({
    required int workoutDaysCount,
    required List<MuscleSplit> selectedSplit,
  }) {
    final splitNames =
        selectedSplit.map((s) => s.name).take(workoutDaysCount).toList();
    const prefixes = ['Progressive', 'Complete', 'Ultimate', 'Dynamic'];
    final prefix = prefixes[_random.nextInt(prefixes.length)];
    return '$prefix $workoutDaysCount-Day ${splitNames.join('/')} Split';
  }
}
