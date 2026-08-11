import 'package:gymgenius/domain/enums/decision_reason.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/health_caution_level.dart';
import 'package:gymgenius/domain/enums/nutrition_status.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_context.dart';
import 'package:gymgenius/engines/decision_engine/models/daily_plan.dart';

/// Builds a compact [CoachContext] from a [DailyPlan].
class CoachContextBuilder {
  const CoachContextBuilder();

  CoachContext build(DailyPlan plan) {
    final profile = plan.context.healthProfile;
    final decision = plan.finalDecision;
    final recovery = plan.recoveryStatus;
    final nutrition = plan.nutritionPlan;
    final progress = plan.progressSnapshot;
    final health = plan.healthDecision;
    final hp = plan.healthPlatformSnapshot;

    return CoachContext(
      userId: profile.userId,
      now: plan.generatedAt,
      goal: profile.goal.value,
      experience: profile.experience.value,
      isRestDay: plan.isRestDay,
      isAdapted: plan.isAdapted,
      workoutAdjustment: decision.adjustment.value,
      decisionReasons:
          decision.reasons.map((r) => r.displayName).toList(growable: false),
      plannedExerciseCount: plan.todayWorkout.finalExerciseCount,
      readinessScore: recovery?.readinessScore,
      recoveryScore: recovery?.recoveryScore,
      volumeMultiplier: recovery?.volumeMultiplier ?? decision.volumeMultiplier,
      nutritionCalories: nutrition?.targets.calories,
      nutritionProteinG: nutrition?.targets.proteinG,
      nutritionStatus: nutrition?.status.value,
      consistencyScore: progress?.consistency?.consistencyScore,
      weightPlateau: progress?.weightPlateauDetected ?? false,
      strengthPlateau: progress?.strengthPlateauDetected ?? false,
      progressReasons: progress?.reasons ?? const [],
      healthPrimaryAction: health?.primaryAction,
      healthReason: health?.reason,
      decisionConfidence: plan.confidence,
      hydrationPercent: hp?.hydrationPercent,
      habitsCompletionPercent: hp?.habitsCompletionPercent,
      habitsStreakSummary: hp == null
          ? null
          : (hp.longestCurrentStreak > 0
              ? 'longest_streak_${hp.longestCurrentStreak}'
              : 'no_streak'),
      wellnessTrend: hp?.wellnessTrendLabel,
      hasBpCaution: hp?.hasBpCaution ?? false,
      hasGlucoseCaution: hp?.hasGlucoseCaution ?? false,
      healthPlatformCaution: hp?.overallCaution.value,
    );
  }
}
