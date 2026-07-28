// lib/domain/enums/workout_day.dart

enum WorkoutDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

extension WorkoutDayExtension on WorkoutDay {
  String get displayName {
    switch (this) {
      case WorkoutDay.monday:
        return 'Monday';
      case WorkoutDay.tuesday:
        return 'Tuesday';
      case WorkoutDay.wednesday:
        return 'Wednesday';
      case WorkoutDay.thursday:
        return 'Thursday';
      case WorkoutDay.friday:
        return 'Friday';
      case WorkoutDay.saturday:
        return 'Saturday';
      case WorkoutDay.sunday:
        return 'Sunday';
    }
  }

  String get value {
    switch (this) {
      case WorkoutDay.monday:
        return 'monday';
      case WorkoutDay.tuesday:
        return 'tuesday';
      case WorkoutDay.wednesday:
        return 'wednesday';
      case WorkoutDay.thursday:
        return 'thursday';
      case WorkoutDay.friday:
        return 'friday';
      case WorkoutDay.saturday:
        return 'saturday';
      case WorkoutDay.sunday:
        return 'sunday';
    }
  }

  static WorkoutDay fromValue(String value) {
    return WorkoutDay.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WorkoutDay.monday,
    );
  }
}
