
// lib/repositories/tracking_repository.dart
import 'package:gymgenius/models/hive/workout_log_model.dart';
import 'package:gymgenius/services/database_service.dart';

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
    if (_currentUserId == null) return [];

    final logs = _db.getLogsForDay(_currentUserId!, day);
    return logs.map((log) => {...log.toMap()}).toList();
  }

  /// Get all workout logs for the current user
  List<WorkoutLogModel> getAllWorkoutLogs() {
    if (_currentUserId == null) return [];
    return _db.getUserWorkoutLogs(_currentUserId!);
  }
}

