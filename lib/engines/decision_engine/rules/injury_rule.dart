import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/workout_engine/shared/profile_coherence.dart';

import '../models/decision_context.dart';
import 'decision_rule.dart';

/// Injury / medical restrictions stored on [HealthProfile.avoidedMuscles].
///
/// If today's planned session still contains exercises whose primary
/// muscles are restricted, Decision Engine substitutes them (same
/// adjustment path as equipment changes). Generation already filters
/// these muscles; this rule covers legacy programs and mid-cycle
/// profile edits.
class InjuryRule implements DecisionRule {
  const InjuryRule();

  @override
  WorkoutDecision evaluate(
    DecisionContext context,
  ) {
    final avoided = context.healthProfile.avoidedMuscles;
    if (avoided.isEmpty) {
      return WorkoutDecision.keepPlannedWorkout();
    }

    final hits = context.todayWorkout.finalExercises.where(
      (exercise) => ProfileCoherence.exerciseTargetsAvoided(
        primaryMuscles: exercise.primaryMuscles,
        avoidedMuscles: avoided,
      ),
    );

    if (hits.isEmpty) {
      return WorkoutDecision.keepPlannedWorkout();
    }

    return const WorkoutDecision(
      requiresAdaptation: true,
      adjustment: WorkoutAdjustment.replaceExercise,
      reasons: [
        DecisionReason.medicalRestriction,
        DecisionReason.exerciseSubstitution,
      ],
      confidence: 0.95,
    );
  }
}
