import 'package:gymgenius/domain/entities/nutrition_plan.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';

import '../../models/decision_context.dart';
import '../decision_rule.dart';
import 'nutrition_plan_builder.dart';

/// Decision Engine rule for the nutrition domain.
///
/// Phase 3 responsibilities:
///
/// • [evaluate] — workout-side signals only (no nutrition-driven workout
///   overrides until Recovery / Progress engines are integrated)
/// • [buildNutritionPlan] — produce today's nutrition plan after workout
///   adaptations are applied
class NutritionRule implements DecisionRule {
  final NutritionPlanBuilder _planBuilder;

  const NutritionRule({
    required NutritionPlanBuilder planBuilder,
  }) : _planBuilder = planBuilder;

  /// Workout adaptation proposal from the nutrition domain.
  ///
  /// Nutrition never overrides safety, recovery, or injury rules.
  /// Full cross-domain nutrition → workout logic arrives with Recovery
  /// Engine integration (Phase 4).
  @override
  WorkoutDecision evaluate(DecisionContext context) {
    // Rest days: nutrition handles lower energy needs via [buildNutritionPlan].
    if (context.todayWorkout.isRestDay) {
      return WorkoutDecision.keepPlannedWorkout(confidence: 1.0);
    }

    // Fat-loss goal on a scheduled training day: keep workout, nutrition
    // applies the deficit through calorie targets (not volume cuts here).
    if (context.healthProfile.goal == FitnessGoal.loseFat) {
      return WorkoutDecision.keepPlannedWorkout(confidence: 0.95);
    }

    return WorkoutDecision.keepPlannedWorkout();
  }

  /// Builds the deterministic nutrition plan for today.
  NutritionPlan buildNutritionPlan({
    required DecisionContext context,
    required TodayWorkout finalWorkout,
  }) {
    return _planBuilder.build(
      context: context,
      finalWorkout: finalWorkout,
    );
  }

  Future<NutritionPlan> buildAndPersistNutritionPlan({
    required DecisionContext context,
    required TodayWorkout finalWorkout,
  }) {
    return _planBuilder.buildAndPersist(
      context: context,
      finalWorkout: finalWorkout,
    );
  }
}
