import 'package:hive/hive.dart';
import '../models/user_hive_model.dart';
import '../models/health_profile_hive_model.dart';
import '../models/training_program_hive_model.dart';
import '../models/weekly_workout_hive_model.dart';
import '../models/workout_log_hive_model.dart';

class HiveBoxes {
  static const String users = 'users';
  static const String healthProfiles = 'health_profiles';
  static const String trainingPrograms = 'training_programs';
  static const String weeklyWorkouts = 'weekly_workouts';
  static const String workoutLogs = 'workout_logs';
  static const String currentUser = 'current_user';

  static Box<UserHiveModel> get usersBox => Hive.box<UserHiveModel>(users);
  static Box<HealthProfileHiveModel> get healthProfilesBox =>
      Hive.box<HealthProfileHiveModel>(healthProfiles);
  static Box<TrainingProgramHiveModel> get trainingProgramsBox =>
      Hive.box<TrainingProgramHiveModel>(trainingPrograms);
  static Box<WeeklyWorkoutHiveModel> get weeklyWorkoutsBox =>
      Hive.box<WeeklyWorkoutHiveModel>(weeklyWorkouts);
  static Box<WorkoutLogHiveModel> get workoutLogsBox =>
      Hive.box<WorkoutLogHiveModel>(workoutLogs);
  static Box get currentUserBox => Hive.box(currentUser);
}
