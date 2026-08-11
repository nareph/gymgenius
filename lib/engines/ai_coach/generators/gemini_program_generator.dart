// lib/core/services/ai/generators/gemini_program_generator.dart

import 'package:gymgenius/engines/ai_coach/ai_config.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/engines/ai_coach/api/gemini_api_client.dart';
import 'package:gymgenius/engines/ai_coach/prompt/prompt_builder.dart';
import 'package:gymgenius/engines/ai_coach/types/types.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';

class GeminiProgramGenerator {
  final GeminiAPIClient _geminiClient;
  static const _tag = 'GeminiProgramGenerator';

  GeminiProgramGenerator({GeminiAPIClient? geminiClient})
      : _geminiClient = geminiClient ?? GeminiAPIClient();

  // ============================================================
  // LEGACY full-generation path — kept in case something still calls it
  // directly, but the current pipeline never uses this for normal
  // program creation (WorkoutEngine always generates locally first).
  // ============================================================

  Future<Map<String, dynamic>> generate({
    required HealthProfile healthProfile,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
    Map<String, dynamic>? previousProgram,
    Map<String, dynamic>? regenerationOptions,
  }) async {
    try {
      Log.debug('Building optimized prompt', tag: _tag);

      final prompt = PromptBuilder.buildProgramPrompt(
        healthProfile: healthProfile,
        selectedSplit: selectedSplit,
        workoutDaysCount: workoutDaysCount,
        useSpecifiedDays: useSpecifiedDays,
        previousProgram: previousProgram,
        regenerationOptions: regenerationOptions,
      );

      Log.debug('Prompt length: ${prompt.length} chars', tag: _tag);

      if (prompt.length > AIConfig.maxPromptLength) {
        Log.warning(
          'Prompt exceeds max length (${prompt.length} > ${AIConfig.maxPromptLength})',
          tag: _tag,
        );
      }

      Log.debug('Calling Gemini API', tag: _tag);

      final responseText = await _geminiClient.generateContent(
        prompt: prompt,
        temperature: 0.7,
        maxOutputTokens: AIConfig.maxOutputTokens,
      );

      Log.debug('Received response (${responseText.length} chars)', tag: _tag);

      _saveResponseForDebug(responseText);

      if (_isResponseTruncated(responseText)) {
        Log.warning('Response appears truncated', tag: _tag);
        if (workoutDaysCount == 5) {
          throw Exception(
            'Response truncated for 5-day program.\n\n'
            'Gemini cannot generate complete 5-day programs.\n'
            'Please try:\n'
            '• 3-4 workout days instead\n'
            '• Simpler split (Full Body, Upper/Lower)\n'
            '• Use local generator (disable AI)',
          );
        }
      }

      Log.debug('Parsing JSON', tag: _tag);

      final programJson = _geminiClient.parseJsonResponse(responseText);

      _validateProgramCompleteness(programJson, workoutDaysCount);

      return _validateProgramStructure(programJson);
    } catch (e, s) {
      Log.error('Error generating program', tag: _tag, error: e, stackTrace: s);

      if (e.toString().contains('truncated')) {
        throw Exception(
          'Program generation incomplete.\n\n'
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

  // ============================================================
  // CURRENT optimization path — improves an already-valid local program.
  // ============================================================

  /// Asks Gemini to optimize [currentProgram] using [prompt] (built by
  /// `PromptBuilder.buildOptimizationPrompt`). Returns the parsed JSON —
  /// expected shape: `{ "monday": ["Exercise Name", ...], "tips": [...] }`
  /// — day keys with exercise-NAME arrays only, no full exercise objects.
  /// Throws on any failure (network, truncation, invalid JSON); the
  /// caller (GeminiProgramOptimizer) already treats any exception as
  /// "skip optimization, keep the local program".
  Future<Map<String, dynamic>> generateOptimization({
    required String prompt,
    required TrainingProgram currentProgram,
  }) async {
    Log.debug('Calling Gemini API for program optimization', tag: _tag);

    final responseText = await _geminiClient.generateContent(
      prompt: prompt,
      temperature: 0.6,
      maxOutputTokens: AIConfig.maxOutputTokens,
    );

    Log.debug(
        'Received optimization response (${responseText.length} chars)',
        tag: _tag);

    if (_isResponseTruncated(responseText)) {
      throw Exception(
          'Optimization response appears truncated — discarding it.');
    }

    return _geminiClient.parseJsonResponse(responseText);
  }

  void _validateProgramCompleteness(
    Map<String, dynamic> program,
    int expectedWorkoutDays,
  ) {
    final dailyWorkouts = program['dailyWorkouts'] as Map<String, dynamic>?;
    if (dailyWorkouts == null) {
      throw Exception('Missing dailyWorkouts');
    }

    int nonEmptyDays = 0;
    for (final exercises in dailyWorkouts.values) {
      if (exercises is List && exercises.isNotEmpty) {
        nonEmptyDays++;
      }
    }

    Log.debug(
      'Program has $nonEmptyDays/$expectedWorkoutDays workout days',
      tag: _tag,
    );

    if (nonEmptyDays < expectedWorkoutDays) {
      throw Exception(
        'Incomplete program: Only $nonEmptyDays/$expectedWorkoutDays days generated.\n'
        'Response was likely truncated.',
      );
    }
  }

  Map<String, dynamic> _validateProgramStructure(Map<String, dynamic> program) {
    if (!program.containsKey('name') ||
        !program.containsKey('durationInWeeks') ||
        !program.containsKey('dailyWorkouts')) {
      throw Exception('Invalid program structure from AI');
    }

    final dailyWorkouts = program['dailyWorkouts'];
    if (dailyWorkouts is! Map<String, dynamic>) {
      throw Exception('Invalid dailyWorkouts structure');
    }

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

    return program;
  }

  bool _isResponseTruncated(String response) {
    final trimmed = response.trim();
    if (trimmed.endsWith('...') ||
        trimmed.endsWith('... (truncated)') ||
        trimmed.endsWith('[TRUNCATED]')) {
      return true;
    }

    final openBraces = '{'.allMatches(trimmed).length;
    final closeBraces = '}'.allMatches(trimmed).length;
    if (openBraces != closeBraces) return true;

    final openBrackets = '['.allMatches(trimmed).length;
    final closeBrackets = ']'.allMatches(trimmed).length;
    if (openBrackets != closeBrackets) return true;

    if (!trimmed.endsWith('}') && !trimmed.endsWith(']')) {
      return true;
    }

    return false;
  }

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