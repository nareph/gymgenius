import 'package:gymgenius/models/hive/training_program_model.dart';
import 'package:gymgenius/models/hive/weekly_workout_model.dart';
import 'package:gymgenius/models/onboarding.dart';

/// Aggregated data for the home screen.
class HomeScreenData {
  final String userId;
  final bool isProfileComplete;
  final OnboardingData? onboardingData;
  final TrainingProgramModel? currentProgram;
  final WeeklyWorkoutModel? currentWeeklyWorkout;

  const HomeScreenData({
    required this.userId,
    required this.isProfileComplete,
    this.onboardingData,
    this.currentProgram,
    this.currentWeeklyWorkout,
  });
}
