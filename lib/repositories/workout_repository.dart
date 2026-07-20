import 'package:gymgenius/models/hive/training_program_model.dart';
import 'package:gymgenius/models/hive/weekly_workout_model.dart';
import 'package:gymgenius/models/hive/user_model.dart';
import 'package:gymgenius/models/hive/workout_log_model.dart';
import 'package:gymgenius/models/workout_log.dart';
import 'package:gymgenius/services/database_service.dart';
import 'package:uuid/uuid.dart';

/// Data access for workout and training program persistence.
///
/// No business logic — only persistence operations.
class WorkoutRepository {
  final DatabaseService _db;
  final Uuid _uuid;

  WorkoutRepository({DatabaseService? database})
      : _db = database ?? DatabaseService.instance,
        _uuid = const Uuid();

  // ============================================================
  // USER HELPERS
  // ============================================================

  String? getCurrentUserId() => _db.getCurrentUserId();

  UserModel? getCurrentUser() => _db.getCurrentUser();

  Future<void> updateUserProfileTimestamp(UserModel user) async {
    user.profileLastUpdatedAt = DateTime.now();
    await _db.updateUser(user);
  }

  // ============================================================
  // TRAINING PROGRAM OPERATIONS
  // ============================================================

  TrainingProgramModel? getCurrentProgram() {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    return _db.getCurrentProgram(userId);
  }

  TrainingProgramModel? getProgram(String id) {
    return _db.getProgram(id);
  }

  List<TrainingProgramModel> getUserPrograms() {
    final userId = getCurrentUserId();
    if (userId == null) return [];
    return _db.getUserPrograms(userId);
  }

  Future<void> saveProgram(TrainingProgramModel program) async {
    await _db.saveProgram(program);
    final user = getCurrentUser();
    if (user != null) {
      await updateUserProfileTimestamp(user);
    }
  }

  Future<void> deleteProgram(String programId) async {
    await _db.deleteProgram(programId);
  }

  bool hasActiveProgram() {
    final program = getCurrentProgram();
    return program != null && program.isActive;
  }

  // ============================================================
  // WEEKLY WORKOUT OPERATIONS
  // ============================================================

  WeeklyWorkoutModel? getCurrentWeeklyWorkout(String programId) {
    return _db.getCurrentWeeklyWorkout(programId);
  }

  WeeklyWorkoutModel? getWeeklyWorkout(String id) {
    return _db.getWeeklyWorkout(id);
  }

  List<WeeklyWorkoutModel> getProgramWeeklyWorkouts(String programId) {
    return _db.getProgramWeeklyWorkouts(programId);
  }

  WeeklyWorkoutModel? getWeeklyWorkoutByWeekNumber(
    String programId,
    int weekNumber,
  ) {
    return _db.getWeeklyWorkoutByWeekNumber(programId, weekNumber);
  }

  Future<void> saveWeeklyWorkout(WeeklyWorkoutModel weekly) async {
    await _db.saveWeeklyWorkout(weekly);
  }

  Future<void> deactivateWeeklyWorkout(String id) async {
    await _db.deactivateWeeklyWorkout(id);
  }

  Future<void> deleteWeeklyWorkout(String id) async {
    await _db.deleteWeeklyWorkout(id);
  }

  // ============================================================
  // WORKOUT LOG OPERATIONS
  // ============================================================

  /// Save a workout log to the local database.
  Future<void> saveWorkoutLog(WorkoutLog log) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final model = WorkoutLogModel(
      id: _uuid.v4(),
      userId: userId,
      savedAt: DateTime.now(),
      workoutData: log.toMap(),
      synced: true, // toujours synced en local-first
    );

    await _db.saveWorkoutLog(model);
  }

  // ============================================================
  // CONVENIENCE METHODS
  // ============================================================

  (TrainingProgramModel?, WeeklyWorkoutModel?) getCurrentProgramAndWeekly() {
    final program = getCurrentProgram();
    if (program == null) return (null, null);
    final weekly = getCurrentWeeklyWorkout(program.id);
    return (program, weekly);
  }

  bool hasActiveWeeklyWorkout() {
    final program = getCurrentProgram();
    if (program == null) return false;
    return getCurrentWeeklyWorkout(program.id) != null;
  }
}
