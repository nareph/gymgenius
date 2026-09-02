// lib/engines/ai_coach/repair/json_repair_service.dart
import 'dart:convert';

import 'package:gymgenius/core/logger/logger_service.dart';

/// Advanced JSON repair and parsing service.
/// Handles Markdown code blocks, smart quotes, trailing commas, unclosed braces,
/// and extracts the first valid JSON object from text.
class JsonRepairService {
  static const _tag = 'JSON Repair';

  /// Parse JSON with automatic repair strategies.
  Map<String, dynamic> parseJsonWithRepair(
    String jsonText,
    String context,
  ) {
    Log.debug('Parsing JSON for: $context', tag: _tag);

    // ------------------------------------------------------------
    // Step 1: Clean the text
    // ------------------------------------------------------------
    var cleaned = _cleanJsonText(jsonText);
    Log.debug('Cleaned text length: ${cleaned.length}', tag: _tag);

    // ------------------------------------------------------------
    // Step 2: Try direct parse
    // ------------------------------------------------------------
    try {
      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      Log.debug('Direct parse successful for: $context', tag: _tag);
      return parsed;
    } catch (e) {
      Log.debug('Direct parse failed: $e', tag: _tag);
    }

    // ------------------------------------------------------------
    // Step 3: Extract JSON from text (robust)
    // ------------------------------------------------------------
    final extracted = _extractJsonFromText(cleaned);
    if (extracted.isNotEmpty) {
      Log.debug('Extraction successful for: $context', tag: _tag);
      return extracted;
    }

    // ------------------------------------------------------------
    // Step 4: Repair common JSON issues
    // ------------------------------------------------------------
    final repaired = _repairJson(cleaned);
    try {
      final parsed = jsonDecode(repaired) as Map<String, dynamic>;
      Log.debug('Repair successful for: $context', tag: _tag);
      return parsed;
    } catch (e) {
      Log.debug('Repair failed: $e', tag: _tag);
    }

    // ------------------------------------------------------------
    // Step 5: Handle truncated JSON (MAX_TOKENS) with message extraction
    // ------------------------------------------------------------
    final truncated = _handleTruncatedJson(cleaned);
    if (truncated.isNotEmpty) {
      Log.debug('Truncated JSON recovery successful for: $context', tag: _tag);
      return truncated;
    }

    // ------------------------------------------------------------
    // Step 6: Last resort — try to parse as partial workout
    // ------------------------------------------------------------
    final partial = _parseAsPartial(cleaned);
    if (partial.isNotEmpty) {
      Log.debug('Partial parse successful for: $context', tag: _tag);
      return partial;
    }

    throw FormatException('Could not parse JSON: $context');
  }

