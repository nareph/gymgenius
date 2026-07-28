// lib/services/ai/json_repair_service.dart
import 'dart:convert';

import 'package:gymgenius/core/logger/logger_service.dart';

/// Advanced JSON repair and parsing service
class JsonRepairService {
  static const _tag = 'JSON Repair';

  /// Parse JSON with automatic repair strategies
  Map<String, dynamic> parseJsonWithRepair(
    String jsonText,
    String context,
  ) {
    try {
      Log.debug('Parsing JSON for: $context', tag: _tag);

      // Strategy 1: Clean and try direct parse
      final cleaned = _cleanJsonText(jsonText);
      try {
        final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
        Log.debug('Direct parse successful for: $context', tag: _tag);
        return parsed;
      } catch (e) {
        Log.debug('Direct parse failed: $e', tag: _tag);
      }

      // Strategy 2: Extract JSON from text
      final extracted = _extractJsonFromText(cleaned);
      if (extracted.isNotEmpty) {
        Log.debug('Extraction successful for: $context', tag: _tag);
        return extracted;
      }

      // Strategy 3: Repair common JSON issues
      final repaired = _repairJson(cleaned);
      try {
        final parsed = jsonDecode(repaired) as Map<String, dynamic>;
        Log.debug('Repair successful for: $context', tag: _tag);
        return parsed;
      } catch (e) {
        Log.debug('Repair failed: $e', tag: _tag);
      }

      // Strategy 4: Parse as partial workout
      final partial = _parseAsPartialWorkout(cleaned, context);
      if (partial.isNotEmpty) {
        Log.debug('Partial parse successful for: $context', tag: _tag);
        return partial;
      }

      throw FormatException('Could not parse JSON: $context');
    } catch (e, s) {
      Log.error(
        'Failed to parse JSON for: $context',
        tag: _tag,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  /// Clean JSON text before parsing
  String _cleanJsonText(String text) {
    var cleaned = text;

    // Remove markdown code blocks
    cleaned = cleaned.replaceAll(RegExp(r'```(?:json)?'), '');

    // Find JSON start
    final jsonStart = cleaned.indexOf(RegExp(r'\{|\['));
    if (jsonStart > 0) {
      cleaned = cleaned.substring(jsonStart);
    }

    // Find JSON end
    final jsonEnd = cleaned.lastIndexOf(RegExp(r'\}|\]'));
    if (jsonEnd != -1 && jsonEnd < cleaned.length - 1) {
      cleaned = cleaned.substring(0, jsonEnd + 1);
    }

    // Fix encoding issues
    cleaned = cleaned.replaceAll('\\"', '"');
    cleaned = cleaned.replaceAll('\\\\', '\\');
    cleaned = cleaned.replaceAll('\\n', '\n');
    cleaned = cleaned.replaceAll('\\t', '\t');

    // Replace smart quotes
    cleaned = cleaned.replaceAll('"', '"');
    cleaned = cleaned.replaceAll('"', '"');
    cleaned = cleaned.replaceAll("'", "'");

    return cleaned.trim();
  }

  /// Extract JSON from surrounding text
  Map<String, dynamic> _extractJsonFromText(String text) {
    // Pattern for complete JSON objects
    final patterns = [
      RegExp(r'\{[\s\S]*?\}(?=\s*(?:\{|\}|$))'), // Complete object
      RegExp(r'\{[\s\S]*\}'), // Any object
      RegExp(r'\[[\s\S]*?\]'), // Array
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          final jsonStr = match.group(0)!;
          final result = jsonDecode(jsonStr);
          if (result is Map<String, dynamic>) {
            return result;
          } else if (result is List) {
            return _wrapListInWorkout(result);
          }
        } catch (e) {
          continue;
        }
      }
    }

    return {};
  }

  /// Repair common JSON issues
  String _repairJson(String text) {
    var repaired = text;

    // 1. Balance braces and brackets
    final openBraces = '{'.allMatches(repaired).length;
    final closeBraces = '}'.allMatches(repaired).length;
    if (openBraces > closeBraces) {
      repaired = '$repaired${'}' * (openBraces - closeBraces)}';
    }

    final openBrackets = '['.allMatches(repaired).length;
    final closeBrackets = ']'.allMatches(repaired).length;
    if (openBrackets > closeBrackets) {
      repaired = '$repaired${']' * (openBrackets - closeBrackets)}';
    }

    // 2. Remove trailing commas
    repaired = repaired.replaceAllMapped(
      RegExp(r',\s*([}\]])'),
      (match) => match.group(1)!,
    );

    // 3. Fix missing string quotes
    repaired = repaired.replaceAllMapped(
      RegExp(r':\s*([^"\s{}\[\],]+)(?=\s*[,\]}])'),
      (match) => ': "${match.group(1)}"',
    );

