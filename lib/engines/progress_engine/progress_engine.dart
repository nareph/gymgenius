import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/entities/strength_progress.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/entities/weekly_progress_report.dart';
import 'package:gymgenius/domain/entities/weight_trend.dart';
import 'package:gymgenius/domain/entities/workout_consistency.dart';
import 'package:gymgenius/domain/entities/workout_log.dart';
import 'package:gymgenius/domain/enums/progress_period.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';
import 'package:gymgenius/engines/progress_engine/calculators/consistency_calculator.dart';
import 'package:gymgenius/engines/progress_engine/calculators/strength_progress_calculator.dart';
import 'package:gymgenius/engines/progress_engine/calculators/weight_progress_calculator.dart';
import 'package:gymgenius/engines/progress_engine/detectors/plateau_detector.dart';

/// Public façade for the Progress Engine (Phase 5).
///
/// Pure, deterministic calculations — no IO.
class ProgressEngine {
  final WeightProgressCalculator _weightCalculator;
  final StrengthProgressCalculator _strengthCalculator;
  final ConsistencyCalculator _consistencyCalculator;
  final PlateauDetector _plateauDetector;

  const ProgressEngine({
    WeightProgressCalculator weightCalculator =
        const WeightProgressCalculator(),
    StrengthProgressCalculator strengthCalculator =
        const StrengthProgressCalculator(),
    ConsistencyCalculator consistencyCalculator = const ConsistencyCalculator(),
    PlateauDetector plateauDetector = const PlateauDetector(),
  })  : _weightCalculator = weightCalculator,
        _strengthCalculator = strengthCalculator,
        _consistencyCalculator = consistencyCalculator,
        _plateauDetector = plateauDetector;

  /// Builds a [ProgressSnapshot] from raw historical inputs.
  ProgressSnapshot computeSnapshot({
    required String userId,
    required DateTime now,
    ProgressPeriod period = ProgressPeriod.weekly,
    required List<DailyCheckIn> checkIns,
    required List<WorkoutLog> workoutLogs,
    required Set<DateTime> plannedWorkoutDates,
    double? targetWeightKg,
  }) {
    final from = now.subtract(period.lookback);
    final to = now;

    final weightTrend = _weightCalculator.calculate(
      checkIns: checkIns,
      from: from,
      to: to,
      targetWeightKg: targetWeightKg,
    );

    final strengthProgress = _strengthCalculator.calculate(
      logs: workoutLogs,
      from: from,
      to: to,
    );

    final consistency = _consistencyCalculator.calculate(
      plannedDates: plannedWorkoutDates,
      logs: workoutLogs,
      from: from,
      to: to,
    );

    final weightPlateau = _plateauDetector.detectWeightPlateau(
      checkIns: checkIns,
      trend: weightTrend,
      to: to,
    );

    final strengthPlateau =
        _plateauDetector.detectStrengthPlateau(strengthProgress);

    final reasons = _buildReasons(
      weightTrend: weightTrend,
      strengthProgress: strengthProgress,
      consistency: consistency,
      weightPlateau: weightPlateau,
      strengthPlateau: strengthPlateau,
    );

    return ProgressSnapshot(
      userId: userId,
      computedAt: now,
      period: period,
      weightTrend: weightTrend,
      strengthProgress: strengthProgress,
      consistency: consistency,
      weightPlateauDetected: weightPlateau,
      strengthPlateauDetected: strengthPlateau,
      reasons: reasons,
    );
  }

