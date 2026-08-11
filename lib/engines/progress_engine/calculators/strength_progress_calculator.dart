import 'package:gymgenius/domain/entities/exercise_strength_metric.dart';
import 'package:gymgenius/domain/entities/strength_progress.dart';
import 'package:gymgenius/domain/entities/workout_log.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';
import 'package:gymgenius/engines/progress_engine/progress_thresholds.dart';

/// Computes strength progression from workout logs.
class StrengthProgressCalculator {
  const StrengthProgressCalculator();

  StrengthProgress? calculate({
    required List<WorkoutLog> logs,
    required DateTime from,
    required DateTime to,
  }) {
    final completed = logs.where((l) => l.completionScore > 0).where((l) {
      final day = _dayKey(l.savedAt);
      return !day.isBefore(_dayKey(from)) && !day.isAfter(_dayKey(to));
    }).toList()
      ..sort((a, b) => a.savedAt.compareTo(b.savedAt));

    if (completed.isEmpty) return null;

    final byExercise = <String, List<_SessionBest>>{};

    for (final log in completed) {
      for (final exercise in log.exercises) {
        if (exercise.sets.isEmpty) continue;

        final bestSet = exercise.sets.reduce((a, b) {
          final aRm = ProgressThresholds.estimated1Rm(a.weightKg, a.reps);
          final bRm = ProgressThresholds.estimated1Rm(b.weightKg, b.reps);
          return aRm >= bRm ? a : b;
        });

        final e1Rm =
            ProgressThresholds.estimated1Rm(bestSet.weightKg, bestSet.reps);
        if (e1Rm <= 0) continue;

        byExercise.putIfAbsent(exercise.exerciseId, () => []).add(
              _SessionBest(
                exerciseName: exercise.name,
                weightKg: bestSet.weightKg,
                reps: bestSet.reps,
                estimated1Rm: e1Rm,
                date: log.savedAt,
              ),
            );
      }
    }

    final metrics = <ExerciseStrengthMetric>[];

    for (final entry in byExercise.entries) {
      final sessions = entry.value..sort((a, b) => a.date.compareTo(b.date));

      if (sessions.length < ProgressThresholds.minStrengthSessions) continue;

      final latest = sessions.last;
      final trend = _exerciseTrend(sessions);
      final plateau = _isPlateau(sessions);

      metrics.add(
        ExerciseStrengthMetric(
          exerciseId: entry.key,
          exerciseName: latest.exerciseName,
          bestWeightKg: latest.weightKg,
          bestReps: latest.reps,
          estimated1Rm: latest.estimated1Rm,
          trend: trend,
          plateauDetected: plateau,
        ),
      );
    }

    if (metrics.isEmpty) return null;

    metrics.sort((a, b) => b.estimated1Rm.compareTo(a.estimated1Rm));
    final top = metrics.take(ProgressThresholds.maxTrackedExercises).toList();

    final overallTrend = _overallTrend(top);
    final changePercent = _overallChangePercent(byExercise);
    final anyPlateau = top.any((m) => m.plateauDetected);

    return StrengthProgress(
      trackedExerciseCount: top.length,
      topExercises: top,
      overallTrend: overallTrend,
      strengthChangePercent: changePercent,
      plateauDetected: anyPlateau,
    );
  }

  TrendDirection _exerciseTrend(List<_SessionBest> sessions) {
    if (sessions.length < ProgressThresholds.minStrengthSessions) {
      return TrendDirection.insufficientData;
    }

    final first = sessions.first.estimated1Rm;
    final last = sessions.last.estimated1Rm;
    final changePercent = first > 0 ? ((last - first) / first) * 100 : 0;

    if (changePercent.abs() <
        ProgressThresholds.strengthProgressThresholdPercent) {
      return TrendDirection.stable;
    }
    return changePercent > 0 ? TrendDirection.gaining : TrendDirection.losing;
  }

  bool _isPlateau(List<_SessionBest> sessions) {
    if (sessions.length < ProgressThresholds.strengthPlateauSessions) {
      return false;
    }

    final recent = sessions
        .sublist(sessions.length - ProgressThresholds.strengthPlateauSessions);
    final firstRm = recent.first.estimated1Rm;

    return recent.every((s) {
      final delta = ((s.estimated1Rm - firstRm) / firstRm) * 100;
      return delta.abs() < ProgressThresholds.strengthProgressThresholdPercent;
    });
  }

  TrendDirection _overallTrend(List<ExerciseStrengthMetric> metrics) {
    if (metrics.isEmpty) return TrendDirection.insufficientData;

    final gaining =
        metrics.where((m) => m.trend == TrendDirection.gaining).length;
    final losing =
        metrics.where((m) => m.trend == TrendDirection.losing).length;

    if (gaining > losing && gaining > metrics.length / 2) {
      return TrendDirection.gaining;
    }
    if (losing > gaining && losing > metrics.length / 2) {
      return TrendDirection.losing;
    }
    if (metrics.every((m) => m.trend == TrendDirection.stable)) {
      return TrendDirection.stable;
    }
    return TrendDirection.fluctuating;
  }

  double _overallChangePercent(Map<String, List<_SessionBest>> byExercise) {
    final changes = <double>[];

    for (final sessions in byExercise.values) {
      if (sessions.length < ProgressThresholds.minStrengthSessions) continue;
      sessions.sort((a, b) => a.date.compareTo(b.date));
      final first = sessions.first.estimated1Rm;
      final last = sessions.last.estimated1Rm;
      if (first > 0) {
        changes.add(((last - first) / first) * 100);
      }
    }

    if (changes.isEmpty) return 0;
    return changes.reduce((a, b) => a + b) / changes.length;
  }

  DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);
}

class _SessionBest {
  final String exerciseName;
  final double weightKg;
  final int reps;
  final double estimated1Rm;
  final DateTime date;

  const _SessionBest({
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
    required this.estimated1Rm,
    required this.date,
  });
}