    // 4. Fix unclosed strings
    final quoteCount = '"'.allMatches(repaired).length;
    if (quoteCount.isOdd) {
      // Find last quote and context
      final lastQuote = repaired.lastIndexOf('"');
      if (lastQuote != -1) {
        final after = repaired.substring(lastQuote + 1);
        if (!after.contains(RegExp(r'^\s*[,}\]]'))) {
          repaired = '$repaired"';
        }
      }
    }

    // 5. Fix missing values
    repaired = repaired.replaceAllMapped(
      RegExp(r'("[^"]*"\s*:\s*)\s*([,\]}])'),
      (match) => '${match.group(1)}null${match.group(2)}',
    );

    return repaired;
  }

  /// Parse as partial workout structure
  Map<String, dynamic> _parseAsPartialWorkout(String text, String context) {
    Log.debug('Parsing as partial workout: $context', tag: _tag);

    final result = <String, dynamic>{};

    // Extract routine name
    final nameMatch = RegExp(r'"name"\s*:\s*"([^"]+)"').firstMatch(text);
    result['name'] = nameMatch?.group(1)?.trim() ?? 'AI Generated Workout';

    // Extract duration
    final durationMatch =
        RegExp(r'"durationInWeeks"\s*:\s*(\d+)').firstMatch(text);
    result['durationInWeeks'] =
        durationMatch != null ? int.parse(durationMatch.group(1)!) : 8;

    // Extract daily workouts
    final dailyWorkouts = <String, List<Map<String, dynamic>>>{};
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];

    for (final day in days) {
      final dayExercises = _extractDayExercises(text, day);
      dailyWorkouts[day] = dayExercises;
    }

    result['dailyWorkouts'] = dailyWorkouts;
    result['repaired'] = true;
    result['repairContext'] = context;

    return result;
  }

  /// Extract exercises for a specific day
  List<Map<String, dynamic>> _extractDayExercises(String text, String day) {
    final exercises = <Map<String, dynamic>>[];

    try {
      // Look for day section
      final dayPattern = RegExp('"$day"\\s*:\\s*\\[([^\\]]*)\\]', dotAll: true);
      final match = dayPattern.firstMatch(text);

      if (match != null) {
        final dayContent = match.group(1)!;
        final exerciseBlocks = dayContent.split(RegExp(r'\}\s*,\s*\{'));

        for (final block in exerciseBlocks) {
          final exercise = _parseExerciseBlock(block);
          if (exercise.isNotEmpty) {
            exercises.add(exercise);
          }
        }
      }
    } catch (e) {
      Log.debug('Failed to extract exercises for $day: $e', tag: _tag);
    }

    return exercises;
  }

  /// Parse a single exercise block
  Map<String, dynamic> _parseExerciseBlock(String block) {
    final exercise = <String, dynamic>{};

    // Extract name
    final nameMatch = RegExp(r'"name"\s*:\s*"([^"]+)"').firstMatch(block);
    if (nameMatch == null) return {};
    exercise['name'] = nameMatch.group(1)!.trim();

    // Extract sets
    final setsMatch = RegExp(r'"sets"\s*:\s*(\d+)').firstMatch(block);
    exercise['sets'] = setsMatch != null ? int.parse(setsMatch.group(1)!) : 3;

    // Extract reps
    final repsMatch = RegExp(r'"reps"\s*:\s*"([^"]+)"').firstMatch(block);
    exercise['reps'] = repsMatch?.group(1)?.trim() ?? '8-12';

    // Extract description
    final descMatch = RegExp(r'"description"\s*:\s*"([^"]+)"', dotAll: true)
        .firstMatch(block);
    exercise['description'] =
        descMatch?.group(1)?.trim() ?? 'Exercise description';

    // Extract weight suggestion
    final weightMatch =
        RegExp(r'"weightSuggestionKg"\s*:\s*"([^"]+)"').firstMatch(block);
    exercise['weightSuggestionKg'] =
        weightMatch?.group(1)?.trim() ?? 'Moderate';

    // Extract rest time
    final restMatch =
        RegExp(r'"restBetweenSetsSeconds"\s*:\s*(\d+)').firstMatch(block);
    exercise['restBetweenSetsSeconds'] =
        restMatch != null ? int.parse(restMatch.group(1)!) : 60;

    // Default values
    exercise['usesWeight'] = false;
    exercise['isTimed'] = false;

    return exercise;
  }

  /// Wrap a list in workout structure
  Map<String, dynamic> _wrapListInWorkout(List<dynamic> list) {
    return {
      'name': 'Repaired Workout',
      'durationInWeeks': 8,
      'dailyWorkouts': {
        'monday': list,
        'tuesday': [],
        'wednesday': [],
        'thursday': [],
        'friday': [],
        'saturday': [],
        'sunday': [],
      },
      'repaired': true,
    };
  }
}
