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

    final todayLogs = logs.where((l) => l.dayKey == dayKey && l.completed);
    final completedIds = todayLogs.map((l) => l.habitId).toSet();
    final dueToday = active.where((h) {
      if (h.frequency == HabitFrequency.daily) return true;
      // Weekly: count as due if not completed yet this calendar week.
      final weekStart = dayKey.subtract(Duration(days: dayKey.weekday - 1));
      final weekLogs = logs.where(
        (l) =>
            l.habitId == h.id &&
            l.completed &&
            !l.dayKey.isBefore(weekStart) &&
            !l.dayKey.isAfter(dayKey),
      );
      return weekLogs.isEmpty;
    }).toList();

    final completedToday =
        dueToday.where((h) => completedIds.contains(h.id)).length;
    final percent = dueToday.isEmpty
        ? 100
        : ((completedToday / dueToday.length) * 100).round();

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
        '$completedToday/${dueToday.length} habits done today',
        if (longest > 0) 'Longest current streak: $longest days',
      ],
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
