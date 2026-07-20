import 'package:gymgenius/models/hive/training_program_model.dart';
import 'package:gymgenius/models/hive/user_model.dart';
import 'package:gymgenius/models/hive/weekly_workout_model.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/repositories/workout_repository.dart';
import 'package:gymgenius/services/ai_service.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/widgets/regeneration/regeneration_options_sheet.dart';
import 'package:uuid/uuid.dart';

/// Orchestrates training program generation workflow: engine + AI + persistence.
///
/// This service is responsible for:
/// - Creating new Training Programs
/// - Adapting existing Training Programs
/// - Persisting programs and weekly workouts
/// - Managing program lifecycle (activation, expiration, deletion)
class WorkoutService {
  final WorkoutRepository _repository;
  final AIService _aiService;
  final _uuid = const Uuid();

  WorkoutService({
    WorkoutRepository? repository,
    AIService? aiService,
  })  : _repository = repository ?? WorkoutRepository(),
        _aiService = aiService ?? AIService();

  // ============================================================
  // PUBLIC METHODS
  // ============================================================

  /// Generate a new Training Program based on onboarding data.
  ///
  /// Returns the persisted [TrainingProgramModel] with its first weekly workout.
  Future<TrainingProgramModel> generateNewProgram({
    required OnboardingData onboardingData,
    TrainingProgramModel? previousProgram,
  }) async {
    final user = _requireCurrentUser();

    Log.debug('WorkoutService: Generating new training program');

    final aiProgramData = await _aiService.generateProgram(
      onboardingData: onboardingData,
      previousProgram: previousProgram?.toMap(),
    );

    return _persistProgram(user.uid, aiProgramData);
  }

  /// Regenerate/adapt a program with specific options.
  ///
  /// Supports:
  /// - Full program regeneration
  /// - Specific day regeneration
  /// - Single exercise replacement
  /// - Preference-based adaptation
  Future<TrainingProgramModel> regenerateWithOptions({
    required OnboardingData onboardingData,
    TrainingProgramModel? previousProgram,
    required RegenerationOptions options,
  }) async {
    final user = _requireCurrentUser();

    Log.debug(
      'WorkoutService: Regenerating with options: ${options.toMap()}',
    );

    final enhancedOnboarding = _enhanceOnboardingWithOptions(
      onboardingData,
      options,
    );

    final aiProgramData = await _aiService.generateProgram(
      onboardingData: enhancedOnboarding,
      previousProgram: previousProgram?.toMap(),
      regenerationOptions: options.toMap(),
    );

    final processedProgram = _adaptProgramWithOptions(
      aiProgramData,
      previousProgram,
      options,
    );

    final programModel = _createProgramModel(user.uid, processedProgram);

    await _repository.saveProgram(programModel);
    await _repository.updateUserProfileTimestamp(user);

    Log.debug('WorkoutService: Program regenerated successfully');
    return programModel;
  }

  /// Clear the current active program and all associated weekly workouts.
  Future<void> clearCurrentProgram() async {
    final user = _repository.getCurrentUser();
    if (user == null) return;

    final program = _repository.getCurrentProgram();
    if (program != null) {
      await _repository.deleteProgram(program.id);
      Log.debug('WorkoutService: Current program cleared');
    }
  }

  /// Get the current active program with its weekly workout.
  ///
  /// Returns a tuple: (program, weeklyWorkout).
  (TrainingProgramModel?, WeeklyWorkoutModel?) getCurrentProgramWithWeekly() {
    return _repository.getCurrentProgramAndWeekly();
  }

  /// Check if the user has an active program.
  bool hasActiveProgram() {
    return _repository.hasActiveProgram();
  }

  // ============================================================
  // PRIVATE METHODS
  // ============================================================

  Future<TrainingProgramModel> _persistProgram(
    String userId,
    Map<String, dynamic> aiProgramData,
  ) async {
    final programId = _uuid.v4();
    final weeklySchedule = _normalizeWeeklySchedule(
      aiProgramData['weeklySchedule'] ?? aiProgramData['dailyWorkouts'],
    );

    var durationInWeeks =
        (aiProgramData['durationInWeeks'] as num?)?.toInt() ?? 4;
    durationInWeeks = durationInWeeks.clamp(1, 12);

    final now = DateTime.now();
    final expiryDate = now.add(Duration(days: durationInWeeks * 7));

    final programModel = TrainingProgramModel(
      id: programId,
      userId: userId,
      name: aiProgramData['name'] as String? ?? 'My Training Program',
      durationInWeeks: durationInWeeks,
      weeklySchedule: weeklySchedule,
      generatedAt: now,
      expiresAt: expiryDate,
      goal: aiProgramData['goal'] as String?,
      splitType: aiProgramData['splitType'] as String?,
    );

    await _repository.saveProgram(programModel);

    final user = _repository.getCurrentUser();
    if (user != null) {
      await _repository.updateUserProfileTimestamp(user);
    }

    Log.debug('WorkoutService: Program persisted with ID: $programId');
    return programModel;
  }

