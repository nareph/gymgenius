import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/decision_engine/decision_priorities.dart';
import 'package:gymgenius/engines/decision_engine/services/conflict_resolver.dart';

void main() {
  const resolver = ConflictResolver();

  group('DecisionPriorities', () {
    test('domain evaluation order matches Phase 6 policy', () {
      expect(
        DecisionPriorities.domainEvaluationOrder,
        [
          'InjuryRule',
          'SafetyRule',
          'RecoveryRule',
          'DeloadRule',
          'ProgressionRule',
          'EquipmentRule',
          'ProgressRule',
          'NutritionRule',
        ],
      );
    });

    test('reduceVolume outranks increaseIntensity', () {
      expect(
        DecisionPriorities.adjustmentRanks['reduceVolume']!,
        greaterThan(DecisionPriorities.adjustmentRanks['increaseIntensity']!),
      );
    });
  });

  group('ConflictResolver', () {
    test('Recovery reduceVolume wins over Progression increaseIntensity', () {
      final recovery = WorkoutDecision(
        requiresAdaptation: true,
        adjustment: WorkoutAdjustment.reduceVolume,
        reasons: const [DecisionReason.lowRecovery],
        confidence: 0.6,
        volumeMultiplier: 0.7,
      );
      final progression = WorkoutDecision(
        requiresAdaptation: true,
        adjustment: WorkoutAdjustment.increaseIntensity,
        reasons: const [DecisionReason.progressionWeek],
        confidence: 0.9,
      );

      final winner = resolver.resolve([progression, recovery]);

      expect(winner.adjustment, WorkoutAdjustment.reduceVolume);
      expect(winner.volumeMultiplier, 0.7);
      expect(winner.reasons, contains(DecisionReason.lowRecovery));
      expect(winner.reasons, contains(DecisionReason.progressionWeek));
      expect(winner.confidence, 0.9); // max of inputs
    });

    test('restDay wins over all other adaptations', () {
      final winner = resolver.resolve([
        WorkoutDecision.reduceVolume(confidence: 0.8),
        WorkoutDecision(
          requiresAdaptation: true,
          adjustment: WorkoutAdjustment.restDay,
          reasons: const [DecisionReason.medicalRestriction],
          confidence: 0.5,
        ),
      ]);

      expect(winner.adjustment, WorkoutAdjustment.restDay);
    });

    test('clamps confidence to 0–1', () {
      final winner = resolver.resolve([
        WorkoutDecision(
          requiresAdaptation: false,
          adjustment: WorkoutAdjustment.none,
          reasons: const [DecisionReason.scheduledWorkout],
          confidence: 1.5,
        ),
      ]);
      expect(winner.confidence, 1.0);
    });
  });
}
