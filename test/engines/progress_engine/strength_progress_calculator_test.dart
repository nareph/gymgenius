import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/logged_exercise.dart';
import 'package:gymgenius/domain/entities/logged_set.dart';
import 'package:gymgenius/domain/entities/workout_log.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';
import 'package:gymgenius/engines/progress_engine/calculators/strength_progress_calculator.dart';

void main() {
  const calculator = StrengthProgressCalculator();
  final now = DateTime(2026, 8, 11);

  WorkoutLog log(DateTime date, double weight, int reps) {
    return WorkoutLog(
      id: 'log_${date.millisecondsSinceEpoch}',
      userId: 'u1',
      programId: 'p1',
      week: 1,
      day: 'monday',
      startedAt: date,
      endedAt: date.add(const Duration(minutes: 45)),
      durationSeconds: 2700,
      completionScore: 100,
      exercises: [
        LoggedExercise(
          exerciseId: 'bench_press',
          name: 'Bench Press',
          targetSets: 3,
          targetReps: '8',
          targetRestSeconds: 90,
          isTimed: false,
          sets: [
            LoggedSet(
              setNumber: 1,
              reps: reps,
              weightKg: weight,
              loggedAt: date,
            ),
          ],
          completed: true,
        ),
      ],
      savedAt: date,
    );
  }

  group('StrengthProgressCalculator', () {
    test('returns null without completed logs', () {
      final result = calculator.calculate(
        logs: const [],
        from: now.subtract(const Duration(days: 28)),
        to: now,
      );
      expect(result, isNull);
    });

    test('detects strength gain across sessions', () {
      final result = calculator.calculate(
        logs: [
          log(now.subtract(const Duration(days: 14)), 80, 8),
          log(now.subtract(const Duration(days: 7)), 85, 8),
          log(now, 90, 8),
        ],
        from: now.subtract(const Duration(days: 28)),
        to: now,
      );

      expect(result, isNotNull);
      expect(result!.overallTrend, TrendDirection.gaining);
      expect(result.strengthChangePercent, greaterThan(0));
    });

    test('detects plateau after stagnant sessions', () {
      final result = calculator.calculate(
        logs: [
          log(now.subtract(const Duration(days: 14)), 80, 8),
          log(now.subtract(const Duration(days: 7)), 80, 8),
          log(now, 80, 8),
        ],
        from: now.subtract(const Duration(days: 28)),
        to: now,
      );

      expect(result?.plateauDetected, isTrue);
    });
  });
}
