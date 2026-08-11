/// Completion record for a habit on a calendar day.
class HabitLog {
  final String id;
  final String userId;
  final String habitId;
  final DateTime date;
  final bool completed;
  final DateTime loggedAt;

  const HabitLog({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.date,
    required this.completed,
    required this.loggedAt,
  });

  DateTime get dayKey => DateTime(date.year, date.month, date.day);

  bool get isValid =>
      userId.isNotEmpty && habitId.isNotEmpty;

  @override
  String toString() => 'HabitLog($habitId @ $dayKey, completed: $completed)';
}
