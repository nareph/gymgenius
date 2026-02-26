// lib/repositories/workout_repository.dart
import 'package:gymgenius/models/hive/workout_log_model.dart';
import 'package:gymgenius/models/workout_log.dart';
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
  Future<SaveResult> saveWorkoutLog(WorkoutLog workoutLog) async {
    if (_currentUserId == null) {
      Log.error(
          "WorkoutRepository: Cannot save log, user is not authenticated.");
      return SaveResult.failure;
    }

    try {
      Log.debug("========== SAVING WORKOUT LOG ==========");
      Log.debug("Raw workout log data:");
      Log.debug("  - workoutName: ${workoutLog.workoutName}");
      Log.debug("  - durationSeconds: ${workoutLog.durationSeconds}");
      Log.debug("  - exercises count: ${workoutLog.exercises.length}");

      final hiveModel = WorkoutLogModel(
        id: _uuid.v4(),
        userId: _currentUserId!,
        savedAt: DateTime.now(),
        workoutData: workoutLog.toMap(),
        synced: true,
      );

      Log.debug("WorkoutLogModel created with ID: ${hiveModel.id}");
      Log.debug("  - userId: ${hiveModel.userId}");
      Log.debug("  - savedAt: ${hiveModel.savedAt}");
      Log.debug("  - workoutData keys: ${hiveModel.workoutData.keys.toList()}");

      await _db.saveWorkoutLog(hiveModel);

      // Verify the save by reading it back
      final savedLog = _db.getWorkoutLog(hiveModel.id);
      if (savedLog != null) {
        Log.debug("Verification: Log saved successfully");
        Log.debug(
            "  - Saved workoutName: ${savedLog.workoutData['workoutName']}");
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
  List<WorkoutLog> getUnsyncedLogs() {
    if (_currentUserId == null) return [];
    return _db
        .getUnsyncedLogs(_currentUserId!)
        .map((log) => WorkoutLog.fromHiveModel(log))
        .toList();
  }

  /// Mark a log as synced
  Future<void> markLogAsSynced(String logId) async {
    await _db.markLogAsSynced(logId);
  }
}
