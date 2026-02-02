// lib/services/ai/generators/gemini_generator.dart
import 'package:gymgenius/config/ai_config.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/services/ai/api/gemini_api_client.dart';
import 'package:gymgenius/services/ai/prompt_builder.dart';
import 'package:gymgenius/services/ai/types.dart';
import 'package:gymgenius/services/logger_service.dart';

/// Generate routines using Gemini AI API
class GeminiRoutineGenerator {
  final GeminiAPIClient _geminiClient;
  static const _tag = 'GeminiGenerator';
  GeminiRoutineGenerator({GeminiAPIClient? geminiClient})
      : _geminiClient = geminiClient ?? GeminiAPIClient();

  /// Generate routine using Gemini AI
  Future<Map<String, dynamic>> generate({
    required OnboardingDataAI onboardingData,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
    WeeklyRoutine? previousRoutine,
  }) async {
    try {
      Log.debug('Building optimized prompt', tag: _tag);
// Build prompt with regeneration instructions if present
      final prompt = PromptBuilder.buildRoutinePrompt(
        onboarding: onboardingData,
        selectedSplit: selectedSplit,
        workoutDaysCount: workoutDaysCount,
        useSpecifiedDays: useSpecifiedDays,
        aggregatedPerformanceSummary: [],
        previousRoutine: previousRoutine?.toMapForCloudFunction(),
        regenerationInstructions: onboardingData.regenerationInstructions,
      );

      Log.debug('Prompt length: ${prompt.length} chars', tag: _tag);

      // Warn if prompt exceeds recommended length
      if (prompt.length > AIConfig.maxPromptLength) {
        Log.warning(
          'Prompt exceeds max length (${prompt.length} > ${AIConfig.maxPromptLength})',
          tag: _tag,
        );
      }

      Log.debug('Calling Gemini API', tag: _tag);

      // Call Gemini with increased output token limit
      final responseText = await _geminiClient.generateContent(
        prompt: prompt,
        temperature: 0.7,
        maxOutputTokens: AIConfig.maxOutputTokens,
      );

      Log.debug('Received response (${responseText.length} chars)', tag: _tag);

      // Save response for debugging
      _saveResponseForDebug(responseText);

      // Check for truncation
      if (_isResponseTruncated(responseText)) {
        Log.warning('Response appears truncated', tag: _tag);

        // If truncated and 5-day split, suggest reduction
        if (workoutDaysCount == 5) {
          throw Exception(
            'Response truncated for 5-day routine.\n\n'
            'Gemini cannot generate complete 5-day routines.\n'
            'Please try:\n'
            '• 3-4 workout days instead\n'
            '• Simpler split (Full Body, Upper/Lower)\n'
            '• Use local generator (disable AI)',
          );
        }
      }

      Log.debug('Parsing JSON', tag: _tag);

      // Parse JSON response with repair strategies
      final routineJson = _geminiClient.parseJsonResponse(responseText);

      // Validate completeness
      _validateRoutineCompleteness(routineJson, workoutDaysCount);

      // Validate structure
      return _validateRoutineStructure(routineJson);
    } catch (e, s) {
      Log.error('Error generating routine', tag: _tag, error: e, stackTrace: s);

      // Provide user-friendly error messages
      if (e.toString().contains('truncated')) {
        throw Exception(
          'Routine generation incomplete.\n\n'
          'The AI response was truncated. Try:\n'
          '• Fewer workout days (3-4 instead of 5)\n'
          '• Simpler equipment (bodyweight only)\n'
          '• Disable AI (use local generator)',
        );
      }

      if (e.toString().contains('FormatException') ||
          e.toString().contains('JSON')) {
        throw Exception(
          'Invalid AI response format.\n\n'
          'Please try again or use local generator.',
        );
      }

      rethrow;
    }
  }

  /// Validate that the routine is complete for expected workout days
  void _validateRoutineCompleteness(
    Map<String, dynamic> routine,
    int expectedWorkoutDays,
  ) {
    final dailyWorkouts = routine['dailyWorkouts'] as Map<String, dynamic>?;
    if (dailyWorkouts == null) {
      throw Exception('Missing dailyWorkouts');
    }
// Count non-empty days
    int nonEmptyDays = 0;
    for (final exercises in dailyWorkouts.values) {
      if (exercises is List && exercises.isNotEmpty) {
        nonEmptyDays++;
      }
    }

    Log.debug(
      'Routine has $nonEmptyDays/$expectedWorkoutDays workout days',
      tag: _tag,
    );

// If fewer days than expected, likely truncated
    if (nonEmptyDays < expectedWorkoutDays) {
      throw Exception(
        'Incomplete routine: Only $nonEmptyDays/$expectedWorkoutDays days generated.\n'
        'Response was likely truncated.',
      );
    }
  }

  /// Validate routine structure
  Map<String, dynamic> _validateRoutineStructure(Map<String, dynamic> routine) {
// Check required fields
    if (!routine.containsKey('name') ||
        !routine.containsKey('durationInWeeks') ||
        !routine.containsKey('dailyWorkouts')) {
      throw Exception('Invalid routine structure from AI');
    }
    final dailyWorkouts = routine['dailyWorkouts'];
    if (dailyWorkouts is! Map<String, dynamic>) {
      throw Exception('Invalid dailyWorkouts structure');
    }

// Ensure all days are present
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
      if (!dailyWorkouts.containsKey(day)) {
        dailyWorkouts[day] = [];
      }
    }

    return routine;
  }

  /// Check if response appears truncated
  bool _isResponseTruncated(String response) {
    final trimmed = response.trim();
// Check for truncation markers
    if (trimmed.endsWith('...') ||
        trimmed.endsWith('... (truncated)') ||
        trimmed.endsWith('[TRUNCATED]')) {
      return true;
    }

// Check for unbalanced braces
    final openBraces = '{'.allMatches(trimmed).length;
    final closeBraces = '}'.allMatches(trimmed).length;
    if (openBraces != closeBraces) return true;

// Check for unbalanced brackets
    final openBrackets = '['.allMatches(trimmed).length;
    final closeBrackets = ']'.allMatches(trimmed).length;
    if (openBrackets != closeBrackets) return true;

// Check if ends abnormally
    if (!trimmed.endsWith('}') && !trimmed.endsWith(']')) {
      return true;
    }

    return false;
  }

  /// Save response for debugging
  void _saveResponseForDebug(String response) {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final debugData = {
        'timestamp': timestamp,
        'response_length': response.length,
        'first_100_chars':
            response.length > 100 ? response.substring(0, 100) : response,
        'last_100_chars': response.length > 100
            ? response.substring(response.length - 100)
            : response,
      };
      Log.debug('Response debug: $debugData', tag: _tag);
    } catch (e) {
      // Ignore logging errors
    }
  }

  void dispose() {
    _geminiClient.dispose();
  }
}
