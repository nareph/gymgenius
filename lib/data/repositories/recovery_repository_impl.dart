import 'package:gymgenius/data/datasources/local/hive/boxes/hive_datasource.dart';
import 'package:gymgenius/data/mappers/recovery_mapper.dart';
import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/repositories/recovery_repository.dart';

/// Hive-backed implementation of [RecoveryRepository].
class RecoveryRepositoryImpl implements RecoveryRepository {
  const RecoveryRepositoryImpl();

  @override
  Future<RecoveryStatus?> getCurrentRecoveryStatus(String userId) async {
    final model = HiveDatasource.getLatestRecoveryStatus(userId);
    if (model == null) return null;
    return RecoveryMapper.toStatusDomain(model);
  }

  @override
  Future<RecoveryStatus?> getRecoveryStatus(
    String userId,
    DateTime date,
  ) async {
    final model = HiveDatasource.getRecoveryStatus(userId, date);
    if (model == null) return null;
    return RecoveryMapper.toStatusDomain(model);
  }

  @override
  Future<void> saveRecoveryStatus(RecoveryStatus status) async {
    final model = RecoveryMapper.toStatusHive(status);
    await HiveDatasource.saveRecoveryStatus(model);
  }

  @override
  Future<DailyCheckIn?> getDailyCheckIn(String userId, DateTime date) async {
    final model = HiveDatasource.getDailyCheckIn(userId, date);
    if (model == null) return null;
    return RecoveryMapper.toCheckInDomain(model);
  }

  @override
  Future<void> saveDailyCheckIn(DailyCheckIn checkIn) async {
    final model = RecoveryMapper.toCheckInHive(checkIn);
    await HiveDatasource.saveDailyCheckIn(model);
    // A real check-in supersedes a prior skip for that day.
    await HiveDatasource.clearCheckInSkipped(checkIn.userId, checkIn.date);
  }

  @override
  Future<List<DailyCheckIn>> getDailyCheckIns(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final models = HiveDatasource.getDailyCheckIns(userId, from: from, to: to);
    return models.map(RecoveryMapper.toCheckInDomain).toList();
  }

  @override
  Future<void> markCheckInSkipped(String userId, DateTime date) async {
    await HiveDatasource.markCheckInSkipped(userId, date);
  }

  @override
  Future<bool> isCheckInSkipped(String userId, DateTime date) async {
    return HiveDatasource.isCheckInSkipped(userId, date);
  }
}
