import 'package:gymgenius/domain/enums/health_caution_level.dart';

/// Deterministic lifestyle aggregate (not medical advice).
class LifestyleStatus {
  final String userId;
  final DateTime computedAt;
  final int? sleepHoursSignal;
  final int? hydrationPercent;
  final int? habitsCompletionPercent;
  final int? wellnessMood;
  final List<String> recommendations;
  final List<String> reasons;
  final HealthCautionLevel cautionLevel;
  final String generatedBy;

  const LifestyleStatus({
    required this.userId,
    required this.computedAt,
    this.sleepHoursSignal,
    this.hydrationPercent,
    this.habitsCompletionPercent,
    this.wellnessMood,
    this.recommendations = const [],
    this.reasons = const [],
    this.cautionLevel = HealthCautionLevel.none,
    this.generatedBy = 'lifestyle_engine_v1',
  });

  @override
  String toString() =>
      'LifestyleStatus(hydration: $hydrationPercent%, habits: $habitsCompletionPercent%)';
}
