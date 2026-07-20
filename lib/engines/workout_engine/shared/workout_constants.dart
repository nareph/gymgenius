/// Shared constants for workout generation.
class WorkoutConstants {
  WorkoutConstants._();

  static const daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static List<String> defaultWorkoutDays(int count) {
    return switch (count) {
      2 => ['monday', 'thursday'],
      3 => ['monday', 'wednesday', 'friday'],
      4 => ['monday', 'tuesday', 'thursday', 'friday'],
      5 => ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      6 => [
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday',
        ],
      _ => ['monday', 'wednesday', 'friday'],
    };
  }
}
