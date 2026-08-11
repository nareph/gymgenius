import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/progress_period.dart';
import 'package:gymgenius/domain/enums/recommended_intensity.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/decision_engine/builders/health_decision_builder.dart';

void main() {
  const builder = HealthDecisionBuilder();
  final now = DateTime(2026, 8, 11);

  group('HealthDecisionBuilder', () {
    test('recommends reduced volume when readiness is low', () {
      final decision = builder.build(
        generatedAt: now,
        finalDecision: WorkoutDecision(
          requiresAdaptation: true,
          adjustment: WorkoutAdjustment.reduceVolume,
          reasons: const [],
          confidence: 0.55,
          volumeMultiplier: 0.55,
        ),
        recoveryStatus: RecoveryStatus(
          userId: 'u1',
          date: now,
          recoveryScore: 40,
          fatigueScore: 70,
          readinessScore: 35,
          recommendedIntensity: RecommendedIntensity.light,
          volumeMultiplier: 0.55,
          reasons: const ['low'],
        ),
      );

      expect(decision.primaryAction, 'train_with_reduced_volume');
      expect(decision.confidence, inInclusiveRange(0.0, 1.0));
    });

    test('recommends scheduled workout when readiness is high', () {
      final decision = builder.build(
        generatedAt: now,
        finalDecision: WorkoutDecision.keepPlannedWorkout(),
        recoveryStatus: RecoveryStatus(
          userId: 'u1',
          date: now,
          recoveryScore: 85,
          fatigueScore: 10,
          readinessScore: 90,
          recommendedIntensity: RecommendedIntensity.max,
          volumeMultiplier: 1.0,
          reasons: const ['good'],
        ),
      );

      expect(decision.primaryAction, 'complete_scheduled_workout');
      expect(decision.displayAction, 'Complete scheduled workout');
    });

    test('flags plateau without mutating workout action when no adaptation',
        () {
      final decision = builder.build(
        generatedAt: now,
        finalDecision: WorkoutDecision.keepPlannedWorkout(),
        progressSnapshot: ProgressSnapshot(
          userId: 'u1',
          computedAt: now,
          period: ProgressPeriod.weekly,
          weightPlateauDetected: true,
        ),
      );

      expect(decision.primaryAction, 'monitor_plateau');
    });

    test('fallback without check-in', () {
      final decision = builder.build(
        generatedAt: now,
        finalDecision: WorkoutDecision.keepPlannedWorkout(confidence: 0.5),
      );

      expect(decision.primaryAction, 'complete_scheduled_workout');
      expect(decision.reason, contains('No check-in'));
    });
  });
}
