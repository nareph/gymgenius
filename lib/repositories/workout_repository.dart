// lib/repositories/workout_repository.dart
import 'package:gymgenius/models/hive/workout_log_model.dart';
import 'package:gymgenius/services/database_service.dart';
import 'package:gymgenius/services/logger_service.dart';
import 'package:uuid/uuid.dart';

enum SaveResult { successOnline, successOffline, failure }

class WorkoutRepository {
  final DatabaseService _db;
  final _uuid = const Uuid();

  WorkoutRepository({DatabaseService? database})
      : _db = database ?? DatabaseService.instance;

  String? get _currentUserId => _db.getCurrentUserId();

  /// Saves a completed workout log to local database
  Future<SaveResult> saveWorkoutLog(Map<String, dynamic> workoutLog) async {
    if (_currentUserId == null) {
      Log.error(
          "WorkoutRepository: Cannot save log, user is not authenticated.");
      return SaveResult.failure;
    }

    try {
      Log.debug("========== SAVING WORKOUT LOG ==========");
      Log.debug("Raw workout log data:");
      Log.debug("  - workoutName: ${workoutLog['workoutName']}");
      Log.debug("  - durationSeconds: ${workoutLog['durationSeconds']}");
      Log.debug(
          "  - exercises count: ${(workoutLog['exercises'] as List?)?.length ?? 0}");
      Log.debug(
          "  - totalPlannedExercises: ${workoutLog['totalPlannedExercises']}");
      Log.debug(
          "  - totalCompletedExercises: ${workoutLog['totalCompletedExercises']}");

      final log = WorkoutLogModel(
        id: _uuid.v4(),
        userId: _currentUserId!,
        savedAt: DateTime.now(),
        workoutData: workoutLog,
        synced: true, // Always synced in local-only mode
      );

      Log.debug("WorkoutLogModel created with ID: ${log.id}");
      Log.debug("  - userId: ${log.userId}");
      Log.debug("  - savedAt: ${log.savedAt}");
      Log.debug("  - workoutData keys: ${log.workoutData.keys.toList()}");

      await _db.saveWorkoutLog(log);

      // Verify the save by reading it back
      final savedLog = _db.getWorkoutLog(log.id);
      if (savedLog != null) {
        Log.debug("Verification: Log saved successfully");
        Log.debug(
            "  - Saved workoutName: ${savedLog.workoutData['workoutName']}");
        Log.debug(
            "  - Saved durationSeconds: ${savedLog.workoutData['durationSeconds']}");
        Log.debug(
            "  - Saved exercises count: ${(savedLog.workoutData['exercises'] as List?)?.length ?? 0}");
      } else {
        Log.error("Verification FAILED: Could not read back saved log!");
      }

      Log.debug("========================================");
      Log.debug("WorkoutRepository: Log successfully saved to database.");
      return SaveResult.successOnline;
    } catch (e, s) {
      Log.error("WorkoutRepository: Failed to save workout log",
          error: e, stackTrace: s);
      return SaveResult.failure;
    }
  }

  /// Get unsynced logs (useful if you later add cloud sync)
  List<WorkoutLogModel> getUnsyncedLogs() {
    if (_currentUserId == null) return [];
    return _db.getUnsyncedLogs(_currentUserId!);
  }

  /// Mark a log as synced
  Future<void> markLogAsSynced(String logId) async {
    await _db.markLogAsSynced(logId);
  }
}
