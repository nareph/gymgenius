import 'dart:async';

import 'package:gymgenius/models/home_screen_data.dart';
import 'package:gymgenius/models/hive/training_program_model.dart';
import 'package:gymgenius/models/hive/user_model.dart';
import 'package:gymgenius/models/hive/weekly_workout_model.dart';
import 'package:gymgenius/models/onboarding.dart';
import 'package:gymgenius/repositories/workout_repository.dart';
import 'package:gymgenius/services/database_service.dart';
import 'package:gymgenius/services/workout_service.dart';
import 'package:gymgenius/widgets/regeneration/regeneration_options_sheet.dart';

/// Data access for the home screen — delegates generation to WorkoutService.
class HomeRepository {
  final DatabaseService _db;
  final WorkoutRepository _workoutRepository;
  final WorkoutService _workoutService;

  HomeRepository({
    DatabaseService? database,
    WorkoutRepository? workoutRepository,
    WorkoutService? workoutService,
  })  : _db = database ?? DatabaseService.instance,
        _workoutRepository = workoutRepository ?? WorkoutRepository(),
        _workoutService =
            workoutService ?? WorkoutService(repository: workoutRepository);

  /// Stream of user profile changes
  Stream<UserModel?> getUserProfileStream() {
    final userId = _db.getCurrentUserId();
    if (userId == null) return Stream.value(null);

    return _db.watchUser(userId).map((event) {
      return _db.getUser(userId);
    });
  }

  /// Load all data needed by the home screen
  Future<HomeScreenData> loadHomeScreenData() async {
    final userId = _db.getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final user = _db.getUser(userId);
    if (user == null) {
      throw Exception('User profile not found');
    }

    OnboardingData? onboardingData;
    if (user.onboardingData != null) {
      onboardingData = OnboardingData.fromMap(user.onboardingData!);
    }

    TrainingProgramModel? currentProgram;
    final program = _workoutRepository.getCurrentProgram();
    if (program != null && !program.isExpired()) {
      currentProgram = program;
    }

    WeeklyWorkoutModel? currentWeekly;
    if (currentProgram != null) {
      currentWeekly = _workoutRepository.getCurrentWeeklyWorkout(
        currentProgram.id,
      );
    }

    return HomeScreenData(
      userId: userId,
      isProfileComplete: user.onboardingCompleted,
      onboardingData: onboardingData,
      currentProgram: currentProgram,
      currentWeeklyWorkout: currentWeekly,
    );
  }

  Future<TrainingProgramModel> generateNewProgram(
    OnboardingData onboardingData,
    TrainingProgramModel? previousProgram,
  ) {
    return _workoutService.generateNewProgram(
      onboardingData: onboardingData,
      previousProgram: previousProgram,
    );
  }

  Future<void> clearCurrentProgram() => _workoutService.clearCurrentProgram();

  Future<TrainingProgramModel> regenerateProgramWithOptions(
    OnboardingData onboardingData,
    TrainingProgramModel? previousProgram,
    RegenerationOptions options,
  ) {
    return _workoutService.regenerateWithOptions(
      onboardingData: onboardingData,
      previousProgram: previousProgram,
      options: options,
    );
  }

  Future<(TrainingProgramModel?, OnboardingData?)> loadCachedData() async {
    final data = await loadHomeScreenData();
    return (data.currentProgram, data.onboardingData);
  }

  Future<bool> checkInternetConnection() async => true;
}
