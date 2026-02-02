// lib/services/ai/routine_validator.dart

/// Validates and normalizes routine data
/// This ensures consistency whether data comes from local generation or AI API
class RoutineValidator {
  static const _daysOfWeek = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday"
  ];

  /// Validate and normalize routine structure
  static Map<String, dynamic> validateAndNormalize(
      Map<String, dynamic> routine) {
    // Validate top-level structure
    if (routine['name'] == null ||
        routine['name'].toString().isEmpty ||
        routine['durationInWeeks'] == null ||
        routine['durationInWeeks'] <= 0 ||
        routine['dailyWorkouts'] == null) {
      throw RoutineValidationException(
          'Invalid routine structure: missing required fields');
    }

    // Normalize daily workouts
    final dailyWorkouts = routine['dailyWorkouts'] as Map<String, dynamic>;
    final normalizedDailyWorkouts = <String, List<Map<String, dynamic>>>{};

    for (final day in _daysOfWeek) {
      if (dailyWorkouts.containsKey(day)) {
        final exercises = dailyWorkouts[day];
        if (exercises is List) {
          normalizedDailyWorkouts[day] = exercises
              .cast<Map<String, dynamic>>()
              .map(_normalizeExercise)
              .toList();
        } else {
          normalizedDailyWorkouts[day] = [];
        }
      } else {
        normalizedDailyWorkouts[day] = [];
      }
    }

    return {
      'name': routine['name'].toString(),
      'durationInWeeks': (routine['durationInWeeks'] as num).toInt(),
      'dailyWorkouts': normalizedDailyWorkouts,
    };
  }

  /// Normalize a single exercise
  static Map<String, dynamic> _normalizeExercise(
      Map<String, dynamic> exercise) {
    return {
      'name': exercise['name']?.toString() ?? 'Unnamed Exercise',
      'sets': (exercise['sets'] as num?)?.toInt() ?? 3,
      'reps': exercise['reps']?.toString() ?? '8-12',
      'weightSuggestionKg': exercise['weightSuggestionKg']?.toString() ?? 'N/A',
      'restBetweenSetsSeconds':
          (exercise['restBetweenSetsSeconds'] as num?)?.toInt() ?? 60,
      'description':
          exercise['description']?.toString() ?? 'No description available.',
      'usesWeight': (exercise['usesWeight'] as bool?) ?? false,
      'isTimed': (exercise['isTimed'] as bool?) ?? false,
      if (exercise['isTimed'] == true &&
          exercise['targetDurationSeconds'] != null)
        'targetDurationSeconds':
            (exercise['targetDurationSeconds'] as num?)?.toInt(),
    };
  }

  /// Validate that all required days have workouts
  static void validateWorkoutDays(
    Map<String, dynamic> routine,
    List<String> expectedDays,
  ) {
    final dailyWorkouts = routine['dailyWorkouts'] as Map<String, dynamic>;

    for (final day in expectedDays) {
      if (!dailyWorkouts.containsKey(day)) {
        throw RoutineValidationException('Missing workout for day: $day');
      }

      final exercises = dailyWorkouts[day] as List<dynamic>?;
      if (exercises == null || exercises.isEmpty) {
        throw RoutineValidationException('Empty workout for day: $day');
      }
    }
  }

  /// Validate exercise structure
  static void validateExercise(Map<String, dynamic> exercise) {
    final requiredFields = ['name', 'sets', 'reps'];

    for (final field in requiredFields) {
      if (!exercise.containsKey(field)) {
        throw RoutineValidationException(
            'Exercise missing required field: $field');
      }
    }

    // Validate types
    if (exercise['sets'] is! num || (exercise['sets'] as num) <= 0) {
      throw RoutineValidationException(
          'Invalid sets value: ${exercise['sets']}');
    }

    if (exercise['reps'] == null || exercise['reps'].toString().isEmpty) {
      throw RoutineValidationException('Invalid reps value');
    }
  }
}

/// Exception for routine validation errors
class RoutineValidationException implements Exception {
  final String message;
  RoutineValidationException(this.message);

  @override
  String toString() => 'RoutineValidationException: $message';
}
