// lib/engines/workout_engine/program_validator.dart
/// Validates and normalizes program data from any generation source.
///
/// Pure deterministic logic — no logging or external dependencies.
class ProgramValidator {
  ProgramValidator._();

  static Map<String, dynamic> validateAndNormalize(
    Map<String, dynamic> program,
  ) {
    if (!program.containsKey('name') ||
        !program.containsKey('durationInWeeks') ||
        !program.containsKey('weeklySchedule')) {
      throw FormatException('Missing required fields in program');
    }

    final weeklySchedule = program['weeklySchedule'] as Map<String, dynamic>;
    final normalized = <String, dynamic>{};

    for (final entry in weeklySchedule.entries) {
      final day = entry.key.toLowerCase();
      final exercises = entry.value as List<dynamic>;

      normalized[day] = exercises.map((ex) {
        if (ex is! Map<String, dynamic>) {
          return <String, dynamic>{};
        }
        return _normalizeExercise(ex);
      }).toList();
    }

    program['weeklySchedule'] = normalized;
    return program;
  }

  static Map<String, dynamic> _normalizeExercise(Map<String, dynamic> ex) {
    ex['name'] = ex['name'] ?? 'Unknown Exercise';
    ex['sets'] = (ex['sets'] as num?)?.toInt() ?? 3;
    ex['description'] = ex['description'] ?? 'No description available';
    ex['restBetweenSetsSeconds'] =
        (ex['restBetweenSetsSeconds'] as num?)?.toInt() ?? 60;

    final reps = (ex['reps'] ?? '8-12').toString().trim();
    ex['reps'] = reps;

    final lowerReps = reps.toLowerCase();
    final isTimed = lowerReps.contains('s') ||
        lowerReps.contains('sec') ||
        lowerReps.contains('min') ||
        lowerReps.contains(':') ||
        lowerReps == 'hold';

    ex['isTimed'] = isTimed;

    if (isTimed) {
      return _normalizeTimedExercise(ex, reps);
    }
    return _normalizeRepBasedExercise(ex);
  }

  static Map<String, dynamic> _normalizeTimedExercise(
    Map<String, dynamic> ex,
    String reps,
  ) {
    final duration = _parseDurationFromReps(reps);
    final validatedDuration = duration.clamp(10, 600);
    ex['targetDurationSeconds'] = validatedDuration;

    if (!reps.contains('s') && !reps.contains('sec') && !reps.contains('min')) {
      ex['reps'] = '${validatedDuration}s';
    }

    final weightSuggestion = (ex['weightSuggestionKg'] ?? 'Bodyweight')
        .toString()
        .toLowerCase()
        .trim();

    if (_isBodyweightIndicator(weightSuggestion)) {
      ex['weightSuggestionKg'] = 'Bodyweight';
      ex['usesWeight'] = false;
    } else {
      ex['usesWeight'] = ex['usesWeight'] as bool? ?? true;
    }

    return ex;
  }

  static Map<String, dynamic> _normalizeRepBasedExercise(
    Map<String, dynamic> ex,
  ) {
    ex.remove('targetDurationSeconds');

    final weightSuggestion = (ex['weightSuggestionKg'] ?? 'Bodyweight')
        .toString()
        .toLowerCase()
        .trim();

    final isBodyweight = _isBodyweightIndicator(weightSuggestion);

    if (ex['usesWeight'] == null) {
      ex['usesWeight'] = !isBodyweight;
    }

    if (ex['weightSuggestionKg'] == null || weightSuggestion.isEmpty) {
      ex['weightSuggestionKg'] = 'Bodyweight';
      ex['usesWeight'] = false;
    }

    final currentUsesWeight = ex['usesWeight'] as bool;
    if (currentUsesWeight && isBodyweight) {
      ex['usesWeight'] = false;
      ex['weightSuggestionKg'] = 'Bodyweight';
    } else if (!currentUsesWeight && !isBodyweight) {
      ex['usesWeight'] = true;
    }

    return ex;
  }

  static bool _isBodyweightIndicator(String weightSuggestion) {
    const bodyweightKeywords = {
      'bodyweight',
      'bw',
      'n/a',
      '',
      'na',
      'none',
      'body weight',
      'body-weight',
      'light',
      'moderate',
      'heavy',
      'challenging',
      'easy',
      'difficult',
    };
    return bodyweightKeywords.contains(weightSuggestion.toLowerCase().trim()) ||
        double.tryParse(weightSuggestion) == null;
  }

  static int _parseDurationFromReps(String reps) {
    final cleanReps = reps.toLowerCase().trim();

    final secondsMatch =
        RegExp(r'(\d+)\s*(?:s|sec|seconds?)\b').firstMatch(cleanReps);
    if (secondsMatch != null) {
      return int.parse(secondsMatch.group(1)!);
    }

    final minutesMatch =
        RegExp(r'(\d+)\s*(?:m|min|minutes?)\b').firstMatch(cleanReps);
    if (minutesMatch != null) {
      return int.parse(minutesMatch.group(1)!) * 60;
    }

    final mmssMatch = RegExp(r'(\d+):(\d{2})').firstMatch(cleanReps);
    if (mmssMatch != null) {
      final minutes = int.parse(mmssMatch.group(1)!);
      final seconds = int.parse(mmssMatch.group(2)!);
      return (minutes * 60) + seconds;
    }

    final numberMatch = RegExp(r'^(\d+)$').firstMatch(cleanReps);
    if (numberMatch != null) {
      return int.parse(numberMatch.group(1)!).clamp(10, 600);
    }

    return 60;
  }
}
