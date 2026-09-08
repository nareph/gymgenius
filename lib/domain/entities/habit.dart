import 'package:gymgenius/domain/enums/habit_frequency.dart';

class Habit {
  final String id;
  final String userId;
  final String name;
  final HabitFrequency frequency;
  final bool isActive;

  /// Optional unit label (e.g. 'km', 'min', 'reps'). When set, this habit
  /// tracks a quantity each time it's completed — see [HabitLog.value].
  /// Null means it's a plain yes/no habit, the original behavior.
  final String? unit;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.frequency,
    this.isActive = true,
    this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isValid => userId.isNotEmpty && name.trim().isNotEmpty;

  /// Whether completing this habit should prompt for a quantity.
  bool get tracksValue => unit != null && unit!.trim().isNotEmpty;

  Habit copyWith({
    String? name,
    HabitFrequency? frequency,
    bool? isActive,
    String? unit,
    // Distinguishes "leave unit unchanged" (default) from
    // "explicitly clear the unit, make this a plain habit again" —
    // `unit: null` alone would be ambiguous between the two.
    bool clearUnit = false,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id,
      userId: userId,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      unit: clearUnit ? null : (unit ?? this.unit),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Habit($name, ${frequency.value}, active: $isActive'
      '${unit != null ? ', unit: $unit' : ''})';
}
