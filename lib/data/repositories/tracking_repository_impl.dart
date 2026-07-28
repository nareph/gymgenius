// lib/data/repositories/tracking_repository_impl.dart

import 'dart:async';
import 'package:gymgenius/data/datasources/local/hive/boxes/hive_datasource.dart';
import 'package:gymgenius/domain/entities/workout_log.dart';
import 'package:gymgenius/domain/repositories/tracking_repository.dart';
import 'package:gymgenius/domain/repositories/workout_repository.dart';
import 'package:gymgenius/data/mappers/workout_mapper.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  TrackingRepositoryImpl({required WorkoutRepository workoutRepository});

  @override
  Future<List<WorkoutLog>> getLogsForDay(DateTime day) async {
    final userId = HiveDatasource.getCurrentUserId();
    if (userId == null) return [];

    final models = HiveDatasource.getLogsForDay(userId, day);
    return models.map(WorkoutMapper.toWorkoutLog).toList();
  }

  @override
  Future<List<WorkoutLog>> getAllLogs() async {
    final userId = HiveDatasource.getCurrentUserId();
    if (userId == null) return [];
    final models = HiveDatasource.getUserWorkoutLogs(userId);
    return models.map(WorkoutMapper.toWorkoutLog).toList();
  }

  @override
  Stream<void> getWorkoutLogsStream() {
    return HiveDatasource.watchWorkoutLogs().map((_) {});
  }
}
