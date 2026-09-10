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
    test('returns null when targetPerWeek is too low', () {
      final result = calculator.calculate(
        targetPerWeek: 0, // Pas de cible → retourne null
        logs: [completedLog(now)],
        from: now.subtract(const Duration(days: 28)),
        to: now,
      );
      expect(result, isNull);
    });

    test('computes completion rate and score against declared frequency', () {
      // L'utilisateur s'entraîne 4 jours/semaine
      const targetPerWeek = 4;
      // Période de 28 jours = 4 semaines → cible totale = 16
      final from = now.subtract(const Duration(days: 28));
      final to = now;

      // Logs répartis sur 4 jours (2 la première semaine, 2 la dernière)
      final logs = [
        completedLog(now.subtract(const Duration(days: 25))), // semaine 1
        completedLog(now.subtract(const Duration(days: 23))), // semaine 1
        completedLog(now.subtract(const Duration(days: 3))), // semaine 4
        completedLog(now.subtract(const Duration(days: 1))), // semaine 4
      ];

      final result = calculator.calculate(
        targetPerWeek: targetPerWeek,
        logs: logs,
        from: from,
        to: to,
      );

      expect(result, isNotNull);

      // 4 semaines × 4 jours/semaine = 16 jours prévus
      expect(result!.plannedWorkouts, 16);

      // 4 jours complétés
      expect(result.completedWorkouts, 4);

      // 4/16 = 25% → score 25
      expect(result.consistencyScore, 25);

      // Fréquence hebdomadaire réelle : 4/4 = 1.0
      expect(result.weeklyFrequency, closeTo(1.0, 0.1));

      // Le trend compare la première moitié (2 jours) vs la seconde (2 jours)
      // → stable
      expect(result.trend, TrendDirection.stable);
    });

    test('handles single completed day correctly', () {
      const targetPerWeek = 4;
      final from = now.subtract(const Duration(days: 7)); // 1 semaine
      final to = now;

      final logs = [
        completedLog(now.subtract(const Duration(days: 3))),
      ];

      final result = calculator.calculate(
        targetPerWeek: targetPerWeek,
        logs: logs,
        from: from,
        to: to,
      );

      expect(result, isNotNull);
      expect(result!.plannedWorkouts, 4);
      expect(result.completedWorkouts, 1);
      expect(result.consistencyScore, 25);
      expect(result.weeklyFrequency, 1.0);
    });

    test('detects improving trend', () {
      const targetPerWeek = 4;
      final from = now.subtract(const Duration(days: 28));
      final to = now;

      // 0 workout la première moitié, 3 la seconde → amélioration
      final logs = [
        completedLog(now.subtract(const Duration(days: 3))),
        completedLog(now.subtract(const Duration(days: 2))),
        completedLog(now.subtract(const Duration(days: 1))),
      ];

      final result = calculator.calculate(
        targetPerWeek: targetPerWeek,
        logs: logs,
        from: from,
        to: to,
      );

      expect(result, isNotNull);
      // Le taux de complétion seconde moitié > première moitié → gaining
      expect(result!.trend, TrendDirection.gaining);
    });

    test('detects stable trend', () {
      const targetPerWeek = 4;
      final from = now.subtract(const Duration(days: 14)); // 2 semaines
      final to = now;

      // 1 workout par moitié → stable
      final logs = [
        completedLog(now.subtract(const Duration(days: 10))),
        completedLog(now.subtract(const Duration(days: 2))),
      ];

      final result = calculator.calculate(
        targetPerWeek: targetPerWeek,
        logs: logs,
        from: from,
        to: to,
      );

      expect(result, isNotNull);
      expect(result!.trend, TrendDirection.stable);
    });

    test('handles zero completed workouts', () {
      const targetPerWeek = 4;
      final from = now.subtract(const Duration(days: 7));
      final to = now;

      final result = calculator.calculate(
        targetPerWeek: targetPerWeek,
        logs: const [],
        from: from,
        to: to,
      );

      expect(result, isNotNull);
      expect(result!.plannedWorkouts, 4);
      expect(result.completedWorkouts, 0);
      expect(result.consistencyScore, 0);
      expect(result.weeklyFrequency, 0.0);
      expect(result.trend, TrendDirection.losing);
    });

    test('daily completion counts only once even with multiple logs', () {
      const targetPerWeek = 4;
      final from = now.subtract(const Duration(days: 7));
      final to = now;

      // Deux logs le même jour
      final logs = [
        completedLog(now.subtract(const Duration(days: 3))),
        completedLog(now.subtract(const Duration(days: 3))), // même jour
        completedLog(now.subtract(const Duration(days: 2))),
      ];

      final result = calculator.calculate(
        targetPerWeek: targetPerWeek,
        logs: logs,
        from: from,
        to: to,
      );

      expect(result, isNotNull);
      // 2 jours distincts sur 4 prévus → 50%
      expect(result!.completedWorkouts, 2);
      expect(result.consistencyScore, 50);
      expect(result.weeklyFrequency, 2.0);
    });

    test('respects minPlannedWorkouts threshold', () {
      const targetPerWeek = 1;
      final from = now.subtract(const Duration(days: 1)); // Moins de 1 jour
      final to = now;

      final result = calculator.calculate(
        targetPerWeek: targetPerWeek,
        logs: [completedLog(now)],
        from: from,
        to: to,
      );

      // plannedWorkouts = (1 * 1/7) ≈ 0 → < 1 → null
      expect(result, isNull);
    });
  });
}
