// lib/domain/entities/daily_checkin.dart

import 'package:gymgenius/domain/value_objects/recovery_data.dart';

/// Domain Entity representing the user's daily check-in.
class DailyCheckIn {
  final String userId;
  final DateTime date;
  final double weightKg;
  final RecoveryData recovery;

  const DailyCheckIn({
    required this.userId,
    required this.date,
    required this.weightKg,
    required this.recovery,
  });

  bool get isWeightLogged => weightKg > 0;
  bool get isSleepLogged => recovery.sleepHours > 0;

  @override
  String toString() => 'DailyCheckIn($date, weight: $weightKg kg)';
}
