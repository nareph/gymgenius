import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/workout_engine/shared/profile_coherence.dart';

import '../models/decision_context.dart';
import 'decision_rule.dart';

/// Session-level safety check using [HealthProfile.avoidedMuscles].
///
/// [InjuryRule] substitutes individual contraindicated exercises.
/// This rule fires when the *entire* session targets avoided muscles —
/// substitution would not produce a usable workout, so we switch to a
/// recovery session instead.
class SafetyRule implements DecisionRule {
  const SafetyRule();

  @override
  WorkoutDecision evaluate(
    DecisionContext context,
  ) {
    final avoided = context.healthProfile.avoidedMuscles;
    final exercises = context.todayWorkout.finalExercises;

    if (avoided.isEmpty || exercises.isEmpty) {
      return WorkoutDecision.keepPlannedWorkout();
    }

    final unsafeCount = exercises
        .where(
          (exercise) => ProfileCoherence.exerciseTargetsAvoided(
            primaryMuscles: exercise.primaryMuscles,
            avoidedMuscles: avoided,
          ),
        )
        .length;

    if (unsafeCount < exercises.length) {
      return WorkoutDecision.keepPlannedWorkout();
    }

    return const WorkoutDecision(
      requiresAdaptation: true,
      adjustment: WorkoutAdjustment.recoverySession,
      reasons: [
        DecisionReason.medicalRestriction,
        DecisionReason.recoveryRequired,
      ],
      confidence: 0.9,
    );
  }
}
