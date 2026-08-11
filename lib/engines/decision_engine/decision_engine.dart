import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/engines/decision_engine/Progression/program_progress_service.dart';
import 'package:gymgenius/engines/decision_engine/services/conflict_resolver.dart';
import 'package:gymgenius/engines/decision_engine/rules/nutrition/nutrition_rule.dart';
import 'package:gymgenius/engines/recovery_engine/recovery_engine.dart';

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
  final NutritionRule _nutritionRule;
  final RecoveryEngine _recoveryEngine;

  final List<DecisionRule> _rules;

  const DecisionEngine({
    required ProgramProgressService programProgressService,
    required TodayWorkoutBuilder todayWorkoutBuilder,
    required WorkoutAdaptationService workoutAdaptationService,
    required ConflictResolver conflictResolver,
    required List<DecisionRule> rules,
    required NutritionRule nutritionRule,
    RecoveryEngine recoveryEngine = const RecoveryEngine(),
  })  : _programProgressService = programProgressService,
        _todayWorkoutBuilder = todayWorkoutBuilder,
        _workoutAdaptationService = workoutAdaptationService,
        _conflictResolver = conflictResolver,
        _rules = rules,
        _nutritionRule = nutritionRule,
        _recoveryEngine = recoveryEngine;

  // ============================================================
  // Daily Plan
  // ============================================================

  DailyPlan buildDailyPlan(
    TrainingProgram trainingProgram,
    HealthProfile healthProfile, {
    DateTime? now,
    DailyCheckIn? checkIn,
  }) {
    final currentDate = now ?? DateTime.now();
    final progress = _programProgressService.calculate(trainingProgram);
    final plannedWorkout = _todayWorkoutBuilder.buildPlannedWorkout(
      program: trainingProgram,
      now: currentDate,
    );
    final recoveryStatus =
        checkIn != null ? _recoveryEngine.compute(checkIn) : null;
    final context = DecisionContext(
      now: currentDate,
      healthProfile: healthProfile,
      trainingProgram: trainingProgram,
      programProgress: progress,
      todayWorkout: plannedWorkout,
      recoveryStatus: recoveryStatus,
    );

    return _buildDailyPlanFromContext(
      context: context,
      progress: progress,
      plannedWorkout: plannedWorkout,
      healthProfile: healthProfile,
      currentDate: currentDate,
      recoveryStatus: recoveryStatus,
    );
  }

  Future<DailyPlan> buildDailyPlanAndPersist(
    TrainingProgram trainingProgram,
    HealthProfile healthProfile, {
    DateTime? now,
    DailyCheckIn? checkIn,
  }) async {
    final currentDate = now ?? DateTime.now();
    final progress = _programProgressService.calculate(trainingProgram);
    final plannedWorkout = _todayWorkoutBuilder.buildPlannedWorkout(
      program: trainingProgram,
      now: currentDate,
    );

    RecoveryStatus? recoveryStatus;
    if (checkIn != null) {
      recoveryStatus = await _recoveryEngine.computeAndPersist(checkIn);
    }

    final context = DecisionContext(
      now: currentDate,
      healthProfile: healthProfile,
      trainingProgram: trainingProgram,
      programProgress: progress,
      todayWorkout: plannedWorkout,
      recoveryStatus: recoveryStatus,
    );

    final decisions = _evaluateRules(context);
    final finalDecision = _conflictResolver.resolve(decisions);
    final finalWorkout = _workoutAdaptationService.adapt(
      plannedWorkout: plannedWorkout,
      decision: finalDecision,
      profile: healthProfile,
    );
    final adaptedContext = context.copyWith(todayWorkout: finalWorkout);
    final nutritionPlan = await _nutritionRule.buildAndPersistNutritionPlan(
      context: adaptedContext,
      finalWorkout: finalWorkout,
    );

    return DailyPlan(
      context: adaptedContext,
      programProgress: progress,
      todayWorkout: finalWorkout,
      nutritionPlan: nutritionPlan,
      recoveryStatus: recoveryStatus,
      confidence: finalDecision.confidence,
      generatedAt: currentDate,
    );
  }

  DailyPlan _buildDailyPlanFromContext({
    required DecisionContext context,
    required ProgramProgress progress,
    required TodayWorkout plannedWorkout,
    required HealthProfile healthProfile,
    required DateTime currentDate,
    RecoveryStatus? recoveryStatus,
  }) {
    final decisions = _evaluateRules(context);
    final finalDecision = _conflictResolver.resolve(decisions);
    final finalWorkout = _workoutAdaptationService.adapt(
      plannedWorkout: plannedWorkout,
      decision: finalDecision,
      profile: healthProfile,
    );
    final adaptedContext = context.copyWith(todayWorkout: finalWorkout);
    final nutritionPlan = _nutritionRule.buildNutritionPlan(
      context: adaptedContext,
      finalWorkout: finalWorkout,
    );

    return DailyPlan(
      context: adaptedContext,
      programProgress: progress,
      todayWorkout: finalWorkout,
      nutritionPlan: nutritionPlan,
      recoveryStatus: recoveryStatus,
      confidence: finalDecision.confidence,
      generatedAt: currentDate,
    );
  }

  List<WorkoutDecision> _evaluateRules(DecisionContext context) {
    final decisions = <WorkoutDecision>[];
    for (final rule in _rules) {
      decisions.add(
        rule.evaluate(context),
      );
    }
    return decisions;
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
