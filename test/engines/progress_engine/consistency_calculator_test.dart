import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/workout_log.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';
import 'package:gymgenius/engines/progress_engine/calculators/consistency_calculator.dart';

void main() {
  const calculator = ConsistencyCalculator();
  final now = DateTime(2026, 8, 11);

  WorkoutLog completedLog(DateTime date) {
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
      exercises: const [],
      savedAt: date,
    );
  }

  group('ConsistencyCalculator', () {
    test('returns null with no planned workouts', () {
      final result = calculator.calculate(
        plannedDates: {},
        logs: [completedLog(now)],
        from: now.subtract(const Duration(days: 28)),
        to: now,
      );
      expect(result, isNull);
    });

    test('computes completion rate and score', () {
      final planned = {
        now.subtract(const Duration(days: 6)),
        now.subtract(const Duration(days: 4)),
        now.subtract(const Duration(days: 2)),
        now,
      };

      final result = calculator.calculate(
        plannedDates: planned,
        logs: [
          completedLog(now.subtract(const Duration(days: 6))),
          completedLog(now.subtract(const Duration(days: 2))),
        ],
        from: now.subtract(const Duration(days: 28)),
        to: now,
      );

      expect(result, isNotNull);
      expect(result!.plannedWorkouts, 4);
      expect(result.completedWorkouts, 2);
      expect(result.consistencyScore, 50);
      expect(result.trend, isA<TrendDirection>());
    });
  });
}
