import 'package:gymgenius/data/datasources/local/hive/boxes/hive_datasource.dart';
import 'package:gymgenius/data/mappers/health_platform_mapper.dart';
import 'package:gymgenius/domain/entities/blood_glucose_reading.dart';
import 'package:gymgenius/domain/entities/blood_pressure_reading.dart';
import 'package:gymgenius/domain/entities/habit.dart';
import 'package:gymgenius/domain/entities/habit_log.dart';
import 'package:gymgenius/domain/entities/health_platform_snapshot.dart';
import 'package:gymgenius/domain/entities/hydration_log.dart';
import 'package:gymgenius/domain/entities/mental_wellness_checkin.dart';
import 'package:gymgenius/domain/repositories/health_platform_repository.dart';
import 'package:gymgenius/domain/repositories/recovery_repository.dart';
import 'package:gymgenius/engines/health_platform/health_platform_engine.dart';

class HealthPlatformRepositoryImpl implements HealthPlatformRepository {
  final HealthPlatformEngine _engine;
  final RecoveryRepository? _recoveryRepository;

  const HealthPlatformRepositoryImpl({
    HealthPlatformEngine engine = const HealthPlatformEngine(),
    RecoveryRepository? recoveryRepository,
  })  : _engine = engine,
        _recoveryRepository = recoveryRepository;

  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _inRange(DateTime value, DateTime? from, DateTime? to) {
    if (from != null && value.isBefore(_day(from))) return false;
    if (to != null && value.isAfter(_day(to).add(const Duration(days: 1)))) {
      return false;
    }
    return true;
  }

  @override
  Future<void> saveBloodPressure(BloodPressureReading reading) async {
    await HiveDatasource.saveBloodPressure(
      HealthPlatformMapper.fromBloodPressure(reading),
    );
  }

  @override
  Future<BloodPressureReading?> getLatestBloodPressure(String userId) async {
    final model = HiveDatasource.getLatestBloodPressure(userId);
    return model == null ? null : HealthPlatformMapper.toBloodPressure(model);
  }

  @override
  Future<List<BloodPressureReading>> getBloodPressureHistory(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    return HiveDatasource.getBloodPressureHistory(userId)
        .where((m) => _inRange(m.measuredAt, from, to))
        .map(HealthPlatformMapper.toBloodPressure)
        .toList();
  }

  @override
  Future<void> deleteBloodPressure(String id) =>
      HiveDatasource.deleteBloodPressure(id);

  @override
  Future<void> saveBloodGlucose(BloodGlucoseReading reading) async {
    await HiveDatasource.saveBloodGlucose(
      HealthPlatformMapper.fromBloodGlucose(reading),
    );
  }

  @override
  Future<BloodGlucoseReading?> getLatestBloodGlucose(String userId) async {
    final model = HiveDatasource.getLatestBloodGlucose(userId);
    return model == null ? null : HealthPlatformMapper.toBloodGlucose(model);
  }

  @override
  Future<List<BloodGlucoseReading>> getBloodGlucoseHistory(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    return HiveDatasource.getBloodGlucoseHistory(userId)
        .where((m) => _inRange(m.measuredAt, from, to))
        .map(HealthPlatformMapper.toBloodGlucose)
        .toList();
  }

  @override
  Future<void> deleteBloodGlucose(String id) =>
      HiveDatasource.deleteBloodGlucose(id);

  @override
  Future<void> saveHydrationLog(HydrationLog log) async {
    await HiveDatasource.saveHydrationLog(
      HealthPlatformMapper.fromHydration(log),
    );
  }

  @override
  Future<List<HydrationLog>> getHydrationLogsForDay(
    String userId,
    DateTime day,
  ) async {
    final key = _day(day);
    return HiveDatasource.getHydrationLogs(userId)
        .where((m) =>
            DateTime(m.loggedAt.year, m.loggedAt.month, m.loggedAt.day) == key)
        .map(HealthPlatformMapper.toHydration)
        .toList();
  }

  @override
  Future<List<HydrationLog>> getHydrationHistory(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    return HiveDatasource.getHydrationLogs(userId)
        .where((m) => _inRange(m.loggedAt, from, to))
        .map(HealthPlatformMapper.toHydration)
        .toList();
  }

  @override
  Future<void> deleteHydrationLog(String id) =>
      HiveDatasource.deleteHydrationLog(id);

  @override
  Future<void> saveMentalWellness(MentalWellnessCheckIn checkIn) async {
    // One check-in per calendar day — replace existing.
    final existing =
        HiveDatasource.getMentalWellnessForDay(checkIn.userId, checkIn.date);
    if (existing != null && existing.id != checkIn.id) {
      await HiveDatasource.deleteMentalWellness(existing.id);
    }
    await HiveDatasource.saveMentalWellness(
      HealthPlatformMapper.fromMental(checkIn),
    );
  }

  @override
  Future<MentalWellnessCheckIn?> getMentalWellnessForDay(
    String userId,
    DateTime day,
  ) async {
    final model = HiveDatasource.getMentalWellnessForDay(userId, day);
    return model == null ? null : HealthPlatformMapper.toMental(model);
  }

  @override
  Future<List<MentalWellnessCheckIn>> getMentalWellnessHistory(
    String userId, {
    int limit = 14,
  }) async {
    return HiveDatasource.getMentalWellnessHistory(userId)
        .take(limit)
        .map(HealthPlatformMapper.toMental)
        .toList();
  }

  @override
  Future<void> deleteMentalWellness(String id) =>
      HiveDatasource.deleteMentalWellness(id);

  @override
  Future<void> saveHabit(Habit habit) async {
    await HiveDatasource.saveHabit(HealthPlatformMapper.fromHabit(habit));
  }

  @override
  Future<List<Habit>> getHabits(String userId) async {
    return HiveDatasource.getHabits(userId)
        .map(HealthPlatformMapper.toHabit)
        .toList();
  }

  @override
  Future<void> deleteHabit(String id) => HiveDatasource.deleteHabit(id);

  @override
  Future<void> saveHabitLog(HabitLog log) async {
    await HiveDatasource.saveHabitLog(HealthPlatformMapper.fromHabitLog(log));
  }

  @override
  Future<List<HabitLog>> getHabitLogs(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    return HiveDatasource.getHabitLogs(userId)
        .where((m) => _inRange(m.date, from, to))
        .map(HealthPlatformMapper.toHabitLog)
        .toList();
  }

  @override
  Future<void> deleteHabitLog(String id) => HiveDatasource.deleteHabitLog(id);

  @override
  Future<HealthPlatformSnapshot> computeSnapshot(
    String userId, {
    DateTime? now,
    double? weightKg,
    bool isTrainingDay = false,
  }) async {
    final current = now ?? DateTime.now();
    final day = _day(current);

    final checkIn = await _recoveryRepository?.getDailyCheckIn(userId, day);

    final recentWellness = await getMentalWellnessHistory(userId, limit: 14);

    return _engine.buildSnapshot(
      userId: userId,
      now: current,
      latestBp: await getLatestBloodPressure(userId),
      latestGlucose: await getLatestBloodGlucose(userId),
      hydrationLogs: await getHydrationHistory(
        userId,
        from: day.subtract(const Duration(days: 1)),
        to: day,
      ),
      todayWellness: await getMentalWellnessForDay(userId, day),
      recentWellness: recentWellness,
      habits: await getHabits(userId),
      habitLogs: await getHabitLogs(
        userId,
        from: day.subtract(const Duration(days: 60)),
        to: day,
      ),
      recoveryCheckIn: checkIn,
      weightKg: weightKg,
      isTrainingDay: isTrainingDay,
    );
  }
}
