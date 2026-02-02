// lib/services/ai/muscle_split_calculator.dart
import 'package:gymgenius/services/ai/types.dart';

class MuscleSplitCalculator {
  static const _daysOfWeek = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday"
  ];

  static List<MuscleSplit> determineMuscleSplit(
      int workoutDaysCount, String experience) {
    final splits = _getMuscleSplits();

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
      } else {
        return splits['4_day']!;
      }
    }
    return splits['3_day']!;
  }

  static Map<int, bool> calculateWorkoutDays({
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
          actualWorkoutDaysCount =
              (maxFreq < _daysOfWeek.length) ? maxFreq : _daysOfWeek.length;
        }
      } else {
        actualWorkoutDaysCount =
            (maxFreq < _daysOfWeek.length) ? maxFreq : _daysOfWeek.length;
      }
    } else {
      actualWorkoutDaysCount = preferredDaysSelected ? preferredDays.length : 3;
      actualWorkoutDaysCount = (actualWorkoutDaysCount < _daysOfWeek.length)
          ? actualWorkoutDaysCount
          : _daysOfWeek.length;
      if (preferredDaysSelected) useSpecifiedDays = true;
    }

    actualWorkoutDaysCount =
        actualWorkoutDaysCount > 0 ? actualWorkoutDaysCount : 1;
    return {actualWorkoutDaysCount: useSpecifiedDays};
  }

  static Map<String, List<MuscleSplit>> _getMuscleSplits() {
    return {
      '2_day': [
        MuscleSplit(
          name: 'Upper Body',
          muscles: ['Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 'Core'],
          theme: 'Full Upper Body',
        ),
        MuscleSplit(
          name: 'Lower Body',
          muscles: ['Quadriceps', 'Hamstrings', 'Glutes', 'Calves', 'Core'],
          theme: 'Full Lower Body',
        ),
      ],
      '3_day': [
        MuscleSplit(
          name: 'Push',
          muscles: ['Chest', 'Shoulders', 'Triceps', 'Core'],
          theme: 'Push Day - Chest, Shoulders, Triceps',
        ),
        MuscleSplit(
          name: 'Pull',
          muscles: ['Back', 'Lats', 'Biceps', 'Rear Delts'],
          theme: 'Pull Day - Back, Biceps',
        ),
        MuscleSplit(
          name: 'Legs',
          muscles: ['Quadriceps', 'Hamstrings', 'Glutes', 'Calves', 'Core'],
          theme: 'Leg Day - Legs, Glutes',
        ),
      ],
      '4_day': [
        MuscleSplit(
          name: 'Chest & Triceps',
          muscles: ['Chest', 'Triceps', 'Front Delts'],
          theme: 'Chest & Triceps',
        ),
        MuscleSplit(
          name: 'Back & Biceps',
          muscles: ['Back', 'Lats', 'Biceps', 'Rear Delts'],
          theme: 'Back & Biceps',
        ),
        MuscleSplit(
          name: 'Legs',
          muscles: ['Quadriceps', 'Hamstrings', 'Glutes', 'Calves'],
          theme: 'Full Legs',
        ),
        MuscleSplit(
          name: 'Shoulders & Core',
          muscles: ['Shoulders', 'Core', 'Traps'],
          theme: 'Shoulders & Core',
        ),
      ],
      '5_day': [
        MuscleSplit(
          name: 'Chest',
          muscles: ['Chest', 'Front Delts'],
          theme: 'Chest Focus',
        ),
        MuscleSplit(
          name: 'Back',
          muscles: ['Back', 'Lats', 'Rear Delts'],
          theme: 'Back Focus',
        ),
        MuscleSplit(
          name: 'Legs',
          muscles: ['Quadriceps', 'Hamstrings', 'Glutes'],
          theme: 'Legs Focus',
        ),
        MuscleSplit(
          name: 'Arms',
          muscles: ['Biceps', 'Triceps', 'Forearms'],
          theme: 'Arms Focus',
        ),
        MuscleSplit(
          name: 'Shoulders & Core',
          muscles: ['Shoulders', 'Core', 'Traps', 'Calves'],
          theme: 'Shoulders & Core Finisher',
        ),
      ],
    };
  }
}