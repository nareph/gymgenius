// lib/services/ai_service.dart

import 'package:gymgenius/config/ai_config.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/services/ai/generators/gemini_generator.dart';
import 'package:gymgenius/services/ai/generators/local_generator.dart';
import 'package:gymgenius/services/ai/muscle_split_calculator.dart';
import 'package:gymgenius/services/ai/validators/routine_validator.dart';
import 'package:gymgenius/services/ai/types.dart';
import 'package:gymgenius/services/logger_service.dart';

/// Main AI Service for generating workout routines
///
/// Supports two modes:
/// - Development: Uses local rule-based generation
/// - Production/Staging: Uses Gemini AI API
class AIService {
  final LocalRoutineGenerator _localGenerator;
  final GeminiRoutineGenerator _geminiGenerator;

  AIService({
    LocalRoutineGenerator? localGenerator,
    GeminiRoutineGenerator? geminiGenerator,
  })  : _localGenerator = localGenerator ?? LocalRoutineGenerator(),
        _geminiGenerator = geminiGenerator ?? GeminiRoutineGenerator() {
    // Log initialization mode
    if (AIConfig.useRealAI) {
      Log.info(
          'AIService: Initialized in ${AIConfig.environmentName} mode (Gemini)');
    } else {
      Log.info(
          'AIService: Initialized in ${AIConfig.environmentName} mode (Local)');
    }
  }

  /// Generate a new workout routine with optional regeneration parameters
  Future<Map<String, dynamic>> generateRoutine({
    required OnboardingData onboardingData,
    WeeklyRoutine? previousRoutine,
    Map<String, dynamic>? regenerationOptions,
  }) async {
    try {
      Log.debug("AIService: Starting routine generation");
      Log.debug("AIService: Regeneration options: $regenerationOptions");

      // Convert to AI types
      var onboardingAI = OnboardingDataAI.fromMap(onboardingData.toMap());

      // Enhance onboarding with regeneration options
      if (regenerationOptions != null) {
        onboardingAI =
            _applyRegenerationOptions(onboardingAI, regenerationOptions);
      }

      // Calculate workout days
      final workoutDaysResult = MuscleSplitCalculator.calculateWorkoutDays(
        frequency: onboardingAI.frequency,
        preferredDays: onboardingAI.workoutDays,
      );

      final actualWorkoutDaysCount = workoutDaysResult.keys.first;
      final useSpecifiedDays = workoutDaysResult.values.first;

      Log.debug(
        "AIService: Workout days count: $actualWorkoutDaysCount, "
        "Use specified: $useSpecifiedDays",
      );

      // Determine muscle split
      final selectedSplit = MuscleSplitCalculator.determineMuscleSplit(
        actualWorkoutDaysCount,
        onboardingAI.experience ?? 'beginner',
      );

      Log.debug(
          "AIService: Selected split: ${selectedSplit.map((s) => s.name).join(', ')}");

      // Generate routine based on mode
      final routine = await _generateRoutineByMode(
        onboardingAI: onboardingAI,
        selectedSplit: selectedSplit,
        workoutDaysCount: actualWorkoutDaysCount,
        useSpecifiedDays: useSpecifiedDays,
        previousRoutine: previousRoutine,
      );

      // Validate and normalize
      final validatedRoutine = RoutineValidator.validateAndNormalize(routine);

      Log.debug("AIService: Routine generation complete");
      return validatedRoutine;
    } catch (e, s) {
      Log.error("AIService: Error generating routine", error: e, stackTrace: s);

      // Provide user-friendly error message
      if (e.toString().contains('complex') ||
          e.toString().contains('truncated') ||
          e.toString().contains('FormatException')) {
        throw Exception(
            'Failed to generate routine. The workout might be too complex.\n'
            'Please try with fewer workout days or a simpler split.');
      }

      rethrow;
    }
  }

