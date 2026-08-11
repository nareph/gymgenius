/// Structured weekly progress summary (deterministic, no natural language).
class WeeklyProgressReport {
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;

  final double? weightStartKg;
  final double? weightEndKg;
  final double? weightChangeKg;

  final int workoutsCompleted;
  final int workoutsPlanned;
  final int consistencyScore;

  final double? strengthChangePercent;
  final int? averageReadiness;

  final List<String> positives;
  final List<String> improvements;

  const WeeklyProgressReport({
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    this.weightStartKg,
    this.weightEndKg,
    this.weightChangeKg,
    required this.workoutsCompleted,
    required this.workoutsPlanned,
    required this.consistencyScore,
    this.strengthChangePercent,
    this.averageReadiness,
    this.positives = const [],
    this.improvements = const [],
  });

  bool get hasData =>
      weightStartKg != null ||
      workoutsCompleted > 0 ||
      (strengthChangePercent != null);
}
