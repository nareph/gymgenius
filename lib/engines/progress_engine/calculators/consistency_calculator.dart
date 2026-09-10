import 'package:gymgenius/domain/entities/workout_consistency.dart';
import 'package:gymgenius/domain/entities/workout_log.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';
import 'package:gymgenius/engines/progress_engine/progress_thresholds.dart';

/// Computes training adherence against a DECLARED weekly frequency
/// target (from the user's profile), not a calendar of days planned
/// by whichever training program happens to be active right now.
class ConsistencyCalculator {
  const ConsistencyCalculator();

  /// [targetPerWeek] — from HealthProfile.training.frequency.toDays().
  WorkoutConsistency? calculate({
    required int targetPerWeek,
    required List<WorkoutLog> logs,
    required DateTime from,
    required DateTime to,
  }) {
    final fromDay = _dayKey(from);
    final toDay = _dayKey(to);

    final daysSpan = toDay.difference(fromDay).inDays + 1;
    final weeks = daysSpan / 7.0;

    final plannedWorkouts = (targetPerWeek * weeks).round();
    if (plannedWorkouts < ProgressThresholds.minPlannedWorkouts) {
      return null;
    }

    final completedDays = logs
        .where((l) => l.isCompleted)
        .map((l) => _dayKey(l.savedAt))
        .where((d) => !d.isBefore(fromDay) && !d.isAfter(toDay))
        .toSet();

    final completedWorkouts = completedDays.length;

    final rawScore = plannedWorkouts > 0
        ? (completedWorkouts / plannedWorkouts * 100).round()
        : 0;
    final score = rawScore.clamp(0, 100);

    final weeklyFrequency = weeks > 0 ? completedDays.length / weeks : 0.0;
    final consecutive = _consecutiveTrainingDays(completedDays, toDay);
    final trend = _trend(completedDays, fromDay, toDay, targetPerWeek);

    return WorkoutConsistency(
      plannedWorkouts: plannedWorkouts,
      completedWorkouts: completedWorkouts,
      consistencyScore: score,
      weeklyFrequency: weeklyFrequency,
      consecutiveTrainingDays: consecutive,
      trend: trend,
    );
  }

  /// Counts the most recent unbroken run of trained days.
  ///
  /// Previously always started counting from `to` (today) — if today
  /// had no log yet (the day may simply not be over), the loop's
  /// while-condition failed on its very first check and returned 0,
  /// discarding an otherwise perfect streak from prior days. Now: if
  /// today isn't logged, start from yesterday instead — an unlogged
  /// "today" no longer zeroes out yesterday's real streak. The streak
  /// only truly breaks once a full day is skipped.
  int _consecutiveTrainingDays(Set<DateTime> completed, DateTime to) {
    final todayKey = _dayKey(to);
    var day = completed.contains(todayKey)
        ? todayKey
        : todayKey.subtract(const Duration(days: 1));

    var count = 0;
    while (completed.contains(day)) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  TrendDirection _trend(
    Set<DateTime> completedDays,
    DateTime from,
    DateTime to,
    int targetPerWeek,
  ) {
    final mid = from.add(to.difference(from) ~/ 2);

    final firstHalfCompleted =
        completedDays.where((d) => !d.isAfter(mid)).length;
    final secondHalfCompleted = completedDays.length - firstHalfCompleted;

    final firstHalfDays = mid.difference(from).inDays + 1;
    final secondHalfDays = to.difference(mid).inDays;

    final firstHalfTarget = targetPerWeek * (firstHalfDays / 7.0);
    final secondHalfTarget = targetPerWeek * (secondHalfDays / 7.0);

    final firstRate =
        firstHalfTarget > 0 ? firstHalfCompleted / firstHalfTarget : 0.0;
    final secondRate =
        secondHalfTarget > 0 ? secondHalfCompleted / secondHalfTarget : 0.0;

    final delta = secondRate - firstRate;

    if (delta.abs() < 0.1) return TrendDirection.stable;
    return delta > 0 ? TrendDirection.gaining : TrendDirection.losing;
  }

  DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);
}

