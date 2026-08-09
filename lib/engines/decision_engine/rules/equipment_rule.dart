import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';

import '../models/decision_context.dart';
import 'decision_rule.dart';

/// Handles workout adaptations caused by equipment availability.
///
/// This rule never replaces exercises itself.
/// It only decides whether today's workout should be adapted.
///
/// The actual substitutions are delegated to
/// ExerciseSubstitutionService.
class EquipmentRule implements DecisionRule {
  const EquipmentRule();

  @override
  WorkoutDecision evaluate(
    DecisionContext context,
  ) {
    final allowedEquipment = context.healthProfile.training.equipment;
    final workout = context.todayWorkout;

    final incompatibleExerciseFound = workout.finalExercises.any(
      (exercise) => !allowedEquipment.contains(exercise.equipment),
    );

    if (!incompatibleExerciseFound) {
      return WorkoutDecision.keepPlannedWorkout();
    }

    return const WorkoutDecision(
      requiresAdaptation: true,
      adjustment: WorkoutAdjustment.replaceExercise,
      reasons: [
        DecisionReason.equipmentChanged,
      ],
      confidence: 0.95,
    );
  }
}
