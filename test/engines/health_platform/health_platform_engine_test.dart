import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/blood_glucose_reading.dart';
import 'package:gymgenius/domain/entities/blood_pressure_reading.dart';
import 'package:gymgenius/domain/entities/habit.dart';
import 'package:gymgenius/domain/entities/habit_log.dart';
import 'package:gymgenius/domain/entities/hydration_log.dart';
import 'package:gymgenius/domain/entities/mental_wellness_checkin.dart';
import 'package:gymgenius/domain/enums/blood_pressure_category.dart';
import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/glucose_category.dart';
import 'package:gymgenius/domain/enums/glucose_context.dart';
import 'package:gymgenius/domain/enums/habit_frequency.dart';
import 'package:gymgenius/domain/enums/health_caution_level.dart';
import 'package:gymgenius/domain/enums/stress_level.dart';
import 'package:gymgenius/engines/health_platform/blood_glucose_engine.dart';
import 'package:gymgenius/engines/health_platform/blood_pressure_engine.dart';
import 'package:gymgenius/engines/health_platform/habit_engine.dart';
import 'package:gymgenius/engines/health_platform/health_platform_engine.dart';
import 'package:gymgenius/engines/health_platform/hydration_engine.dart';

void main() {
  group('BloodPressureEngine', () {
    const engine = BloodPressureEngine();

    test('classifies normal and crisis', () {
      final normal = BloodPressureReading(
        id: '1',
        userId: 'u',
        systolic: 118,
        diastolic: 76,
        measuredAt: DateTime(2026, 8, 11),
      );
      final crisis = BloodPressureReading(
        id: '2',
        userId: 'u',
        systolic: 185,
        diastolic: 122,
        measuredAt: DateTime(2026, 8, 11),
      );
      expect(engine.classify(normal), BloodPressureCategory.normal);
      expect(engine.classify(crisis), BloodPressureCategory.crisis);
      expect(engine.cautionFor(BloodPressureCategory.crisis),
          HealthCautionLevel.urgent);
    });
  });

  group('BloodGlucoseEngine', () {
    const engine = BloodGlucoseEngine();

    test('classifies fasting ranges', () {
      final ok = BloodGlucoseReading(
        id: '1',
        userId: 'u',
        valueMmolL: 5.0,
        context: GlucoseContext.fasting,
        measuredAt: DateTime(2026, 8, 11),
      );
      final high = BloodGlucoseReading(
        id: '2',
        userId: 'u',
        valueMmolL: 8.0,
        context: GlucoseContext.fasting,
        measuredAt: DateTime(2026, 8, 11),
      );
      expect(engine.classify(ok), GlucoseCategory.normal);
      expect(engine.classify(high), GlucoseCategory.high);
    });

    test('mg/dL conversion', () {
      final mmol = BloodGlucoseReading.mgDlToMmolL(99);
      expect(mmol, closeTo(5.5, 0.05));
    });
  });

  group('HydrationEngine', () {
    const engine = HydrationEngine();

    test('target from weight and training day', () {
      expect(engine.targetMl(weightKg: 70), 2100);
      expect(
        engine.targetMl(weightKg: 70, isTrainingDay: true),
        2400,
      );
    });

    test('summarizes daily percent', () {
      final status = engine.summarize(
        logs: [
          HydrationLog(
            id: '1',
            userId: 'u',
            amountMl: 1000,
            loggedAt: DateTime(2026, 8, 11, 10),
          ),
        ],
        weightKg: 70,
      );
      expect(status.totalMl, 1000);
      expect(status.percent, closeTo(48, 1));
    });
  });

  group('HabitEngine', () {
    const engine = HabitEngine();
    final day = DateTime(2026, 8, 11);

    test('computes completion and streak', () {
      final habit = Habit(
        id: 'h1',
        userId: 'u',
        name: 'Walk',
        frequency: HabitFrequency.daily,
        createdAt: day,
        updatedAt: day,
      );
      final logs = [
        HabitLog(
          id: 'l1',
          userId: 'u',
          habitId: 'h1',
          date: day,
          completed: true,
          loggedAt: day,
        ),
        HabitLog(
          id: 'l0',
          userId: 'u',
          habitId: 'h1',
          date: day.subtract(const Duration(days: 1)),
          completed: true,
          loggedAt: day.subtract(const Duration(days: 1)),
        ),
      ];
      final stats = engine.computeStats(
        habits: [habit],
        logs: logs,
        day: day,
      );
      expect(stats.completedToday, 1);
      expect(stats.completionPercent, 100);
      expect(stats.longestCurrentStreak, 2);
    });
  });

  group('HealthPlatformEngine facade', () {
    const facade = HealthPlatformEngine();

    test('builds snapshot with caution flags and coach-safe map', () {
      final snap = facade.buildSnapshot(
        userId: 'u',
        now: DateTime(2026, 8, 11),
        latestBp: BloodPressureReading(
          id: 'bp',
          userId: 'u',
          systolic: 150,
          diastolic: 95,
          measuredAt: DateTime(2026, 8, 11),
        ),
        hydrationLogs: [
          HydrationLog(
            id: 'h',
            userId: 'u',
            amountMl: 500,
            loggedAt: DateTime(2026, 8, 11, 9),
          ),
        ],
        todayWellness: MentalWellnessCheckIn(
          id: 'mw',
          userId: 'u',
          date: DateTime(2026, 8, 11),
          mood: 3,
          stress: StressLevel.moderate,
          energy: EnergyLevel.moderate,
        ),
        weightKg: 75,
      );

      expect(snap.hasBpCaution, isTrue);
      expect(snap.hydrationPercent, greaterThan(0));
      final safe = snap.toCoachSafeMap();
      expect(safe.containsKey('hasBpCaution'), isTrue);
      expect(safe.containsKey('systolic'), isFalse);
      expect(safe['hydrationPercent'], snap.hydrationPercent);
    });
  });
}
