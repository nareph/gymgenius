import 'package:gymgenius/domain/enums/habit_frequency.dart';

class Habit {
  final String id;
  final String userId;
  final String name;
  final HabitFrequency frequency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.frequency,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isValid => userId.isNotEmpty && name.trim().isNotEmpty;

  Habit copyWith({
    String? name,
    HabitFrequency? frequency,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id,
      userId: userId,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Habit($name, ${frequency.value}, active: $isActive)';
}
