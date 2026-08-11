import 'package:gymgenius/domain/entities/nutrition_plan.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/engines/decision_engine/models/decision_context.dart';
import 'package:gymgenius/engines/nutrition_engine/nutrition_engine.dart';

/// Builds a [NutritionPlan] from Decision Engine context and the final workout.
///
/// Bridges Workout adaptations (rest day, recovery session, deload) into
/// nutrition targets without duplicating Nutrition Engine calculations.
class NutritionPlanBuilder {
  final NutritionEngine _nutritionEngine;

  const NutritionPlanBuilder({
    required NutritionEngine nutritionEngine,
  }) : _nutritionEngine = nutritionEngine;

  NutritionPlan build({
    required DecisionContext context,
    required TodayWorkout finalWorkout,
  }) {
    final isTrainingDay =
        finalWorkout.hasExercises && !finalWorkout.isRecoverySession;

    final basePlan = _nutritionEngine.computeDailyPlanSync(
      profile: context.healthProfile,
      isTrainingDay: isTrainingDay,
      date: context.now,
    );

    final extraReasons = <String>[];

    if (finalWorkout.isRestDay) {
      extraReasons.add(
        'Rest day: calories adjusted for recovery without training bonus.',
      );
    } else if (finalWorkout.isRecoverySession) {
      extraReasons.add(
        'Recovery session: nutrition plan uses rest-day energy targets.',
      );
    }

    if (context.programProgress.deloadPlan.isDeload) {
      extraReasons.add(
        'Deload week: maintain protein and support recovery with adequate carbs.',
      );
    }

    if (extraReasons.isEmpty) return basePlan;

    return NutritionPlan(
      userId: basePlan.userId,
      date: basePlan.date,
      targets: basePlan.targets,
      maintenanceCalories: basePlan.maintenanceCalories,
      status: basePlan.status,
      meals: basePlan.meals,
      country: basePlan.country,
      isTrainingDay: basePlan.isTrainingDay,
      reasons: [...basePlan.reasons, ...extraReasons],
      generatedBy: basePlan.generatedBy,
    );
  }

  Future<NutritionPlan> buildAndPersist({
    required DecisionContext context,
    required TodayWorkout finalWorkout,
  }) async {
    final plan = build(
      context: context,
      finalWorkout: finalWorkout,
    );

    await _nutritionEngine.persistPlan(
      plan: plan,
      profile: context.healthProfile,
    );

    return plan;
  }
}
