import 'package:hive/hive.dart';
import '../models/user_hive_model.dart';
import '../models/health_profile_hive_model.dart';
import '../models/training_program_hive_model.dart';
import '../models/workout_log_hive_model.dart';
import '../models/nutrition_profile_hive_model.dart';
import '../models/nutrition_plan_hive_model.dart';
import '../models/recovery_status_hive_model.dart';
import '../models/daily_checkin_hive_model.dart';
import '../models/progress_snapshot_hive_model.dart';

class HiveBoxes {
  static const String users = 'users';
  static const String healthProfiles = 'health_profiles';
  static const String trainingPrograms = 'training_programs';
  static const String weeklyWorkouts = 'weekly_workouts';
  static const String workoutLogs = 'workout_logs';
  static const String currentUser = 'current_user';
  static const String nutritionProfiles = 'nutrition_profiles';
  static const String nutritionPlans = 'nutrition_plans';
  static const String recoveryStatuses = 'recovery_statuses';
  static const String dailyCheckIns = 'daily_checkins';
  static const String progressSnapshots = 'progress_snapshots';

  static Box<UserHiveModel> get usersBox => Hive.box<UserHiveModel>(users);
  static Box<HealthProfileHiveModel> get healthProfilesBox =>
      Hive.box<HealthProfileHiveModel>(healthProfiles);
  static Box<TrainingProgramHiveModel> get trainingProgramsBox =>
      Hive.box<TrainingProgramHiveModel>(trainingPrograms);
  static Box<WorkoutLogHiveModel> get workoutLogsBox =>
      Hive.box<WorkoutLogHiveModel>(workoutLogs);
  static Box get currentUserBox => Hive.box(currentUser);
  static Box<NutritionProfileHiveModel> get nutritionProfilesBox =>
      Hive.box<NutritionProfileHiveModel>(nutritionProfiles);
  static Box<NutritionPlanHiveModel> get nutritionPlansBox =>
      Hive.box<NutritionPlanHiveModel>(nutritionPlans);
  static Box<RecoveryStatusHiveModel> get recoveryStatusesBox =>
      Hive.box<RecoveryStatusHiveModel>(recoveryStatuses);
  static Box<DailyCheckInHiveModel> get dailyCheckInsBox =>
      Hive.box<DailyCheckInHiveModel>(dailyCheckIns);
  static Box<ProgressSnapshotHiveModel> get progressSnapshotsBox =>
      Hive.box<ProgressSnapshotHiveModel>(progressSnapshots);
}
