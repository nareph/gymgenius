import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_context.dart';
import 'package:gymgenius/engines/ai_coach/providers/local_coach_provider.dart';

CoachContext _ctx({
  bool volumeReduced = false,
  bool restDay = false,
  int? readiness,
}) {
  return CoachContext(
    userId: 'u1',
    now: DateTime(2026, 8, 11),
    isRestDay: restDay,
    isAdapted: volumeReduced,
    workoutAdjustment: volumeReduced
        ? WorkoutAdjustment.reduceVolume.value
        : WorkoutAdjustment.none.value,
    decisionReasons: const ['low_recovery'],
    plannedExerciseCount: restDay ? 0 : 2,
    readinessScore: readiness,
    volumeMultiplier: volumeReduced ? 0.7 : 1.0,
    decisionConfidence: 0.8,
  );
}

void main() {
  const local = LocalCoachProvider();

  test('daily reduced volume forbids pushing harder', () {
    final response = local.buildDaily(_ctx(volumeReduced: true, readiness: 40));
    expect(response.message.toLowerCase(), contains('reduced'));
    expect(response.usedFallback, isTrue);
    expect(
      response.recommendations.any(
        (r) => (r.actionTag ?? '').contains('increase'),
      ),
      isFalse,
    );
    expect(response.recommendations.first.actionTag, 'follow_reduced_volume');
  });

  test('daily rest day message', () {
    final response = local.buildDaily(_ctx(restDay: true, readiness: 55));
    expect(response.message.toLowerCase(), contains('rest'));
  });

  test('weekly uses report numbers only', () {
    final response = local.buildWeekly(
      context: _ctx(),
      weeklyReport: {
        'workoutsCompleted': 3,
        'workoutsPlanned': 4,
        'consistencyScore': 75,
        'weightChangeKg': -0.4,
        'positives': ['Logged all check-ins'],
        'improvements': ['Hit planned sessions'],
      },
    );
    expect(response.message, contains('3/4'));
    expect(response.message, contains('75%'));
    expect(response.message, contains('-0.4'));
  });

  test('chat explains why from decision reasons', () {
    final response = local.buildChat(
      context: _ctx(volumeReduced: true),
      question: 'Why was my workout changed?',
    );
    expect(response.message.toLowerCase(), contains('low_recovery'));
  });
}