  /// Builds a weekly report for the calendar week containing [weekStart].
  WeeklyProgressReport buildWeeklyReport({
    required String userId,
    required DateTime weekStart,
    required List<DailyCheckIn> checkIns,
    required List<WorkoutLog> workoutLogs,
    required Set<DateTime> plannedWorkoutDates,
    List<RecoveryStatus> recoveryStatuses = const [],
  }) {
    final start = _dayKey(weekStart);
    final end = start.add(const Duration(days: 6));

    final weekCheckIns = checkIns.where((c) {
      final day = _dayKey(c.date);
      return !day.isBefore(start) && !day.isAfter(end);
    }).toList();

    final weightPoints = weekCheckIns.where((c) => c.isWeightLogged).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final weightStart =
        weightPoints.isNotEmpty ? weightPoints.first.weightKg : null;
    final weightEnd =
        weightPoints.isNotEmpty ? weightPoints.last.weightKg : null;
    final weightChange = weightStart != null && weightEnd != null
        ? weightEnd - weightStart
        : null;

    final weekLogs = workoutLogs.where((l) {
      final day = _dayKey(l.savedAt);
      return !day.isBefore(start) && !day.isAfter(end);
    }).toList();

    final plannedInWeek = plannedWorkoutDates.where((d) {
      final day = _dayKey(d);
      return !day.isBefore(start) && !day.isAfter(end);
    }).length;

    final completedInWeek = weekLogs
        .where((l) => l.completionScore > 0)
        .map((l) => _dayKey(l.savedAt))
        .toSet()
        .length;

    final consistencyScore = plannedInWeek > 0
        ? ((completedInWeek / plannedInWeek) * 100).round().clamp(0, 100)
        : 0;

    final strength = _strengthCalculator.calculate(
      logs: workoutLogs,
      from: start,
      to: end,
    );

    final weekRecovery = recoveryStatuses.where((r) {
      final day = _dayKey(r.date);
      return !day.isBefore(start) && !day.isAfter(end);
    }).toList();

    final avgReadiness = weekRecovery.isNotEmpty
        ? (weekRecovery.map((r) => r.readinessScore).reduce((a, b) => a + b) /
                weekRecovery.length)
            .round()
        : null;

    final positives = <String>[];
    final improvements = <String>[];

    if (consistencyScore >= 80) {
      positives.add('Strong workout consistency ($consistencyScore%)');
    } else if (consistencyScore < 60 && plannedInWeek > 0) {
      improvements.add('Workout consistency below target ($consistencyScore%)');
    }

    if (weightChange != null) {
      if (weightChange.abs() <= 0.2) {
        positives.add('Weight stable this week');
      } else if (weightChange < 0) {
        positives
            .add('Weight down ${weightChange.abs().toStringAsFixed(1)} kg');
      } else {
        improvements.add(
            'Weight up ${weightChange.toStringAsFixed(1)} kg — review nutrition');
      }
    }

    if (strength?.overallTrend == TrendDirection.gaining) {
      positives.add('Strength trending up');
    } else if (strength?.plateauDetected ?? false) {
      improvements.add('Strength plateau detected on key lifts');
    }

    if (avgReadiness != null && avgReadiness >= 70) {
      positives.add('Average readiness $avgReadiness');
    } else if (avgReadiness != null && avgReadiness < 50) {
      improvements.add('Low average readiness ($avgReadiness)');
    }

    return WeeklyProgressReport(
      userId: userId,
      weekStart: start,
      weekEnd: end,
      weightStartKg: weightStart,
      weightEndKg: weightEnd,
      weightChangeKg: weightChange,
      workoutsCompleted: completedInWeek,
      workoutsPlanned: plannedInWeek,
      consistencyScore: consistencyScore,
      strengthChangePercent: strength?.strengthChangePercent,
      averageReadiness: avgReadiness,
      positives: positives,
      improvements: improvements,
    );
  }

  /// Extracts planned workout calendar days from an active [TrainingProgram].
  static Set<DateTime> plannedDatesFromProgram(TrainingProgram program) {
    final dates = <DateTime>{};
    if (program.durationWeeks <= 0 || program.weeklySchedule.isEmpty) {
      return dates;
    }

    final startDate = program.createdAt;
    final endDate = program.expiresAt;
    var current = _dayKey(startDate);

    const daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    while (!current.isAfter(endDate)) {
      final dayKey = daysOfWeek[current.weekday - 1];
      final exercises = program.weeklySchedule[dayKey];
      if (exercises != null && exercises.isNotEmpty) {
        dates.add(current);
      }
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  List<String> _buildReasons({
    required WeightTrend? weightTrend,
    required StrengthProgress? strengthProgress,
    required WorkoutConsistency? consistency,
    required bool weightPlateau,
    required bool strengthPlateau,
  }) {
    final reasons = <String>[];

    if (weightTrend?.hasSufficientData ?? false) {
      reasons.add('Weight ${weightTrend!.direction.displayName.toLowerCase()} '
          '(${weightTrend.changeKg?.toStringAsFixed(1) ?? "?"} kg over period)');
    }

    if (strengthProgress?.hasSufficientData ?? false) {
      reasons.add(
          'Strength ${strengthProgress!.overallTrend.displayName.toLowerCase()} '
          '(${strengthProgress.strengthChangePercent.toStringAsFixed(1)}%)');
    }

    if (consistency?.hasSufficientData ?? false) {
      reasons.add('Consistency ${consistency!.consistencyScore}% '
          '(${consistency.completedWorkouts}/${consistency.plannedWorkouts})');
    }

    if (weightPlateau) {
      reasons.add('Weight plateau detected');
    }
    if (strengthPlateau) {
      reasons.add('Strength plateau detected');
    }

    if (reasons.isEmpty) {
      reasons
          .add('Insufficient progress data — keep logging workouts and weight');
    }

    return reasons;
  }

  static DateTime _dayKey(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
