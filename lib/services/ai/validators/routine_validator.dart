import 'package:gymgenius/services/logger_service.dart';

/// Validates and normalizes routine data from AI
///
/// This validator ensures all exercises have consistent properties.
/// The key rule: If reps contains time unit ('s', 'sec', 'min', ':'),
/// it's ALWAYS a timed exercise.
class RoutineValidator {
  static const _tag = 'RoutineValidator';

  /// Validates and normalizes a routine from AI
  static Map<String, dynamic> validateAndNormalize(
    Map<String, dynamic> routine,
  ) {
    try {
      // Ensure required fields
      if (!routine.containsKey('name') ||
          !routine.containsKey('durationInWeeks') ||
          !routine.containsKey('dailyWorkouts')) {
        throw Exception('Missing required fields in routine');
      }

      final dailyWorkouts = routine['dailyWorkouts'] as Map<String, dynamic>;
      final normalized = <String, dynamic>{};
      int timedExercisesCount = 0;

      for (final entry in dailyWorkouts.entries) {
        final day = entry.key.toLowerCase();
        final exercises = entry.value as List<dynamic>;

        normalized[day] = exercises.map((ex) {
          if (ex is! Map<String, dynamic>) {
            Log.warning('Invalid exercise format for day $day', tag: _tag);
            return <String, dynamic>{};
          }

          final normalizedEx = _normalizeExercise(ex);

          if (normalizedEx['isTimed'] == true) {
            timedExercisesCount++;
          }

          return normalizedEx;
        }).toList();
      }

      routine['dailyWorkouts'] = normalized;

      Log.info(
        'Routine validated: ${_countExercises(normalized)} exercises, '
        '$timedExercisesCount timed exercises',
        tag: _tag,
      );

      return routine;
    } catch (e, s) {
      Log.error('Routine validation failed',
          tag: _tag, error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Counts total exercises in normalized daily workouts
  static int _countExercises(Map<String, dynamic> dailyWorkouts) {
    int total = 0;
    for (final exercises in dailyWorkouts.values) {
      if (exercises is List) {
        total += exercises.length;
      }
    }
    return total;
  }

  /// Normalizes a single exercise with simple timed detection
  static Map<String, dynamic> _normalizeExercise(Map<String, dynamic> ex) {
    // Ensure basic required fields with defaults
    ex['name'] = ex['name'] ?? 'Unknown Exercise';
    ex['sets'] = (ex['sets'] as num?)?.toInt() ?? 3;
    ex['description'] = ex['description'] ?? 'No description available';
    ex['restBetweenSetsSeconds'] =
        (ex['restBetweenSetsSeconds'] as num?)?.toInt() ?? 60;

    final reps = (ex['reps'] ?? '8-12').toString().trim();
    final exerciseName = ex['name'].toString();
    ex['reps'] = reps;

    Log.debug(
      'Normalizing exercise: "$exerciseName" - reps: "$reps"',
      tag: _tag,
    );

    // === SIMPLE TIMED DETECTION ===
    // Rule: If reps contains time unit → it's a timed exercise
    final lowerReps = reps.toLowerCase();
    final isTimed = lowerReps.contains('s') ||
        lowerReps.contains('sec') ||
        lowerReps.contains('min') ||
        lowerReps.contains(':') ||
        lowerReps == 'hold';

    // Override AI's value with our detection
    final aiIsTimed = ex['isTimed'] as bool?;
    if (aiIsTimed != null && aiIsTimed != isTimed) {
      Log.debug(
        'Correcting isTimed for "$exerciseName": '
        'AI=$aiIsTimed → Corrected=$isTimed (reps="$reps")',
        tag: _tag,
      );
    }

    ex['isTimed'] = isTimed;

    // === HANDLE TIMED EXERCISES ===
    if (isTimed) {
      return _normalizeTimedExercise(ex, reps);
    } else {
      return _normalizeRepBasedExercise(ex);
    }
  }

  /// Normalizes a timed exercise
  static Map<String, dynamic> _normalizeTimedExercise(
    Map<String, dynamic> ex,
    String reps,
  ) {
    Log.debug('Normalizing TIMED exercise: ${ex['name']}', tag: _tag);

    // Parse duration from reps
    final duration = _parseDurationFromReps(reps);

    // Validate duration is reasonable (10s to 600s = 10 minutes)
    final validatedDuration = duration.clamp(10, 600);
    if (duration != validatedDuration) {
      Log.debug(
        'Adjusted duration for ${ex['name']}: $duration → $validatedDuration',
        tag: _tag,
      );
    }

    ex['targetDurationSeconds'] = validatedDuration;

    // Ensure reps format includes time unit for clarity
    if (!reps.contains('s') && !reps.contains('sec') && !reps.contains('min')) {
      ex['reps'] = '${validatedDuration}s';
    }

    // Timed exercises are typically bodyweight
    final weightSuggestion = (ex['weightSuggestionKg'] ?? 'Bodyweight')
        .toString()
        .toLowerCase()
        .trim();

    final isBodyweight = _isBodyweightIndicator(weightSuggestion);
    if (isBodyweight) {
      ex['weightSuggestionKg'] = 'Bodyweight';
      ex['usesWeight'] = false;
    } else {
      // Allow for weighted timed exercises (e.g., weighted planks)
      ex['usesWeight'] = ex['usesWeight'] as bool? ?? true;
    }

    return ex;
  }

  /// Normalizes a rep-based (non-timed) exercise
  static Map<String, dynamic> _normalizeRepBasedExercise(
      Map<String, dynamic> ex) {
    Log.debug('Normalizing REP-BASED exercise: ${ex['name']}', tag: _tag);

    // Remove targetDurationSeconds if present
    ex.remove('targetDurationSeconds');

    // Handle weight detection
    final weightSuggestion = (ex['weightSuggestionKg'] ?? 'Bodyweight')
        .toString()
        .toLowerCase()
        .trim();

    final isBodyweight = _isBodyweightIndicator(weightSuggestion);

    // Determine usesWeight
    if (ex['usesWeight'] == null) {
      ex['usesWeight'] = !isBodyweight;
    }

    // Ensure weight suggestion is set
    if (ex['weightSuggestionKg'] == null || weightSuggestion.isEmpty) {
      ex['weightSuggestionKg'] = 'Bodyweight';
      ex['usesWeight'] = false;
    }

    // Fix inconsistencies
    final currentUsesWeight = ex['usesWeight'] as bool;
    if (currentUsesWeight && isBodyweight) {
      ex['usesWeight'] = false;
      ex['weightSuggestionKg'] = 'Bodyweight';
    } else if (!currentUsesWeight && !isBodyweight) {
      // Has numeric weight but usesWeight=false
      ex['usesWeight'] = true;
    }

    return ex;
  }

  /// Checks if a weight suggestion indicates bodyweight exercise
  static bool _isBodyweightIndicator(String weightSuggestion) {
    const bodyweightIndicators = [
      'bodyweight',
      'bw',
      'n/a',
      '',
      'na',
      'none',
      'body weight',
      'body-weight',
    ];

    const nonNumericIndicators = [
      'light',
      'moderate',
      'heavy',
      'challenging',
      'easy',
      'difficult',
    ];

    // Check exact matches
    if (bodyweightIndicators.contains(weightSuggestion)) {
      return true;
    }

    // Check for non-numeric descriptive words
    for (final indicator in nonNumericIndicators) {
      if (weightSuggestion.contains(indicator)) {
        return true;
      }
    }

    // Check if it's not a number
    final isNumeric = double.tryParse(weightSuggestion) != null;
    return !isNumeric;
  }

  /// Parses duration in seconds from reps string
  ///
  /// Supports formats:
  /// - "30s" or "30 sec" → 30 seconds
  /// - "2m" or "2 min" → 120 seconds
  /// - "1:30" → 90 seconds
  /// - "60" → 60 seconds (if context is timed)
  static int _parseDurationFromReps(String reps) {
    final cleanReps = reps.toLowerCase().trim();

    Log.debug('Parsing duration from: "$reps"', tag: _tag);

    // Pattern: "30s" or "30 seconds"
    final secondsMatch =
        RegExp(r'(\d+)\s*(?:s|sec|seconds?)\b').firstMatch(cleanReps);
    if (secondsMatch != null) {
      return int.parse(secondsMatch.group(1)!);
    }

    // Pattern: "2m" or "2 minutes"
    final minutesMatch =
        RegExp(r'(\d+)\s*(?:m|min|minutes?)\b').firstMatch(cleanReps);
    if (minutesMatch != null) {
      return int.parse(minutesMatch.group(1)!) * 60;
    }

    // Pattern: "1:30" (mm:ss format)
    final mmssMatch = RegExp(r'(\d+):(\d{2})').firstMatch(cleanReps);
    if (mmssMatch != null) {
      final minutes = int.parse(mmssMatch.group(1)!);
      final seconds = int.parse(mmssMatch.group(2)!);
      return (minutes * 60) + seconds;
    }

    // Pattern: pure number "45" - assume seconds for timed exercises
    final numberMatch = RegExp(r'^(\d+)$').firstMatch(cleanReps);
    if (numberMatch != null) {
      final value = int.parse(numberMatch.group(1)!);
      // Validate if this could be seconds
      return value.clamp(10, 600);
    }

    // Default for timed exercises
    return 60;
  }
}
