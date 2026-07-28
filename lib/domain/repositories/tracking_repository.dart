// lib/domain/repositories/tracking_repository.dart

import 'package:gymgenius/domain/entities/workout_log.dart';

abstract interface class TrackingRepository {
  Future<List<WorkoutLog>> getLogsForDay(DateTime day);
  Future<List<WorkoutLog>> getAllLogs();
  Stream<void> getWorkoutLogsStream();
}
