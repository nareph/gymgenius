// lib/services/ai_service.dart
import 'package:gymgenius/config/ai_config.dart';
import 'package:gymgenius/engines/workout_engine/models/workout_profile.dart';
import 'package:gymgenius/engines/workout_engine/workout_engine.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/services/ai/generators/gemini_program_generator.dart';
import 'package:gymgenius/services/ai/types.dart';
import 'package:gymgenius/services/logger_service.dart';

/// AI enhancement layer for training program generation.
///
/// Deterministic decisions are delegated to [WorkoutEngine].
/// Cloud AI (Gemini) is used only when configured and enabled.
class AIService {
  final WorkoutEngine _workoutEngine;
  final GeminiProgramGenerator _geminiGenerator;

  AIService({
    int? seed,
    WorkoutEngine? workoutEngine,
    GeminiProgramGenerator? geminiGenerator,
  })  : _workoutEngine = workoutEngine ?? WorkoutEngine(seed: seed),
        _geminiGenerator = geminiGenerator ?? GeminiProgramGenerator() {
    if (AIConfig.useRealAI) {
      Log.info(
        'AIService: Initialized in ${AIConfig.environmentName} mode (Gemini)',
      );
    } else {
      Log.info(
        'AIService: Initialized in ${AIConfig.environmentName} mode (Local)',
      );
    }
  }

  /// Generate a training program based on user onboarding data.
  ///
  /// [previousProgram] should be a serialized version of the previous program
  /// (e.g., `previousProgram.toMap()`) to allow regeneration context.
  ///
  /// Returns raw program data as a Map, ready for persistence.
  Future<Map<String, dynamic>> generateProgram({
    required OnboardingData onboardingData,
    Map<String, dynamic>? previousProgram,
    Map<String, dynamic>? regenerationOptions,
  }) async {
    try {
      Log.debug('AIService: Starting program generation');

      var onboardingAI = OnboardingDataAI.fromMap(onboardingData.toMap());

      if (regenerationOptions != null) {
        onboardingAI =
            _applyRegenerationOptions(onboardingAI, regenerationOptions);
      }

      final daysResult = _workoutEngine.calculateWorkoutDays(
        frequency: onboardingAI.frequency,
        preferredDays: onboardingAI.workoutDays,
      );

      final selectedSplit = _workoutEngine.determineMuscleSplit(
        daysResult.count,
        onboardingAI.experience ?? 'beginner',
      );

      Log.debug(
        'AIService: Workout days: ${daysResult.count}, '
        'split: ${selectedSplit.map((s) => s.name).join(', ')}',
      );

      final programData = await _generateProgramByMode(
        onboardingAI: onboardingAI,
        selectedSplit: selectedSplit,
        workoutDaysCount: daysResult.count,
        useSpecifiedDays: daysResult.useSpecifiedDays,
        previousProgram: previousProgram,
      );

      return _workoutEngine.validateAndNormalize(programData);
    } catch (e, s) {
      Log.error('AIService: Error generating program', error: e, stackTrace: s);

      if (e.toString().contains('complex') ||
          e.toString().contains('truncated') ||
          e.toString().contains('FormatException')) {
        throw Exception(
          'Failed to generate training program. The workout might be too complex.\n'
          'Please try with fewer workout days or a simpler split.',
        );
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> _generateProgramByMode({
    required OnboardingDataAI onboardingAI,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
    Map<String, dynamic>? previousProgram,
  }) async {
    final useAI = AIConfig.useRealAI && AIConfig.isConfigured;

    if (useAI) {
      if (!AIConfig.isConfigured) {
        throw Exception(
          'Gemini API key not configured. '
          'Please set GEMINI_API_KEY environment variable.',
        );
      }
      return _generateWithGemini(
        onboardingAI: onboardingAI,
        selectedSplit: selectedSplit,
        workoutDaysCount: workoutDaysCount,
        useSpecifiedDays: useSpecifiedDays,
        previousProgram: previousProgram,
      );
    }

    return _generateLocally(
      onboardingAI: onboardingAI,
      selectedSplit: selectedSplit,
      workoutDaysCount: workoutDaysCount,
      useSpecifiedDays: useSpecifiedDays,
    );
  }

  Future<Map<String, dynamic>> _generateWithGemini({
    required OnboardingDataAI onboardingAI,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
    Map<String, dynamic>? previousProgram,
  }) async {
    Log.info('AIService: Generating program with Gemini AI');

    try {
      final programData = await _geminiGenerator.generate(
        onboardingData: onboardingAI,
        selectedSplit: selectedSplit,
        workoutDaysCount: workoutDaysCount,
        useSpecifiedDays: useSpecifiedDays,
        previousProgram: previousProgram,
      );

      Log.info('AIService: Successfully generated program with Gemini AI');
      return programData;
    } catch (e, s) {
      Log.error(
        'AIService: Gemini AI generation failed',
        error: e,
        stackTrace: s,
      );

      if (workoutDaysCount > 4) {
        throw Exception(
          'Failed to generate program for $workoutDaysCount days.\n'
          'This split might be too complex for AI generation.\n\n'
          'Please try:\n'
          '• Reducing to 3-4 workout days\n'
          '• Using Full Body or Upper/Lower split\n'
          '• Generating with local mode (simpler)',
        );
      }

      rethrow;
    }
  }

  Map<String, dynamic> _generateLocally({
    required OnboardingDataAI onboardingAI,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
  }) {
    Log.info('AIService: Generating program locally via WorkoutEngine');

    final profile = WorkoutProfile.fromMap(onboardingAI.toMap());

    return _workoutEngine.generateTrainingProgram(
      profile: profile,
      selectedSplit: selectedSplit,
      workoutDaysCount: workoutDaysCount,
      useSpecifiedDays: useSpecifiedDays,
    );
  }

  void dispose() {
    _geminiGenerator.dispose();
  }

  OnboardingDataAI _applyRegenerationOptions(
    OnboardingDataAI onboarding,
    Map<String, dynamic> options,
  ) {
    final instructions = <String>[];

    if (options['type'] == 'specificDay' && options['targetDay'] != null) {
      instructions.add(
        'CRITICAL: Regenerate ONLY the ${options['targetDay']} workout. '
        'Keep all other days EXACTLY as they are in the previous program.',
      );
    }

    if (options['focusMuscles'] != null) {
      instructions.add(
        'CRITICAL: Focus specifically on these muscles: ${options['focusMuscles'].join(', ')}. '
        'Include additional exercises for these muscle groups.',
      );
    }

    if (options['avoidMuscles'] != null) {
      instructions.add(
        'CRITICAL: Avoid exercises targeting these muscles: ${options['avoidMuscles'].join(', ')}. '
        'Replace any exercises that work these muscles.',
      );
    }

    if (options['intensity'] == 'harder') {
      instructions.add(
        'Increase exercise intensity: Add more sets, use higher weight suggestions, '
        'or include more challenging exercise variations.',
      );
    } else if (options['intensity'] == 'easier') {
      instructions.add(
        'Decrease exercise intensity: Reduce sets, use lighter weight suggestions, '
        'or include easier exercise variations.',
      );
    }

    return onboarding.copyWith(
      regenerationInstructions: instructions.isNotEmpty ? instructions : null,
    );
  }
}
