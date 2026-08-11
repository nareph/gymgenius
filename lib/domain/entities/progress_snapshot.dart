import 'package:gymgenius/domain/enums/progress_period.dart';

import 'strength_progress.dart';
import 'weight_trend.dart';
import 'workout_consistency.dart';

/// Deterministic progress analysis for a user at a point in time.
///
/// Produced by [ProgressEngine] and consumed by [ProgressRule] / UI.
class ProgressSnapshot {
  final String userId;
  final DateTime computedAt;
  final ProgressPeriod period;

  final WeightTrend? weightTrend;
  final StrengthProgress? strengthProgress;
  final WorkoutConsistency? consistency;

  final bool weightPlateauDetected;
  final bool strengthPlateauDetected;

  final List<String> reasons;
  final String generatedBy;

  const ProgressSnapshot({
    required this.userId,
    required this.computedAt,
    required this.period,
    this.weightTrend,
    this.strengthProgress,
    this.consistency,
    this.weightPlateauDetected = false,
    this.strengthPlateauDetected = false,
    this.reasons = const [],
    this.generatedBy = 'progress_engine_v1',
  });

  bool get hasSufficientData =>
      (weightTrend?.hasSufficientData ?? false) ||
      (strengthProgress?.hasSufficientData ?? false) ||
      (consistency?.hasSufficientData ?? false);

  bool get anyPlateauDetected =>
      weightPlateauDetected || strengthPlateauDetected;

  int get overallConsistencyScore => consistency?.consistencyScore ?? 0;

  @override
  String toString() =>
      'ProgressSnapshot($period, sufficient: $hasSufficientData, plateaus: $anyPlateauDetected)';
}
