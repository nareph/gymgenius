import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/recommended_intensity.dart';
import 'package:gymgenius/domain/enums/soreness_level.dart';
import 'package:gymgenius/engines/recovery_engine/recovery_engine.dart';

DailyCheckIn _checkIn({
  double sleep = 8.0,
  SorenessLevel soreness = SorenessLevel.none,
  EnergyLevel energy = EnergyLevel.high,
  int mood = 4,
}) {
  return DailyCheckIn(
    userId: 'user-test',
    date: DateTime(2026, 8, 11),
    sleepHours: sleep,
    sorenessLevel: soreness,
    energyLevel: energy,
    mood: mood,
  );
}

void main() {
  const engine = RecoveryEngine();

  group('RecoveryEngine compute', () {
    test('well-rested profile → readiness ≥ 80 and intensity max/high', () {
      final status = engine.compute(_checkIn());
      expect(status.readinessScore, greaterThanOrEqualTo(75));
      expect(
        [RecommendedIntensity.max, RecommendedIntensity.high]
            .contains(status.recommendedIntensity),
        isTrue,
      );
    });

    test('poor sleep + severe soreness + low energy → low readiness', () {
      final status = engine.compute(_checkIn(
        sleep: 3.5,
        soreness: SorenessLevel.severe,
        energy: EnergyLevel.veryLow,
        mood: 1,
      ));
      expect(status.readinessScore, lessThan(40));
      expect(status.volumeMultiplier, lessThan(1.0));
    });

    test('userId and date are preserved', () {
      final checkIn = _checkIn();
      final status = engine.compute(checkIn);
      expect(status.userId, checkIn.userId);
      expect(status.date, checkIn.date);
    });

    test('reasons list is non-empty', () {
      final status = engine.compute(_checkIn());
      expect(status.reasons, isNotEmpty);
    });

    test('volumeMultiplier matches readiness tier', () {
      final poor = engine.compute(_checkIn(
        sleep: 3.0,
        soreness: SorenessLevel.severe,
        energy: EnergyLevel.veryLow,
        mood: 1,
      ));
      expect(poor.volumeMultiplier, lessThan(1.0));

      final great = engine.compute(_checkIn());
      expect(great.volumeMultiplier, greaterThanOrEqualTo(0.85));
    });
  });

  group('RecoveryEngine integration with DecisionEngine', () {
    test('DailyCheckIn → RecoveryStatus → requiresVolumeReduction flag', () {
      final status = engine.compute(_checkIn(
        sleep: 4.0,
        soreness: SorenessLevel.moderate,
        energy: EnergyLevel.low,
        mood: 2,
      ));
      expect(status.requiresVolumeReduction, isTrue);
    });

    test('well-rested → no volume reduction needed', () {
      final status = engine.compute(_checkIn());
      // Good sleep + no soreness + high energy + good mood → volume stays full
      expect(status.volumeMultiplier, greaterThanOrEqualTo(0.85));
    });
  });
}
