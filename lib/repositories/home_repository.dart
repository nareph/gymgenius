// lib/repositories/home_repository.dart
import 'dart:async';
import 'package:gymgenius/models/hive/routine_model.dart';
import 'package:gymgenius/models/hive/user_model.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/models/routine.dart';
import 'package:gymgenius/services/ai_service.dart';
import 'package:gymgenius/services/database_service.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:gymgenius/widgets/regeneration/regeneration_options_sheet.dart';
import 'package:uuid/uuid.dart';

class HomeRepository {
  final DatabaseService _db;
  final AIService _aiService;
  final _uuid = const Uuid();

  HomeRepository({
    DatabaseService? database,
    AIService? aiService,
  })  : _db = database ?? DatabaseService.instance,
        _aiService = aiService ?? AIService();

  UserModel? get _currentUser => _db.getCurrentUser();

  /// Stream of user profile changes
  Stream<UserModel?> getUserProfileStream() {
    final userId = _db.getCurrentUserId();
    if (userId == null) return Stream.value(null);

    return _db.watchUser(userId).map((event) {
      return _db.getUser(userId);
    });
  }

  /// Generate a new AI routine based on onboarding data
  Future<WeeklyRoutine> generateNewRoutine(
      OnboardingData onboardingData, WeeklyRoutine? previousRoutine) async {
    try {
      if (_currentUser == null) {
        throw Exception('User not authenticated');
      }

      Log.debug("HomeRepository: Generating AI routine");

      // Call AI service to generate routine
      final aiRoutineData = await _aiService.generateRoutine(
        onboardingData: onboardingData,
        previousRoutine: previousRoutine,
      );

      // Create routine model
      final String newRoutineId = _uuid.v4();
      Map<String, dynamic> dailyWorkoutsFromAIConverted = {};
      final dynamic rawDailyWorkouts = aiRoutineData['dailyWorkouts'];

      if (rawDailyWorkouts is Map) {
        rawDailyWorkouts.forEach((dayKey, exercisesForDay) {
          if (dayKey is String && exercisesForDay is List) {
            dailyWorkoutsFromAIConverted[dayKey.toLowerCase()] = exercisesForDay
                .map((exercise) => exercise is Map
                    ? Map<String, dynamic>.from(exercise)
                    : null)
                .where((item) => item != null)
                .toList()
                .cast<Map<String, dynamic>>();
          }
        });
      }

      int durationInWeeks =
          (aiRoutineData['durationInWeeks'] as num?)?.toInt() ?? 4;
      durationInWeeks = durationInWeeks.clamp(1, 12);

      final now = DateTime.now();
      final expiryDate = now.add(Duration(days: durationInWeeks * 7));

      // Create Hive routine model
      final routineModel = RoutineModel(
        id: newRoutineId,
        userId: _currentUser!.uid,
        name: aiRoutineData['name'] as String? ?? "My New Routine",
        durationInWeeks: durationInWeeks,
        dailyWorkouts: dailyWorkoutsFromAIConverted,
        generatedAt: now,
        expiresAt: expiryDate,
      );

      // Save to database
      await _db.saveRoutine(routineModel);

      // Update user's last routine generation time
      final user = _currentUser!;
      user.profileLastUpdatedAt = now;
      await _db.updateUser(user);

      // Convert to WeeklyRoutine for return (assuming you have fromMap)
      final newRoutine = WeeklyRoutine.fromMap({
        'id': newRoutineId,
        'name': routineModel.name,
        'durationInWeeks': durationInWeeks,
        'dailyWorkouts': dailyWorkoutsFromAIConverted,
        'generatedAt': now,
        'expiresAt': expiryDate,
      });

      Log.debug("HomeRepository: Routine generated successfully");
      return newRoutine;
    } catch (e, s) {
      Log.error("HomeRepository: Error generating routine",
          error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Clear the current routine
  Future<void> clearCurrentRoutine() async {
    if (_currentUser == null) return;

    final routine = _db.getCurrentRoutine(_currentUser!.uid);
    if (routine != null) {
      await _db.deleteRoutine(routine.id);
      Log.debug("HomeRepository: Current routine cleared");
    }
  }

  /// Regenerate routine with specific options
  Future<WeeklyRoutine> regenerateRoutineWithOptions(
    OnboardingData onboardingData,
    WeeklyRoutine? previousRoutine,
    RegenerationOptions options,
  ) async {
    try {
      if (_currentUser == null) {
        throw Exception('User not authenticated');
      }

      Log.debug(
          "HomeRepository: Regenerating routine with options: ${options.toMap()}");

      // Build enhanced parameters for AI
      final enhancedOnboarding = _enhanceOnboardingWithOptions(
        onboardingData,
        options,
      );

      // Call AI service with enhanced parameters
      final aiRoutineData = await _aiService.generateRoutine(
        onboardingData: enhancedOnboarding,
        previousRoutine: previousRoutine,
        regenerationOptions: options.toMap(),
      );

      // Process the new routine based on regeneration type
      final processedRoutine = _processRegeneratedRoutine(
        aiRoutineData,
        previousRoutine,
        options,
      );

      // Save the new routine
      final routineModel = RoutineModel(
        id: processedRoutine.id,
        userId: _currentUser!.uid,
        name: processedRoutine.name,
        durationInWeeks: processedRoutine.durationInWeeks,
        dailyWorkouts: processedRoutine.dailyWorkouts.map(
          (key, value) => MapEntry(
            key,
            value.map((ex) => ex.toMap()).toList(),
          ),
        ),
        generatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(
          Duration(days: processedRoutine.durationInWeeks * 7),
        ),
      );

      await _db.saveRoutine(routineModel);

      // Update user timestamp
      final user = _currentUser!;
      user.profileLastUpdatedAt = DateTime.now();
      await _db.updateUser(user);

      Log.debug("HomeRepository: Routine regenerated successfully");
      return processedRoutine;
    } catch (e, s) {
      Log.error("HomeRepository: Error regenerating routine",
          error: e, stackTrace: s);
      rethrow;
    }
  }

  OnboardingData _enhanceOnboardingWithOptions(
    OnboardingData onboardingData,
    RegenerationOptions options,
  ) {
    // Create a copy of the onboarding data
    OnboardingData enhanced = onboardingData.copyWith();

    // Apply equipment preference if specified
    if (options.newEquipmentPreference != null) {
      enhanced = enhanced.copyWith(
        equipment: [options.newEquipmentPreference!],
      );
    }

    // Add muscle focus/avoid instructions to description
    final List<String> instructions = [];

    if (options.musclesToFocus != null && options.musclesToFocus!.isNotEmpty) {
      instructions.add(
        'CRITICAL: Focus specifically on these muscles: ${options.musclesToFocus!.join(', ')}. '
        'Include additional exercises for these muscle groups.',
      );
    }

    if (options.musclesToAvoid != null && options.musclesToAvoid!.isNotEmpty) {
      instructions.add(
        'CRITICAL: Avoid exercises targeting these muscles: ${options.musclesToAvoid!.join(', ')}. '
        'Replace any exercises that work these muscles.',
      );
    }

    if (options.type == RegenerationType.specificDay &&
        options.targetDay != null) {
      instructions.add(
        'CRITICAL: Only regenerate exercises for ${options.targetDay}. '
        'Keep all other days exactly as they are.',
      );
    }

    if (options.intensity == IntensityLevel.harder) {
      instructions.add(
        'Increase exercise intensity: Add more sets, use higher weight suggestions, '
        'or include more challenging exercise variations.',
      );
    } else if (options.intensity == IntensityLevel.easier) {
      instructions.add(
        'Decrease exercise intensity: Reduce sets, use lighter weight suggestions, '
        'or include easier exercise variations.',
      );
    }

    return enhanced;
  }

  WeeklyRoutine _processRegeneratedRoutine(
    Map<String, dynamic> aiRoutineData,
    WeeklyRoutine? previousRoutine,
    RegenerationOptions options,
  ) {
    // Create the new routine from AI data
    final newRoutine = WeeklyRoutine.fromMap(aiRoutineData);

    if (previousRoutine == null) {
      return newRoutine;
    }

    // Handle different regeneration types
    switch (options.type) {
      case RegenerationType.fullRoutine:
        return newRoutine; // Return completely new routine

      case RegenerationType.specificDay:
        if (options.targetDay == null) return newRoutine;

        // Merge: keep previous days except the target day
        final mergedWorkouts = Map<String, List<RoutineExercise>>.from(
          previousRoutine.dailyWorkouts,
        );

        // Update only the target day
        if (newRoutine.dailyWorkouts.containsKey(options.targetDay!)) {
          mergedWorkouts[options.targetDay!] =
              newRoutine.dailyWorkouts[options.targetDay!]!;
        }

        return previousRoutine.copyWith(
          dailyWorkouts: mergedWorkouts,
          name: '${previousRoutine.name} (Updated)',
          generatedAt: DateTime.now(),
        );

      case RegenerationType.singleExercise:
        if (options.targetExerciseId == null || options.targetDay == null) {
          return newRoutine;
        }

        // Find and replace the specific exercise
        final mergedWorkouts = Map<String, List<RoutineExercise>>.from(
          previousRoutine.dailyWorkouts,
        );

        if (mergedWorkouts.containsKey(options.targetDay!)) {
          final exercises = mergedWorkouts[options.targetDay!]!;
          final index =
              exercises.indexWhere((ex) => ex.id == options.targetExerciseId);

          if (index != -1 &&
              newRoutine.dailyWorkouts.containsKey(options.targetDay!)) {
            final newExercises = newRoutine.dailyWorkouts[options.targetDay!]!;
            if (newExercises.isNotEmpty) {
              exercises[index] = newExercises.first;
              mergedWorkouts[options.targetDay!] = exercises;
            }
          }
        }

        return previousRoutine.copyWith(
          dailyWorkouts: mergedWorkouts,
          name: '${previousRoutine.name} (Updated)',
          generatedAt: DateTime.now(),
        );

      case RegenerationType.withPreferences:
        return newRoutine;
    }
  }

  /// Load cached data (routine and onboarding)
  Future<(WeeklyRoutine?, OnboardingData?)> loadCachedData() async {
    if (_currentUser == null) return (null, null);

    WeeklyRoutine? cachedRoutine;
    OnboardingData? cachedOnboardingData;

    // Load routine
    final routineModel = _db.getCurrentRoutine(_currentUser!.uid);
    if (routineModel != null && !routineModel.isExpired()) {
      cachedRoutine = WeeklyRoutine.fromMap({
        'id': routineModel.id,
        'name': routineModel.name,
        'durationInWeeks': routineModel.durationInWeeks,
        'dailyWorkouts': routineModel.dailyWorkouts,
        'generatedAt': routineModel.generatedAt,
        'expiresAt': routineModel.expiresAt,
      });
    }

    // Load onboarding data
    final user = _db.getUser(_currentUser!.uid);
    if (user?.onboardingData != null) {
      cachedOnboardingData = OnboardingData.fromMap(user!.onboardingData!);
    }

    return (cachedRoutine, cachedOnboardingData);
  }

  /// Check internet connection (always returns true for local-only mode)
  /// You can implement actual connectivity check if needed
  Future<bool> checkInternetConnection() async {
    // For local-only mode, we consider the app always "connected"
    // to its local database
    return true;
  }
}
