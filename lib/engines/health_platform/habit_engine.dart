import 'package:gymgenius/domain/entities/habit.dart';
import 'package:gymgenius/domain/entities/habit_log.dart';
import 'package:gymgenius/domain/enums/habit_frequency.dart';

class HabitStats {
  final int activeCount;
  final int completedToday;
  final int completionPercent;
  final int longestCurrentStreak;
  final Map<String, int> streakByHabitId;
  final List<String> reasons;

  const HabitStats({
    required this.activeCount,
    required this.completedToday,
    required this.completionPercent,
    required this.longestCurrentStreak,
    this.streakByHabitId = const {},
    this.reasons = const [],
  });
}

class HabitEngine {
  const HabitEngine();

  HabitStats computeStats({
    required List<Habit> habits,
    required List<HabitLog> logs,
    required DateTime day,
  }) {
    final dayKey = DateTime(day.year, day.month, day.day);
    final active = habits.where((h) => h.isActive).toList();
    if (active.isEmpty) {
      return const HabitStats(
        activeCount: 0,
        completedToday: 0,
        completionPercent: 0,
        longestCurrentStreak: 0,
        reasons: ['No active habits'],
      );
    }

    final weekStart = dayKey.subtract(Duration(days: dayKey.weekday - 1));

    // Previously this went through a `dueToday` list that EXCLUDED a
    // weekly habit once it had already been completed this week (it
    // was meant to answer "does this still need action?"), then
    // counted completions as the intersection of `dueToday` and
    // "completed today" logs. That's a self-defeating definition for
    // weekly habits: completing one removes it from `dueToday`, so it
    // could never be counted in `completedToday` — the header stayed
    // stuck at e.g. "0/1" even right after saving a completion.
    //
    // completedToday now directly asks each active habit "is it
    // completed for its current period?" (today for daily, this
    // calendar week for weekly) — no intermediate "still due" list to
    // accidentally exclude it from its own count.
    final completedToday = active
        .where((h) => _isCompletedForCurrentPeriod(h, logs, dayKey, weekStart))
        .length;

    final percent =
        active.isEmpty ? 100 : ((completedToday / active.length) * 100).round();

    final streaks = <String, int>{};
    var longest = 0;
    for (final habit in active) {
      final streak = _currentStreak(habit, logs, dayKey);
      streaks[habit.id] = streak;
      if (streak > longest) longest = streak;
    }

    return HabitStats(
      activeCount: active.length,
      completedToday: completedToday,
      completionPercent: percent.clamp(0, 100),
      longestCurrentStreak: longest,
      streakByHabitId: streaks,
      reasons: [
        '$completedToday/${active.length} habits done today',
        if (longest > 0) 'Longest current streak: $longest days',
      ],
    );
  }

  bool _isCompletedForCurrentPeriod(
    Habit habit,
    List<HabitLog> logs,
    DateTime dayKey,
    DateTime weekStart,
  ) {
    if (habit.frequency == HabitFrequency.daily) {
      return logs.any(
        (l) => l.habitId == habit.id && l.completed && l.dayKey == dayKey,
      );
    }

    // Weekly: completed if there's any completion from the start of
    // this calendar week through today.
    return logs.any(
      (l) =>
          l.habitId == habit.id &&
          l.completed &&
          !l.dayKey.isBefore(weekStart) &&
          !l.dayKey.isAfter(dayKey),
    );
  }

  int _currentStreak(Habit habit, List<HabitLog> logs, DateTime dayKey) {
    if (habit.frequency == HabitFrequency.weekly) {
      // Weekly streak = consecutive weeks with ≥1 completion.
      var streak = 0;
      var cursor = dayKey;
      while (true) {
        final weekStart = cursor.subtract(Duration(days: cursor.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final hit = logs.any(
          (l) =>
              l.habitId == habit.id &&
              l.completed &&
              !l.dayKey.isBefore(weekStart) &&
              !l.dayKey.isAfter(weekEnd),
        );
        if (!hit) break;
        streak++;
        cursor = weekStart.subtract(const Duration(days: 1));
      }
      return streak;
    }

    var streak = 0;
    var cursor = dayKey;
    while (true) {
      final hit = logs.any(
        (l) => l.habitId == habit.id && l.completed && l.dayKey == cursor,
      );
      if (!hit) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
