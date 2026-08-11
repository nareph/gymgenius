import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/recommended_intensity.dart';
import 'package:gymgenius/domain/enums/soreness_level.dart';
import 'package:gymgenius/domain/repositories/recovery_repository.dart';

/// Minimal in-memory stub for [RecoveryRepository].
class _InMemoryRecoveryRepo implements RecoveryRepository {
  final _statuses = <String, RecoveryStatus>{};
  final _checkIns = <String, DailyCheckIn>{};
  final _skipped = <String>{};

  String _key(String userId, DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return '${userId}_${d.toIso8601String()}';
  }

  @override
  Future<RecoveryStatus?> getCurrentRecoveryStatus(String userId) async {
    final entries = _statuses.values.where((s) => s.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return entries.isEmpty ? null : entries.first;
  }

  @override
  Future<RecoveryStatus?> getRecoveryStatus(
    String userId,
    DateTime date,
  ) async =>
      _statuses[_key(userId, date)];

  @override
  Future<void> saveRecoveryStatus(RecoveryStatus status) async {
    _statuses[_key(status.userId, status.date)] = status;
  }

  @override
  Future<DailyCheckIn?> getDailyCheckIn(String userId, DateTime date) async =>
      _checkIns[_key(userId, date)];

  @override
  Future<void> saveDailyCheckIn(DailyCheckIn checkIn) async {
    _checkIns[_key(checkIn.userId, checkIn.date)] = checkIn;
    _skipped.remove(_key(checkIn.userId, checkIn.date));
  }

  @override
  Future<List<DailyCheckIn>> getDailyCheckIns(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    return _checkIns.values.where((c) {
      if (c.userId != userId) return false;
      if (from != null && c.date.isBefore(from)) return false;
      if (to != null && c.date.isAfter(to)) return false;
      return true;
    }).toList();
  }

  @override
  Future<void> markCheckInSkipped(String userId, DateTime date) async {
    _skipped.add(_key(userId, date));
  }

  @override
  Future<bool> isCheckInSkipped(String userId, DateTime date) async =>
      _skipped.contains(_key(userId, date));
}

void main() {
  group('Recovery persistence (in-memory)', () {
    test('saveDailyCheckIn then getDailyCheckIn returns same values', () async {
      final repo = _InMemoryRecoveryRepo();
      final date = DateTime(2026, 8, 11);

      final checkIn = DailyCheckIn(
        userId: 'user-1',
        date: date,
        sleepHours: 7.5,
        sorenessLevel: SorenessLevel.mild,
        energyLevel: EnergyLevel.high,
        mood: 4,
      );

      await repo.saveDailyCheckIn(checkIn);
      final result = await repo.getDailyCheckIn('user-1', date);

      expect(result, isNotNull);
      expect(result!.sleepHours, checkIn.sleepHours);
      expect(result.sorenessLevel, checkIn.sorenessLevel);
      expect(result.energyLevel, checkIn.energyLevel);
      expect(result.mood, checkIn.mood);
    });

    test('replace check-in for same day overwrites previous', () async {
      final repo = _InMemoryRecoveryRepo();
      final date = DateTime(2026, 8, 11);

      await repo.saveDailyCheckIn(DailyCheckIn(
        userId: 'user-1',
        date: date,
        sleepHours: 6.0,
        sorenessLevel: SorenessLevel.none,
        energyLevel: EnergyLevel.moderate,
        mood: 3,
      ));
      await repo.saveDailyCheckIn(DailyCheckIn(
        userId: 'user-1',
        date: date,
        sleepHours: 8.0,
        sorenessLevel: SorenessLevel.mild,
        energyLevel: EnergyLevel.high,
        mood: 5,
      ));

      final result = await repo.getDailyCheckIn('user-1', date);
      expect(result!.sleepHours, 8.0);
      expect(result.mood, 5);
    });

    test('getRecoveryStatus for date vs absent', () async {
      final repo = _InMemoryRecoveryRepo();
      final date = DateTime(2026, 8, 11);
      expect(await repo.getRecoveryStatus('user-1', date), isNull);

      await repo.saveRecoveryStatus(RecoveryStatus(
        userId: 'user-1',
        date: date,
        recoveryScore: 80,
        fatigueScore: 20,
        readinessScore: 85,
        recommendedIntensity: RecommendedIntensity.high,
        volumeMultiplier: 1.0,
        reasons: const ['Good sleep'],
      ));

      final result = await repo.getRecoveryStatus('user-1', date);
      expect(result, isNotNull);
      expect(result!.readinessScore, 85);
    });

    test('two users same day stay isolated', () async {
      final repo = _InMemoryRecoveryRepo();
      final date = DateTime(2026, 8, 11);

      await repo.saveDailyCheckIn(DailyCheckIn(
        userId: 'user-a',
        date: date,
        sleepHours: 8.0,
        sorenessLevel: SorenessLevel.none,
        energyLevel: EnergyLevel.high,
        mood: 5,
      ));
      await repo.saveDailyCheckIn(DailyCheckIn(
        userId: 'user-b',
        date: date,
        sleepHours: 5.0,
        sorenessLevel: SorenessLevel.severe,
        energyLevel: EnergyLevel.low,
        mood: 2,
      ));

      expect((await repo.getDailyCheckIn('user-a', date))!.sleepHours, 8.0);
      expect((await repo.getDailyCheckIn('user-b', date))!.sleepHours, 5.0);
    });

    test('skip flag persists and clears on real check-in', () async {
      final repo = _InMemoryRecoveryRepo();
      final date = DateTime(2026, 8, 11);

      await repo.markCheckInSkipped('user-1', date);
      expect(await repo.isCheckInSkipped('user-1', date), isTrue);

      await repo.saveDailyCheckIn(DailyCheckIn(
        userId: 'user-1',
        date: date,
        sleepHours: 7.0,
        sorenessLevel: SorenessLevel.none,
        energyLevel: EnergyLevel.moderate,
        mood: 3,
      ));
      expect(await repo.isCheckInSkipped('user-1', date), isFalse);
    });

    test('check-in exists without RecoveryStatus is allowed', () async {
      final repo = _InMemoryRecoveryRepo();
      final date = DateTime(2026, 8, 11);
      await repo.saveDailyCheckIn(DailyCheckIn(
        userId: 'user-1',
        date: date,
        sleepHours: 7.0,
        sorenessLevel: SorenessLevel.none,
        energyLevel: EnergyLevel.moderate,
        mood: 3,
      ));
      expect(await repo.getDailyCheckIn('user-1', date), isNotNull);
      expect(await repo.getRecoveryStatus('user-1', date), isNull);
    });

    test('DailyCheckIn clamps invalid mood/sleep', () {
      final checkIn = DailyCheckIn(
        userId: 'u',
        date: DateTime(2026, 8, 11),
        sleepHours: 99,
        sorenessLevel: SorenessLevel.none,
        energyLevel: EnergyLevel.high,
        mood: 99,
      );
      expect(checkIn.sleepHours, DailyCheckIn.maxSleepHours);
      expect(checkIn.mood, DailyCheckIn.maxMood);
      expect(checkIn.isValid, isTrue);
    });
  });
}
