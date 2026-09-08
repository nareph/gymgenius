class HabitLog {
  final String id;
  final String userId;
  final String habitId;
  final DateTime date;
  final bool completed;

  /// Optional quantity logged for this completion (e.g. 8.0 for "8 km"
  /// on a habit whose [Habit.unit] is 'km'). Null for plain yes/no
  /// habits, or when the user didn't enter a value.
  final double? value;

  final DateTime loggedAt;

  const HabitLog({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.date,
    required this.completed,
    this.value,
    required this.loggedAt,
  });

  DateTime get dayKey => DateTime(date.year, date.month, date.day);

  bool get isValid => userId.isNotEmpty && habitId.isNotEmpty;

  @override
  String toString() => 'HabitLog($habitId @ $dayKey, completed: $completed'
      '${value != null ? ', value: $value' : ''})';
}
