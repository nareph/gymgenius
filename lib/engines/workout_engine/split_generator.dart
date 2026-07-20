import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/models/workout_days_result.dart';
import 'package:gymgenius/engines/workout_engine/shared/workout_constants.dart';

/// Determines muscle splits and workout day scheduling.
class SplitGenerator {
  SplitGenerator._();

  static List<MuscleSplit> determineMuscleSplit(
    int workoutDaysCount,
    String experience,
  ) {
    final splits = _muscleSplits;

    if (workoutDaysCount <= 2) {
      return splits['2_day']!;
    } else if (workoutDaysCount == 3) {
      return splits['3_day']!;
    } else if (workoutDaysCount == 4) {
      return splits['4_day']!;
    } else if (workoutDaysCount >= 5) {
      if (experience == 'intermediate' ||
          experience == 'advanced' ||
          experience == 'expert') {
        return splits['5_day']!;
      }
      return splits['4_day']!;
    }
    return splits['3_day']!;
  }

  static WorkoutDaysResult calculateWorkoutDays({
    String? frequency,
    List<String>? preferredDays,
  }) {
    int actualWorkoutDaysCount = 0;
    bool useSpecifiedDays = false;
    final preferredDaysSelected =
        preferredDays != null && preferredDays.isNotEmpty;

    if (frequency != null) {
      final freqParts = frequency.split('-').map(int.tryParse).toList();
      final minFreq = freqParts[0] ?? 1;
      final maxFreq = freqParts.length > 1 ? (freqParts[1] ?? minFreq) : minFreq;

      if (preferredDaysSelected) {
        final numSelectedDays = preferredDays.length;
        if (numSelectedDays >= minFreq && numSelectedDays <= maxFreq) {
          actualWorkoutDaysCount = numSelectedDays;
          useSpecifiedDays = true;
        } else {
          actualWorkoutDaysCount = maxFreq < WorkoutConstants.daysOfWeek.length
              ? maxFreq
              : WorkoutConstants.daysOfWeek.length;
        }
      } else {
        actualWorkoutDaysCount = maxFreq < WorkoutConstants.daysOfWeek.length
            ? maxFreq
            : WorkoutConstants.daysOfWeek.length;
      }
    } else {
      actualWorkoutDaysCount =
          preferredDaysSelected ? preferredDays.length : 3;
      actualWorkoutDaysCount = actualWorkoutDaysCount <
              WorkoutConstants.daysOfWeek.length
          ? actualWorkoutDaysCount
          : WorkoutConstants.daysOfWeek.length;
      if (preferredDaysSelected) useSpecifiedDays = true;
    }

    actualWorkoutDaysCount =
        actualWorkoutDaysCount > 0 ? actualWorkoutDaysCount : 1;

    return WorkoutDaysResult(
      count: actualWorkoutDaysCount,
      useSpecifiedDays: useSpecifiedDays,
    );
  }

  static Map<String, List<MuscleSplit>> get _muscleSplits {
    return {
      '2_day': [
        const MuscleSplit(
          name: 'Upper Body',
          muscles: ['Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 'Core'],
          theme: 'Full Upper Body',
        ),
        const MuscleSplit(
          name: 'Lower Body',
          muscles: ['Quadriceps', 'Hamstrings', 'Glutes', 'Calves', 'Core'],
          theme: 'Full Lower Body',
        ),
      ],
      '3_day': [
        const MuscleSplit(
          name: 'Push',
          muscles: ['Chest', 'Shoulders', 'Triceps', 'Core'],
          theme: 'Push Day - Chest, Shoulders, Triceps',
        ),
        const MuscleSplit(
          name: 'Pull',
          muscles: ['Back', 'Lats', 'Biceps', 'Rear Delts'],
          theme: 'Pull Day - Back, Biceps',
        ),
        const MuscleSplit(
          name: 'Legs',
          muscles: ['Quadriceps', 'Hamstrings', 'Glutes', 'Calves', 'Core'],
          theme: 'Leg Day - Legs, Glutes',
        ),
      ],
      '4_day': [
        const MuscleSplit(
          name: 'Chest & Triceps',
          muscles: ['Chest', 'Triceps', 'Front Delts'],
          theme: 'Chest & Triceps',
        ),
        const MuscleSplit(
          name: 'Back & Biceps',
          muscles: ['Back', 'Lats', 'Biceps', 'Rear Delts'],
          theme: 'Back & Biceps',
        ),
        const MuscleSplit(
          name: 'Legs',
          muscles: ['Quadriceps', 'Hamstrings', 'Glutes', 'Calves'],
          theme: 'Full Legs',
        ),
        const MuscleSplit(
          name: 'Shoulders & Core',
          muscles: ['Shoulders', 'Core', 'Traps'],
          theme: 'Shoulders & Core',
        ),
      ],
      '5_day': [
        const MuscleSplit(
          name: 'Chest',
          muscles: ['Chest', 'Front Delts'],
          theme: 'Chest Focus',
        ),
        const MuscleSplit(
          name: 'Back',
          muscles: ['Back', 'Lats', 'Rear Delts'],
          theme: 'Back Focus',
        ),
        const MuscleSplit(
          name: 'Legs',
          muscles: ['Quadriceps', 'Hamstrings', 'Glutes'],
          theme: 'Legs Focus',
        ),
        const MuscleSplit(
          name: 'Arms',
          muscles: ['Biceps', 'Triceps', 'Forearms'],
          theme: 'Arms Focus',
        ),
        const MuscleSplit(
          name: 'Shoulders & Core',
          muscles: ['Shoulders', 'Core', 'Traps', 'Calves'],
          theme: 'Shoulders & Core Finisher',
        ),
      ],
    };
  }
}