  Map<String, dynamic> _normalizeWeeklySchedule(dynamic rawSchedule) {
    final converted = <String, dynamic>{};

    if (rawSchedule is Map) {
      rawSchedule.forEach((dayKey, exercisesForDay) {
        if (dayKey is String && exercisesForDay is List) {
          converted[dayKey.toLowerCase()] = exercisesForDay
              .map((exercise) =>
                  exercise is Map ? Map<String, dynamic>.from(exercise) : null)
              .where((item) => item != null)
              .toList()
              .cast<Map<String, dynamic>>();
        }
      });
    }

    return converted;
  }

  TrainingProgramModel _createProgramModel(
    String userId,
    Map<String, dynamic> programData,
  ) {
    final id = _uuid.v4();
    final weeklySchedule = _normalizeWeeklySchedule(
      programData['weeklySchedule'] ?? programData['dailyWorkouts'],
    );

    var durationInWeeks =
        (programData['durationInWeeks'] as num?)?.toInt() ?? 4;
    durationInWeeks = durationInWeeks.clamp(1, 12);

    final now = DateTime.now();

    return TrainingProgramModel(
      id: id,
      userId: userId,
      name: programData['name'] as String? ?? 'My Training Program',
      durationInWeeks: durationInWeeks,
      weeklySchedule: weeklySchedule,
      generatedAt: now,
      expiresAt: now.add(Duration(days: durationInWeeks * 7)),
      goal: programData['goal'] as String?,
      splitType: programData['splitType'] as String?,
    );
  }

  OnboardingData _enhanceOnboardingWithOptions(
    OnboardingData onboardingData,
    RegenerationOptions options,
  ) {
    var enhanced = onboardingData.copyWith();

    if (options.newEquipmentPreference != null) {
      enhanced = enhanced.copyWith(
        equipment: [options.newEquipmentPreference!],
      );
    }

    return enhanced;
  }

  Map<String, dynamic> _adaptProgramWithOptions(
    Map<String, dynamic> aiProgramData,
    TrainingProgramModel? previousProgram,
    RegenerationOptions options,
  ) {
    // If no previous program, return the new one directly
    if (previousProgram == null) {
      return aiProgramData;
    }

    final newSchedule = _normalizeWeeklySchedule(
      aiProgramData['weeklySchedule'] ?? aiProgramData['dailyWorkouts'],
    );

    switch (options.type) {
      case RegenerationType.fullProgram:
        // Full regeneration — use the new program data
        return {
          ...aiProgramData,
          'weeklySchedule': newSchedule,
        };

      case RegenerationType.specificDay:
        if (options.targetDay == null) {
          return {
            ...aiProgramData,
            'weeklySchedule': newSchedule,
          };
        }

        // Merge: keep existing program, replace only the target day
        final mergedSchedule =
            Map<String, dynamic>.from(previousProgram.weeklySchedule);

        if (newSchedule.containsKey(options.targetDay!)) {
          mergedSchedule[options.targetDay!] = newSchedule[options.targetDay!]!;
        }

        return {
          'name': '${previousProgram.name} (Updated)',
          'durationInWeeks': previousProgram.durationInWeeks,
          'weeklySchedule': mergedSchedule,
          'goal': previousProgram.goal,
          'splitType': previousProgram.splitType,
        };

      case RegenerationType.singleExercise:
        if (options.targetExerciseId == null || options.targetDay == null) {
          return {
            ...aiProgramData,
            'weeklySchedule': newSchedule,
          };
        }

        // Replace a single exercise in the target day
        final mergedSchedule =
            Map<String, dynamic>.from(previousProgram.weeklySchedule);

        if (mergedSchedule.containsKey(options.targetDay!)) {
          final exercises = List<Map<String, dynamic>>.from(
            mergedSchedule[options.targetDay!] as List,
          );

          final exerciseIndex = exercises.indexWhere(
            (ex) => ex['id'] == options.targetExerciseId,
          );

          if (exerciseIndex != -1 &&
              newSchedule.containsKey(options.targetDay!)) {
            final newExercises = List<Map<String, dynamic>>.from(
                newSchedule[options.targetDay!] as List);
            if (newExercises.isNotEmpty) {
              // Preserve the exercise ID if it exists
              final replacement = Map<String, dynamic>.from(newExercises.first);
              replacement['id'] ??= options.targetExerciseId;
              exercises[exerciseIndex] = replacement;
              mergedSchedule[options.targetDay!] = exercises;
            }
          }
        }

        return {
          'name': '${previousProgram.name} (Updated)',
          'durationInWeeks': previousProgram.durationInWeeks,
          'weeklySchedule': mergedSchedule,
          'goal': previousProgram.goal,
          'splitType': previousProgram.splitType,
        };

      case RegenerationType.withPreferences:
        // Use new program but preserve some metadata
        return {
          ...aiProgramData,
          'weeklySchedule': newSchedule,
          'name': aiProgramData['name'] as String? ??
              '${previousProgram.name} (Adapted)',
        };
    }
  }

  UserModel _requireCurrentUser() {
    final user = _repository.getCurrentUser();
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user;
  }
}
