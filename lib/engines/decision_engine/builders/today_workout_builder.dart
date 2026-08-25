// lib/engines/workout_engine/services/today_workout_builder.dart

import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';

/// Builds the planned workout for the current day.
///
/// This class does not make decisions.
/// It simply extracts today's workout from the TrainingProgram.
class TodayWorkoutBuilder {
  const TodayWorkoutBuilder();

  /// Builds the planned workout with a given split display name.
  TodayWorkout build({
    required TrainingProgram program,
    required String splitDisplayName,
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();
    final dayKey = _dayKey(currentDate);

    final plannedExercises = List<Exercise>.from(
      program.weeklySchedule[dayKey] ?? const <Exercise>[],
    );

    return TodayWorkout(
      date: currentDate,
      dayKey: dayKey,
      plannedExercises: plannedExercises,
      finalExercises: List<Exercise>.from(plannedExercises),
      isAdapted: false,
      adjustments: const [],
      reasons: const [DecisionReason.scheduledWorkout],
      splitDisplayName: splitDisplayName,
    );
  }

  String _dayKey(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        throw StateError('Invalid weekday: ${date.weekday}');
    }
  }
}
