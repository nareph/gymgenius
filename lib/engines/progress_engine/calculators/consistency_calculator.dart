import 'package:gymgenius/domain/entities/workout_consistency.dart';
import 'package:gymgenius/domain/entities/workout_log.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';
import 'package:gymgenius/engines/progress_engine/progress_thresholds.dart';

/// Computes training adherence from planned vs completed workouts.
class ConsistencyCalculator {
  const ConsistencyCalculator();

  WorkoutConsistency? calculate({
    required Set<DateTime> plannedDates,
    required List<WorkoutLog> logs,
    required DateTime from,
    required DateTime to,
  }) {
    final fromDay = _dayKey(from);
    final toDay = _dayKey(to);

    final plannedInWindow = plannedDates.where((d) {
      final day = _dayKey(d);
      return !day.isBefore(fromDay) && !day.isAfter(toDay);
    }).toSet();

    if (plannedInWindow.length < ProgressThresholds.minPlannedWorkouts) {
      return null;
    }

    final completedDays = logs
        .where((l) => l.completionScore > 0)
        .map((l) => _dayKey(l.savedAt))
        .where((d) => !d.isBefore(fromDay) && !d.isAfter(toDay))
        .toSet();

    final completedOnPlanned =
        plannedInWindow.where(completedDays.contains).length;

    final completionRate = plannedInWindow.isNotEmpty
        ? completedOnPlanned / plannedInWindow.length
        : 0.0;

    final score = (completionRate * 100).round().clamp(0, 100);
    final daysSpan = toDay.difference(fromDay).inDays + 1;
    final weeks = daysSpan / 7.0;
    final weeklyFrequency = weeks > 0 ? completedDays.length / weeks : 0.0;
    final consecutive = _consecutiveTrainingDays(completedDays, toDay);
    final trend = _trend(plannedInWindow, completedDays, fromDay, toDay);

    return WorkoutConsistency(
      plannedWorkouts: plannedInWindow.length,
      completedWorkouts: completedOnPlanned,
      consistencyScore: score,
      weeklyFrequency: weeklyFrequency,
      consecutiveTrainingDays: consecutive,
      trend: trend,
    );
  }

  int _consecutiveTrainingDays(Set<DateTime> completed, DateTime to) {
    var count = 0;
    var day = _dayKey(to);

    while (completed.contains(day)) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  TrendDirection _trend(
    Set<DateTime> planned,
    Set<DateTime> completed,
    DateTime from,
    DateTime to,
  ) {
    final mid = from.add(to.difference(from) ~/ 2);
    final firstHalfPlanned =
        planned.where((d) => d.isBefore(mid) || _sameDay(d, mid)).length;
    final secondHalfPlanned = planned.length - firstHalfPlanned;

    final firstHalfCompleted = completed
        .where((d) => d.isBefore(mid) || _sameDay(d, mid))
        .where(planned.contains)
        .length;
    final secondHalfCompleted =
        completed.where(planned.contains).length - firstHalfCompleted;

    if (firstHalfPlanned == 0 || secondHalfPlanned == 0) {
      final rate = planned.isNotEmpty
          ? completed.where(planned.contains).length / planned.length
          : 0.0;
      if (rate >= ProgressThresholds.irregularWeekCompletionRate) {
        return TrendDirection.stable;
      }
      return TrendDirection.losing;
    }

    final firstRate = firstHalfCompleted / firstHalfPlanned;
    final secondRate = secondHalfCompleted / secondHalfPlanned;
    final delta = secondRate - firstRate;

    if (delta.abs() < 0.1) return TrendDirection.stable;
    return delta > 0 ? TrendDirection.gaining : TrendDirection.losing;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);
}
