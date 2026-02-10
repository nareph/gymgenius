// lib/repositories/tracking_repository.dart
import 'package:gymgenius/models/hive/workout_log_model.dart';
import 'package:gymgenius/services/database_service.dart';
import 'package:gymgenius/services/logger_service.dart';

class TrackingRepository {
  final DatabaseService _db;

  TrackingRepository({DatabaseService? database})
      : _db = database ?? DatabaseService.instance;

  String? get _currentUserId => _db.getCurrentUserId();

  /// Provides a stream of the user's data changes
  Stream<void> getUserDocumentStream() {
    if (_currentUserId == null) return const Stream.empty();
    return _db.watchUser(_currentUserId!);
  }

  /// Provides a stream of all workout logs changes
  Stream<void> getWorkoutLogsStream() {
    if (_currentUserId == null) return const Stream.empty();
    return _db.watchWorkoutLogs();
  }

  /// Fetches the detailed workout logs for a specific day
  Future<List<Map<String, dynamic>>> getLogsForDay(DateTime day) async {
    if (_currentUserId == null) {
      Log.debug("TrackingRepository.getLogsForDay: No current user");
      return [];
    }

    Log.debug("========== GETTING LOGS FOR DAY ==========");
    Log.debug("  - Day: $day");
    Log.debug("  - User ID: $_currentUserId");

    final logs = _db.getLogsForDay(_currentUserId!, day);

    Log.debug("  - Found ${logs.length} log(s) for this day");

    final result = logs.map((log) {
      Log.debug("  - Log ID: ${log.id}");
      Log.debug("    - workoutName: ${log.workoutData['workoutName']}");
      Log.debug("    - durationSeconds: ${log.workoutData['durationSeconds']}");
      Log.debug(
          "    - exercises count: ${(log.workoutData['exercises'] as List?)?.length ?? 0}");

      return {...log.workoutData};
    }).toList();

    Log.debug("==========================================");

    return result;
  }

  /// Get all workout logs for the current user
  List<WorkoutLogModel> getAllWorkoutLogs() {
    if (_currentUserId == null) return [];
    return _db.getUserWorkoutLogs(_currentUserId!);
  }
}