  /// Clean JSON text before parsing.
  String _cleanJsonText(String text) {
    var cleaned = text;

    // Remove markdown code blocks
    cleaned = cleaned.replaceAll(RegExp(r'```(?:json)?'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```'), '');

    // Find JSON start (first '{' or '[')
    final jsonStart = cleaned.indexOf(RegExp(r'\{|\['));
    if (jsonStart > 0) {
      cleaned = cleaned.substring(jsonStart);
    }

    // Trim whitespace
    cleaned = cleaned.trim();

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

  /// Extract JSON from surrounding text using brace counting.
  Map<String, dynamic> _extractJsonFromText(String text) {
    // Find the first '{'
    final startBrace = text.indexOf('{');
    if (startBrace == -1) return {};

    var braceCount = 0;
    var inString = false;
    var escape = false;

    for (var i = startBrace; i < text.length; i++) {
      final char = text[i];

      if (escape) {
        escape = false;
        continue;
      }

      if (char == '\\') {
        escape = true;
        continue;
      }

      if (char == '"') {
        inString = !inString;
        continue;
      }

      if (!inString) {
        if (char == '{') {
          braceCount++;
        } else if (char == '}') {
          braceCount--;
          if (braceCount == 0) {
            final jsonStr = text.substring(startBrace, i + 1);
            try {
              final result = jsonDecode(jsonStr);
              if (result is Map<String, dynamic>) {
                return result;
              }
            } catch (_) {
              // Continue searching
            }
          }
        }
      }
    }

    // If we reach here, try to find any JSON-like structure with regex
    final patterns = [
      RegExp(r'\{[\s\S]*?\}(?=\s*(?:\{|\}|$))'),
      RegExp(r'\{[\s\S]*\}'),
      RegExp(r'\[[\s\S]*?\]'),
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
        } catch (_) {
          continue;
        }
      }
    }

    return {};
  }

  /// Repair common JSON issues.
  String _repairJson(String text) {
    var repaired = text;

    // 1. Balance braces
    final openBraces = '{'.allMatches(repaired).length;
    final closeBraces = '}'.allMatches(repaired).length;
    if (openBraces > closeBraces) {
      repaired = '$repaired${'}' * (openBraces - closeBraces)}';
    }

    // 2. Balance brackets
    final openBrackets = '['.allMatches(repaired).length;
    final closeBrackets = ']'.allMatches(repaired).length;
    if (openBrackets > closeBrackets) {
      repaired = '$repaired${']' * (openBrackets - closeBrackets)}';
    }

    // 3. Remove trailing commas
    repaired = repaired.replaceAllMapped(
      RegExp(r',\s*([}\]])'),
      (match) => match.group(1)!,
    );

    // 4. Fix missing string quotes
    repaired = repaired.replaceAllMapped(
      RegExp(r':\s*([^"\s{}\[\],]+)(?=\s*[,\]}])'),
      (match) => ': "${match.group(1)}"',
    );

    // 5. Fix unclosed strings
    final quoteCount = '"'.allMatches(repaired).length;
    if (quoteCount.isOdd) {
      final lastQuote = repaired.lastIndexOf('"');
      if (lastQuote != -1) {
        final after = repaired.substring(lastQuote + 1);
        if (!after.contains(RegExp(r'^\s*[,}\]]'))) {
          repaired = '$repaired"';
        }
      }
    }

    // 6. Fix missing values
    repaired = repaired.replaceAllMapped(
      RegExp(r'("[^"]*"\s*:\s*)\s*([,\]}])'),
      (match) => '${match.group(1)}null${match.group(2)}',
    );

    return repaired;
  }

  /// 🔥 CORRECTION : handle truncated JSON (MAX_TOKENS) with message extraction
  Map<String, dynamic> _handleTruncatedJson(String text) {
    Log.debug('Attempting to recover truncated JSON', tag: _tag);

    var recovered = text;

    // ------------------------------------------------------------
    // Step 1: Try to repair the string and parse
    // ------------------------------------------------------------

    // Count open braces
    final openBraces = '{'.allMatches(recovered).length;
    final closeBraces = '}'.allMatches(recovered).length;

    if (openBraces > closeBraces) {
      // Remove trailing comma if present
      final lastComma = recovered.lastIndexOf(',');
      final lastBrace = recovered.lastIndexOf('{');
      if (lastComma > lastBrace) {
        recovered = recovered.substring(0, lastComma);
      }
      // Close all open braces
      recovered = '$recovered${'}' * (openBraces - closeBraces)}';
      Log.debug('Closed ${openBraces - closeBraces} open braces', tag: _tag);
    }

    // ------------------------------------------------------------
    // Step 2: Fix unclosed strings (add missing quotes)
    // ------------------------------------------------------------
    // Find the last opening quote that is not closed.
    var lastQuoteIndex = -1;
    var inString2 = false;
    var escape2 = false;
    for (var i = 0; i < recovered.length; i++) {
      final char = recovered[i];
      if (escape2) {
        escape2 = false;
        continue;
      }
      if (char == '\\') {
        escape2 = true;
        continue;
      }
      if (char == '"') {
        inString2 = !inString2;
        if (inString2) {
          lastQuoteIndex = i;
        }
      }
    }

    // If we are still inside a string (odd number of quotes), add a closing quote.
    if (inString2 && lastQuoteIndex != -1) {
      // Check if after the last quote there is a comma or brace that would indicate the string should be closed.
      // For simplicity, we add a closing quote.
      recovered = '$recovered"';
      Log.debug('Added closing quote for unclosed string', tag: _tag);
    }

    // ------------------------------------------------------------
    // Step 3: Try to parse the recovered JSON
    // ------------------------------------------------------------
    try {
      final parsed = jsonDecode(recovered) as Map<String, dynamic>;
      Log.debug('Truncated JSON recovered successfully', tag: _tag);
      return parsed;
    } catch (_) {
      // Fall through to partial extraction
    }

    // ------------------------------------------------------------
    // Step 4: Extract what we can using regex (including message)
    // ------------------------------------------------------------
    try {
      final result = <String, dynamic>{};

      // Extract message
      final messageMatch =
          RegExp(r'"message"\s*:\s*"([^"]*)"?', dotAll: true).firstMatch(text);
      String message = '';
      if (messageMatch != null) {
        message = messageMatch.group(1)?.trim() ?? '';
        // If the message ends with a backslash or unescaped, we may need to clean it
        if (message.endsWith('\\')) {
          message = message.substring(0, message.length - 1);
        }
        // Remove any trailing characters that might be part of the JSON structure
        final cleanEnd =
            message.lastIndexOf(RegExp(r'[^a-zA-Z0-9\s\.\,\!\?\-\:\;]'));
        if (cleanEnd != -1) {
          message = message.substring(0, cleanEnd + 1);
        }
        result['message'] = message;
      } else {
        result['message'] = 'AI Coach response (partial)';
      }

      // Extract name if present (for potential workout context)
      final nameMatch = RegExp(r'"name"\s*:\s*"([^"]+)"').firstMatch(text);
      result['name'] = nameMatch?.group(1)?.trim() ?? 'AI Generated Workout';

      // Extract duration
      final durationMatch =
          RegExp(r'"durationInWeeks"\s*:\s*(\d+)').firstMatch(text);
      result['durationInWeeks'] =
          durationMatch != null ? int.parse(durationMatch.group(1)!) : 8;

      // Extract recommendations if any
      final recsMatch =
          RegExp(r'"recommendations"\s*:\s*\[([^\]]*)\]', dotAll: true)
              .firstMatch(text);
      if (recsMatch != null) {
        final recsContent = recsMatch.group(1)!;
        // Try to parse recommendation objects
        final recs = <Map<String, dynamic>>[];
        final recBlocks = recsContent.split(RegExp(r'\}\s*,\s*\{'));
        for (final block in recBlocks) {
          final rec = <String, dynamic>{};
          final catMatch =
              RegExp(r'"category"\s*:\s*"([^"]+)"').firstMatch(block);
          if (catMatch != null) {
            rec['category'] = catMatch.group(1)!;
          }
          final textMatch = RegExp(r'"text"\s*:\s*"([^"]+)"').firstMatch(block);
          if (textMatch != null) {
            rec['text'] = textMatch.group(1)!;
          }
          if (rec.isNotEmpty) {
            recs.add(rec);
          }
        }
        result['recommendations'] = recs;
      } else {
        result['recommendations'] = const <Map<String, dynamic>>[];
      }

      // Provide default insights if missing
      result['insights'] = const <Map<String, dynamic>>[];
      result['tone'] = 'supportive';
      result['generatedBy'] = 'ai_coach_v1';
      result['repaired'] = true;
      result['truncated'] = true;
      result['repairContext'] = 'MAX_TOKENS recovery';

      Log.debug('Partial extraction successful from truncated JSON', tag: _tag);
      return result;
    } catch (_) {
      return {};
    }
  }

  /// Extract exercises for a specific day.
  List<Map<String, dynamic>> _extractDayExercises(String text, String day) {
    final exercises = <Map<String, dynamic>>[];

    try {
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
    } catch (_) {}

    return exercises;
  }

  /// Parse a single exercise block.
  Map<String, dynamic> _parseExerciseBlock(String block) {
    final exercise = <String, dynamic>{};

    final nameMatch = RegExp(r'"name"\s*:\s*"([^"]+)"').firstMatch(block);
    if (nameMatch == null) return {};
    exercise['name'] = nameMatch.group(1)!.trim();

    final setsMatch = RegExp(r'"sets"\s*:\s*(\d+)').firstMatch(block);
    exercise['sets'] = setsMatch != null ? int.parse(setsMatch.group(1)!) : 3;

    final repsMatch = RegExp(r'"reps"\s*:\s*"([^"]+)"').firstMatch(block);
    exercise['reps'] = repsMatch?.group(1)?.trim() ?? '8-12';

    return exercise;
  }

  /// Wrap a list in a workout structure.
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

  /// Parse as partial workout structure.
  Map<String, dynamic> _parseAsPartial(String text) {
    final result = <String, dynamic>{};

    final nameMatch = RegExp(r'"name"\s*:\s*"([^"]+)"').firstMatch(text);
    result['name'] = nameMatch?.group(1)?.trim() ?? 'AI Generated Workout';

    final durationMatch =
        RegExp(r'"durationInWeeks"\s*:\s*(\d+)').firstMatch(text);
    result['durationInWeeks'] =
        durationMatch != null ? int.parse(durationMatch.group(1)!) : 8;

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
    result['repairContext'] = 'partial';

    return result;
  }
}
