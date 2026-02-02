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
      final log = WorkoutLogModel(
        id: _uuid.v4(),
        userId: _currentUserId!,
        savedAt: DateTime.now(),
        workoutData: workoutLog,
        synced: true, // Always synced in local-only mode
      );

      await _db.saveWorkoutLog(log);
      Log.debug("WorkoutRepository: Log successfully saved to database.");

      return SaveResult
          .successOnline; // Consider local save as "online" success
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