  /// Generate routine using appropriate method based on configuration
  Future<Map<String, dynamic>> _generateRoutineByMode({
    required OnboardingDataAI onboardingAI,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
    WeeklyRoutine? previousRoutine,
  }) async {
    // Check if we should use real AI
    final useAI = AIConfig.useRealAI && AIConfig.isConfigured;

    if (useAI) {
      if (!AIConfig.isConfigured) {
        throw Exception(
          'Gemini API key not configured. '
          'Please set GEMINI_API_KEY environment variable.',
        );
      }
      return await _generateWithGemini(
        onboardingAI: onboardingAI,
        selectedSplit: selectedSplit,
        workoutDaysCount: workoutDaysCount,
        useSpecifiedDays: useSpecifiedDays,
        previousRoutine: previousRoutine,
      );
    } else {
      return _generateLocally(
        onboardingAI: onboardingAI,
        selectedSplit: selectedSplit,
        workoutDaysCount: workoutDaysCount,
        useSpecifiedDays: useSpecifiedDays,
      );
    }
  }

  /// Generate using Gemini API with error recovery
  Future<Map<String, dynamic>> _generateWithGemini({
    required OnboardingDataAI onboardingAI,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
    WeeklyRoutine? previousRoutine,
  }) async {
    Log.info('AIService: Generating routine with Gemini AI');

    try {
      final routine = await _geminiGenerator.generate(
        onboardingData: onboardingAI,
        selectedSplit: selectedSplit,
        workoutDaysCount: workoutDaysCount,
        useSpecifiedDays: useSpecifiedDays,
        previousRoutine: previousRoutine,
      );

      Log.info('AIService: Successfully generated routine with Gemini AI');
      return routine;
    } catch (e, s) {
      Log.error(
        'AIService: Gemini AI generation failed',
        error: e,
        stackTrace: s,
      );

      // If it's a complexity issue, suggest simplification
      if (workoutDaysCount > 4) {
        throw Exception(
            'Failed to generate routine for $workoutDaysCount days.\n'
            'This split might be too complex for AI generation.\n\n'
            'Please try:\n'
            '• Reducing to 3-4 workout days\n'
            '• Using Full Body or Upper/Lower split\n'
            '• Generating with local mode (simpler)');
      }

      rethrow;
    }
  }

  /// Generate using local rule-based logic
  Map<String, dynamic> _generateLocally({
    required OnboardingDataAI onboardingAI,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
  }) {
    Log.info('AIService: Generating routine locally (rule-based)');

    return _localGenerator.generate(
      onboardingData: onboardingAI,
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
    final enhanced = onboarding.copyWith();

    // Add regeneration instructions to the AI prompt
    final instructions = <String>[];

    if (options['type'] == 'specificDay' && options['targetDay'] != null) {
      instructions.add(
        "CRITICAL: Regenerate ONLY the ${options['targetDay']} workout. "
        "Keep all other days EXACTLY as they are in the previous routine.",
      );
    }

    if (options['focusMuscles'] != null) {
      instructions.add(
        "CRITICAL: Focus specifically on these muscles: ${options['focusMuscles'].join(', ')}. "
        "Include additional exercises for these muscle groups.",
      );
    }

    if (options['avoidMuscles'] != null) {
      instructions.add(
        "CRITICAL: Avoid exercises targeting these muscles: ${options['avoidMuscles'].join(', ')}. "
        "Replace any exercises that work these muscles.",
      );
    }

    if (options['intensity'] == 'harder') {
      instructions.add(
        "Increase exercise intensity: Add more sets, use higher weight suggestions, "
        "or include more challenging exercise variations.",
      );
    } else if (options['intensity'] == 'easier') {
      instructions.add(
        "Decrease exercise intensity: Reduce sets, use lighter weight suggestions, "
        "or include easier exercise variations.",
      );
    }

    // Store instructions to be used in prompt building
    return onboarding.copyWith(
      regenerationInstructions: instructions.isNotEmpty ? instructions : null,
    );
  }
}
