import 'package:gymgenius/data/datasources/local/hive/boxes/hive_datasource.dart';
import 'package:gymgenius/data/mappers/progress_mapper.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/entities/weekly_progress_report.dart';
import 'package:gymgenius/domain/enums/progress_period.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/enums/workout_frequency.dart';
import 'package:gymgenius/domain/repositories/health_repository.dart';
import 'package:gymgenius/domain/repositories/progress_repository.dart';
import 'package:gymgenius/domain/repositories/recovery_repository.dart';
import 'package:gymgenius/domain/repositories/workout_repository.dart';
import 'package:gymgenius/engines/progress_engine/progress_engine.dart';

/// Hive-backed implementation of [ProgressRepository].
class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressEngine _engine;
  final RecoveryRepository _recoveryRepository;
  final WorkoutRepository _workoutRepository;
  final HealthRepository _healthRepository;

  const ProgressRepositoryImpl({
    ProgressEngine engine = const ProgressEngine(),
    required RecoveryRepository recoveryRepository,
    required WorkoutRepository workoutRepository,
    required HealthRepository healthRepository,
  })  : _engine = engine,
        _recoveryRepository = recoveryRepository,
        _workoutRepository = workoutRepository,
        _healthRepository = healthRepository;

  @override
  Future<ProgressSnapshot?> getLatestSnapshot(String userId) async {
    final model = HiveDatasource.getLatestProgressSnapshot(userId);
    if (model == null) return null;
    return ProgressMapper.toDomain(model);
  }

  @override
  Future<ProgressSnapshot?> getSnapshot(
    String userId,
    DateTime computedAt,
  ) async {
    final model = HiveDatasource.getProgressSnapshot(userId, computedAt);
    if (model == null) return null;
    return ProgressMapper.toDomain(model);
  }

  @override
  Future<void> saveSnapshot(ProgressSnapshot snapshot) async {
    final model = ProgressMapper.toHive(snapshot);
    await HiveDatasource.saveProgressSnapshot(model);
  }

  @override
  Future<List<ProgressSnapshot>> getSnapshotHistory(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final models =
        HiveDatasource.getProgressSnapshots(userId, from: from, to: to);
    return models.map(ProgressMapper.toDomain).toList();
  }

  @override
  Future<ProgressSnapshot> computeSnapshot(
    String userId, {
    ProgressPeriod period = ProgressPeriod.weekly,
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();
    final from = current.subtract(period.lookback);

    final checkIns = await _recoveryRepository.getDailyCheckIns(
      userId,
      from: from,
      to: current,
    );

    final logs = await _workoutRepository.getWorkoutLogs(
      userId,
      from: from,
      to: current,
    );

    await _workoutRepository.getCurrentProgram(userId);

    final healthProfile = await _healthRepository.getHealthProfile(userId);
    final targetWeight = healthProfile?.targetWeightKg;

    // Determine targetPerWeek from profile frequency.
    final targetPerWeek = healthProfile?.training.frequency.toDays() ?? 4;

    final snapshot = _engine.computeSnapshot(
      userId: userId,
      now: current,
      period: period,
      checkIns: checkIns,
      workoutLogs: logs,
      targetPerWeek: targetPerWeek, // NEW: use targetPerWeek
      targetWeightKg: targetWeight,
    );

    await saveSnapshot(snapshot);
    return snapshot;
  }

  @override
  Future<WeeklyProgressReport> computeWeeklyReport(
    String userId, {
    DateTime? weekStart,
  }) async {
    final now = DateTime.now();
    final start = weekStart ?? _mondayOfWeek(now);

    final checkIns = await _recoveryRepository.getDailyCheckIns(
      userId,
      from: start.subtract(const Duration(days: 7)),
      to: start.add(const Duration(days: 13)),
    );

    final logs = await _workoutRepository.getWorkoutLogs(
      userId,
      from: start.subtract(const Duration(days: 28)),
      to: start.add(const Duration(days: 6)),
    );

    final recoveryStatuses = <RecoveryStatus>[];
    for (var i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final status = await _recoveryRepository.getRecoveryStatus(userId, day);
      if (status != null) recoveryStatuses.add(status);
    }

    final healthProfile = await _healthRepository.getHealthProfile(userId);
    final targetPerWeek = healthProfile?.training.frequency.toDays() ?? 4;

    return _engine.buildWeeklyReport(
      userId: userId,
      weekStart: start,
      checkIns: checkIns,
      workoutLogs: logs,
      targetPerWeek: targetPerWeek,
      recoveryStatuses: recoveryStatuses,
    );
  }

  DateTime _mondayOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }
}
