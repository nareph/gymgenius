// lib/domain/repositories/recovery_repository.dart

import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/entities/daily_checkin.dart';

/// Contract for recovery persistence operations.
abstract interface class RecoveryRepository {
  Future<RecoveryStatus?> getCurrentRecoveryStatus(String userId);
  Future<void> saveRecoveryStatus(RecoveryStatus status);

  Future<DailyCheckIn?> getDailyCheckIn(String userId, DateTime date);
  Future<void> saveDailyCheckIn(DailyCheckIn checkIn);
  Future<List<DailyCheckIn>> getDailyCheckIns(String userId,
      {DateTime? from, DateTime? to});
}
