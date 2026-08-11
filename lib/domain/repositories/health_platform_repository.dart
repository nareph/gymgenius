import 'package:gymgenius/domain/entities/blood_glucose_reading.dart';
import 'package:gymgenius/domain/entities/blood_pressure_reading.dart';
import 'package:gymgenius/domain/entities/habit.dart';
import 'package:gymgenius/domain/entities/habit_log.dart';
import 'package:gymgenius/domain/entities/health_platform_snapshot.dart';
import 'package:gymgenius/domain/entities/hydration_log.dart';
import 'package:gymgenius/domain/entities/mental_wellness_checkin.dart';

/// Persistence for Health Platform manual entries and derived snapshot.
abstract interface class HealthPlatformRepository {
  // Blood pressure
  Future<void> saveBloodPressure(BloodPressureReading reading);
  Future<BloodPressureReading?> getLatestBloodPressure(String userId);
  Future<List<BloodPressureReading>> getBloodPressureHistory(
    String userId, {
    DateTime? from,
    DateTime? to,
  });
  Future<void> deleteBloodPressure(String id);

  // Blood glucose
  Future<void> saveBloodGlucose(BloodGlucoseReading reading);
  Future<BloodGlucoseReading?> getLatestBloodGlucose(String userId);
  Future<List<BloodGlucoseReading>> getBloodGlucoseHistory(
    String userId, {
    DateTime? from,
    DateTime? to,
  });
  Future<void> deleteBloodGlucose(String id);

  // Hydration
  Future<void> saveHydrationLog(HydrationLog log);
  Future<List<HydrationLog>> getHydrationLogsForDay(String userId, DateTime day);
  Future<List<HydrationLog>> getHydrationHistory(
    String userId, {
    DateTime? from,
    DateTime? to,
  });
  Future<void> deleteHydrationLog(String id);

  // Mental wellness
  Future<void> saveMentalWellness(MentalWellnessCheckIn checkIn);
  Future<MentalWellnessCheckIn?> getMentalWellnessForDay(
    String userId,
    DateTime day,
  );
  Future<List<MentalWellnessCheckIn>> getMentalWellnessHistory(
    String userId, {
    int limit = 14,
  });
  Future<void> deleteMentalWellness(String id);

  // Habits
  Future<void> saveHabit(Habit habit);
  Future<List<Habit>> getHabits(String userId);
  Future<void> deleteHabit(String id);
  Future<void> saveHabitLog(HabitLog log);
  Future<List<HabitLog>> getHabitLogs(
    String userId, {
    DateTime? from,
    DateTime? to,
  });
  Future<void> deleteHabitLog(String id);

  /// Build + return today's snapshot (does not require caching).
  Future<HealthPlatformSnapshot> computeSnapshot(
    String userId, {
    DateTime? now,
    double? weightKg,
    bool isTrainingDay = false,
  });
}
