import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/models/workout_days_result.dart';
import 'package:gymgenius/engines/workout_engine/shared/workout_constants.dart';

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
      final maxFreq =
          freqParts.length > 1 ? (freqParts[1] ?? minFreq) : minFreq;

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
      actualWorkoutDaysCount = preferredDaysSelected ? preferredDays.length : 3;
      actualWorkoutDaysCount =
          actualWorkoutDaysCount < WorkoutConstants.daysOfWeek.length
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
          muscles: [
            MuscleGroup.chest,
            MuscleGroup.back,
            MuscleGroup.shoulders,
            MuscleGroup.biceps,
            MuscleGroup.triceps,
            MuscleGroup.absCore,
          ],
          theme: 'Full Upper Body',
        ),
        const MuscleSplit(
          name: 'Lower Body',
          muscles: [
            MuscleGroup.quadriceps,
            MuscleGroup.hamstrings,
            MuscleGroup.glutes,
            MuscleGroup.calves,
            MuscleGroup.absCore,
          ],
          theme: 'Full Lower Body',
        ),
      ],
      '3_day': [
        const MuscleSplit(
          name: 'Push',
          muscles: [
            MuscleGroup.chest,
            MuscleGroup.shoulders,
            MuscleGroup.triceps,
            MuscleGroup.absCore,
          ],
          theme: 'Push Day - Chest, Shoulders, Triceps',
        ),
        const MuscleSplit(
          name: 'Pull',
          muscles: [
            MuscleGroup.back,
            MuscleGroup.shoulders,
            MuscleGroup.biceps,
            MuscleGroup.forearms,
          ],
          theme: 'Pull Day - Back, Biceps',
        ),
        const MuscleSplit(
          name: 'Legs',
          muscles: [
            MuscleGroup.quadriceps,
            MuscleGroup.hamstrings,
            MuscleGroup.glutes,
            MuscleGroup.calves,
            MuscleGroup.absCore,
          ],
          theme: 'Leg Day - Legs, Glutes',
        ),
      ],
      '4_day': [
        const MuscleSplit(
          name: 'Chest & Triceps',
          muscles: [
            MuscleGroup.chest,
            MuscleGroup.triceps,
            MuscleGroup.shoulders,
          ],
          theme: 'Chest & Triceps',
        ),
        const MuscleSplit(
          name: 'Back & Biceps',
          muscles: [
            MuscleGroup.back,
            MuscleGroup.shoulders,
            MuscleGroup.biceps,
            MuscleGroup.forearms,
          ],
          theme: 'Back & Biceps',
        ),
        const MuscleSplit(
          name: 'Legs',
          muscles: [
            MuscleGroup.quadriceps,
            MuscleGroup.hamstrings,
            MuscleGroup.glutes,
            MuscleGroup.calves,
          ],
          theme: 'Full Legs',
        ),
        const MuscleSplit(
          name: 'Shoulders & Core',
          muscles: [
            MuscleGroup.shoulders,
            MuscleGroup.absCore,
            MuscleGroup.traps,
          ],
          theme: 'Shoulders & Core',
        ),
      ],
      '5_day': [
        const MuscleSplit(
          name: 'Chest',
          muscles: [MuscleGroup.chest, MuscleGroup.shoulders],
          theme: 'Chest Focus',
        ),
        const MuscleSplit(
          name: 'Back',
          muscles: [MuscleGroup.back, MuscleGroup.shoulders],
          theme: 'Back Focus',
        ),
        const MuscleSplit(
          name: 'Legs',
          muscles: [
            MuscleGroup.quadriceps,
            MuscleGroup.hamstrings,
            MuscleGroup.glutes,
          ],
          theme: 'Legs Focus',
        ),
        const MuscleSplit(
          name: 'Arms',
          muscles: [
            MuscleGroup.biceps,
            MuscleGroup.triceps,
            MuscleGroup.forearms,
          ],
          theme: 'Arms Focus',
        ),
        const MuscleSplit(
          name: 'Shoulders & Core',
          muscles: [
            MuscleGroup.shoulders,
            MuscleGroup.absCore,
            MuscleGroup.traps,
            MuscleGroup.calves,
          ],
          theme: 'Shoulders & Core Finisher',
        ),
      ],
    };
  }
}
