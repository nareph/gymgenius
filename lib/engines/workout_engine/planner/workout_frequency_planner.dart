import 'package:gymgenius/domain/enums/workout_frequency.dart';

import '../models/workout_days_result.dart';

/// Determines how many workout days should be generated.
///
/// Responsibilities:
///
/// • Interpret the user's selected workout frequency.
/// • Respect preferred workout days whenever possible.
/// • Never return zero workout days.
///
/// This class deliberately does **not** choose muscle splits.
/// That responsibility belongs to SplitPlanner.
class WorkoutFrequencyPlanner {
  const WorkoutFrequencyPlanner();

  WorkoutDaysResult calculateWorkoutDays({
    required WorkoutFrequency frequency,
    required List<String> preferredDays,
  }) {
    final preferredSelected = preferredDays.isNotEmpty;

    final (minDays, maxDays) = _frequencyRange(frequency);

    var workoutDays = maxDays;
    var useSpecifiedDays = false;

    if (preferredSelected) {
      final selected = preferredDays.length;
      workoutDays = selected.clamp(minDays, maxDays);
      useSpecifiedDays = selected >= minDays && selected <= maxDays;
    } else {
      workoutDays = minDays;
    }

    if (workoutDays < 1) {
      workoutDays = 1;
    }

    if (workoutDays > 7) {
      workoutDays = 7;
    }

    return WorkoutDaysResult(
      count: workoutDays,
      useSpecifiedDays: useSpecifiedDays,
    );
  }

  (int min, int max) _frequencyRange(
    WorkoutFrequency frequency,
  ) {
    switch (frequency) {
      case WorkoutFrequency.oneToTwo:
        return (1, 2);

      case WorkoutFrequency.threeToFour:
        return (3, 4);

      case WorkoutFrequency.fivePlus:
        return (5, 7);
    }
  }
}
