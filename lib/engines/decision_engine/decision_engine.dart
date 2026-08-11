import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/engines/decision_engine/Progression/program_progress_service.dart';
import 'package:gymgenius/engines/decision_engine/services/conflict_resolver.dart';
import 'package:gymgenius/engines/nutrition_engine/nutrition_engine.dart';

import 'builders/today_workout_builder.dart';
import 'models/daily_plan.dart';
import 'models/decision_context.dart';
import 'models/health_decision.dart';
import 'models/program_progress.dart';
import 'rules/decision_rule.dart';
import 'services/workout_adaptation_service.dart';

/// Central orchestrator of the Decision Engine.
///
/// Responsibilities:
///
/// • Build DecisionContext
/// • Execute every DecisionRule
/// • Resolve conflicts
/// • Adapt today's workout
/// • Attach NutritionPlan
/// • Produce the final DailyPlan
///
/// The DecisionEngine itself contains no business logic.
class DecisionEngine {
  final ProgramProgressService _programProgressService;
  final TodayWorkoutBuilder _todayWorkoutBuilder;
  final WorkoutAdaptationService _workoutAdaptationService;
  final ConflictResolver _conflictResolver;
  final NutritionEngine _nutritionEngine;

  final List<DecisionRule> _rules;

  const DecisionEngine({
    required ProgramProgressService programProgressService,
    required TodayWorkoutBuilder todayWorkoutBuilder,
    required WorkoutAdaptationService workoutAdaptationService,
    required ConflictResolver conflictResolver,
    required List<DecisionRule> rules,
    required NutritionEngine nutritionEngine,
  })  : _programProgressService = programProgressService,
        _todayWorkoutBuilder = todayWorkoutBuilder,
        _workoutAdaptationService = workoutAdaptationService,
        _conflictResolver = conflictResolver,
        _rules = rules,
        _nutritionEngine = nutritionEngine;

  // ============================================================
  // Daily Plan
  // ============================================================

  DailyPlan buildDailyPlan(
    TrainingProgram trainingProgram,
    HealthProfile healthProfile, {
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();

    // ----------------------------------------------------------
    // Program Progress
    // ----------------------------------------------------------

    final progress = _programProgressService.calculate(trainingProgram);

    // ----------------------------------------------------------
    // Planned Workout
    // ----------------------------------------------------------

    final plannedWorkout = _todayWorkoutBuilder.buildPlannedWorkout(
      program: trainingProgram,
      now: currentDate,
    );

    // ----------------------------------------------------------
    // Context
    // ----------------------------------------------------------

    final context = DecisionContext(
      now: currentDate,
      healthProfile: healthProfile,
      trainingProgram: trainingProgram,
      programProgress: progress,
      todayWorkout: plannedWorkout,
    );

    // ----------------------------------------------------------
    // Evaluate every rule
    // ----------------------------------------------------------

    final decisions = <WorkoutDecision>[];

    for (final rule in _rules) {
      decisions.add(
        rule.evaluate(context),
      );
    }

    // ----------------------------------------------------------
    // Resolve conflicts
    // ----------------------------------------------------------

    final finalDecision = _conflictResolver.resolve(
      decisions,
    );

    // ----------------------------------------------------------
    // Apply adaptations
    // ----------------------------------------------------------

    final finalWorkout = _workoutAdaptationService.adapt(
      plannedWorkout: plannedWorkout,
      decision: finalDecision,
      profile: healthProfile,
    );

    // ----------------------------------------------------------
    // Nutrition (deterministic)
    // ----------------------------------------------------------

    final nutritionPlan = _nutritionEngine.computeDailyPlanSync(
      profile: healthProfile,
      isTrainingDay: finalWorkout.hasExercises && !finalWorkout.isRecoverySession,
      date: currentDate,
    );

    // ----------------------------------------------------------
    // Final Daily Plan
    // ----------------------------------------------------------

    return DailyPlan(
      context: context.copyWith(
        todayWorkout: finalWorkout,
      ),
      programProgress: progress,
      todayWorkout: finalWorkout,
      nutritionPlan: nutritionPlan,
      confidence: finalDecision.confidence,
      generatedAt: currentDate,
    );
  }

  // ============================================================
  // Convenience methods
  // ============================================================

  ProgramProgress getProgramProgress(
    TrainingProgram program,
  ) {
    return _programProgressService.calculate(program);
  }

  TodayWorkout getTodayWorkout(
    TrainingProgram trainingProgram,
    HealthProfile healthProfile, {
    DateTime? now,
  }) {
    return buildDailyPlan(
      trainingProgram,
      healthProfile,
      now: now,
    ).todayWorkout;
  }

  // Temporary until AI Coach / Health Engine
  HealthDecision getDefaultDecision({
    DateTime? now,
  }) {
    return HealthDecision(
      primaryAction: 'complete_scheduled_workout',
      reason: 'No recovery or nutrition data available yet.',
      confidence: 0.5,
      generatedAt: now ?? DateTime.now(),
    );
  }
}
