import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/soreness_level.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';
import 'package:gymgenius/engines/progress_engine/calculators/weight_progress_calculator.dart';
import 'package:gymgenius/engines/progress_engine/progress_thresholds.dart';

void main() {
  const calculator = WeightProgressCalculator();
  final now = DateTime(2026, 8, 11);

  DailyCheckIn checkIn(String userId, DateTime date, double weight) {
    return DailyCheckIn(
      userId: userId,
      date: date,
      sleepHours: 7,
      sorenessLevel: SorenessLevel.none,
      energyLevel: EnergyLevel.high,
      mood: 4,
      weightKg: weight,
    );
  }

  group('WeightProgressCalculator', () {
    test('returns insufficient data with fewer than 3 points', () {
      final trend = calculator.calculate(
        checkIns: [
          checkIn('u1', now.subtract(const Duration(days: 2)), 80),
          checkIn('u1', now.subtract(const Duration(days: 1)), 79.5),
        ],
        from: now.subtract(const Duration(days: 28)),
        to: now,
      );

      expect(trend?.direction, TrendDirection.insufficientData);
      expect(trend?.hasSufficientData, isFalse);
    });

    test('detects weight loss trend', () {
      final trend = calculator.calculate(
        checkIns: [
          checkIn('u1', now.subtract(const Duration(days: 20)), 82),
          checkIn('u1', now.subtract(const Duration(days: 14)), 81),
          checkIn('u1', now.subtract(const Duration(days: 7)), 80),
          checkIn('u1', now, 79),
        ],
        from: now.subtract(const Duration(days: 28)),
        to: now,
      );

      expect(trend?.hasSufficientData, isTrue);
      expect(trend?.direction, TrendDirection.losing);
      expect(trend!.changeKg, lessThan(0));
    });

    test('filters abnormal daily weight spikes', () {
      final trend = calculator.calculate(
        checkIns: [
          checkIn('u1', now.subtract(const Duration(days: 6)), 80),
          checkIn('u1', now.subtract(const Duration(days: 5)), 85),
          checkIn('u1', now.subtract(const Duration(days: 4)), 79.8),
          checkIn('u1', now.subtract(const Duration(days: 2)), 79.5),
        ],
        from: now.subtract(const Duration(days: 28)),
        to: now,
      );

      expect(trend?.dataPointCount, lessThan(4));
    });

    test('computes distance to target weight', () {
      final trend = calculator.calculate(
        checkIns: [
          checkIn('u1', now.subtract(const Duration(days: 6)), 82),
          checkIn('u1', now.subtract(const Duration(days: 4)), 81),
          checkIn('u1', now, 80),
        ],
        from: now.subtract(const Duration(days: 28)),
        to: now,
        targetWeightKg: 75,
      );

      expect(trend?.distanceToTargetKg, 5);
    });
  });

  group('ProgressThresholds', () {
    test('estimated1Rm uses Epley formula', () {
      expect(
        ProgressThresholds.estimated1Rm(100, 5),
        closeTo(116.67, 0.01),
      );
    });
  });
}
