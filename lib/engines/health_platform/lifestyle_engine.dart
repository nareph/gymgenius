import 'package:gymgenius/domain/entities/lifestyle_status.dart';
import 'package:gymgenius/domain/enums/health_caution_level.dart';
import 'package:gymgenius/engines/health_platform/habit_engine.dart';
import 'package:gymgenius/engines/health_platform/hydration_engine.dart';
import 'package:gymgenius/engines/health_platform/mental_wellness_engine.dart';

/// Aggregates lifestyle signals without diagnosing medical conditions.
class LifestyleEngine {
  const LifestyleEngine();

  LifestyleStatus build({
    required String userId,
    required DateTime now,
    double? sleepHours,
    HydrationDayStatus? hydration,
    HabitStats? habits,
    MentalWellnessStatus? wellness,
  }) {
    final reasons = <String>[];
    final recs = <String>[];
    var caution = HealthCautionLevel.none;

    if (sleepHours != null) {
      reasons.add('Sleep signal: ${sleepHours}h (from recovery check-in)');
      if (sleepHours < 6) {
        recs.add('Prioritize an earlier bedtime tonight');
        caution = HealthCautionLevel.info;
      }
    }

    if (hydration != null) {
      reasons.addAll(hydration.reasons);
      if (hydration.percent < 60) {
        recs.add('Sip water steadily toward today\'s hydration target');
      }
    }

    if (habits != null) {
      reasons.addAll(habits.reasons);
      if (habits.completionPercent < 50 && habits.activeCount > 0) {
        recs.add('Pick one habit to complete today');
      }
    }

    if (wellness != null) {
      reasons.addAll(wellness.reasons);
      recs.addAll(wellness.recommendations.take(2));
    }

    if (recs.isEmpty) {
      recs.add('Keep logging lifestyle signals for better personalization');
    }

    return LifestyleStatus(
      userId: userId,
      computedAt: now,
      sleepHoursSignal: sleepHours?.round(),
      hydrationPercent: hydration?.percent,
      habitsCompletionPercent: habits?.completionPercent,
      wellnessMood: wellness?.today?.mood,
      recommendations: recs,
      reasons: reasons,
      cautionLevel: caution,
    );
  }
}
