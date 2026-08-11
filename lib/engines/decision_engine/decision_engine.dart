import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/engines/decision_engine/Progression/program_progress_service.dart';
import 'package:gymgenius/engines/decision_engine/builders/health_decision_builder.dart';
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
/// • Build HealthDecision
/// • Produce the final DailyPlan
///
/// The DecisionEngine itself contains no domain business logic.
class DecisionEngine {
  final ProgramProgressService _programProgressService;
  final TodayWorkoutBuilder _todayWorkoutBuilder;
  final WorkoutAdaptationService _workoutAdaptationService;
  final ConflictResolver _conflictResolver;
  final NutritionRule _nutritionRule;
  final RecoveryEngine _recoveryEngine;
  final HealthDecisionBuilder _healthDecisionBuilder;

  final List<DecisionRule> _rules;

  const DecisionEngine({
    required ProgramProgressService programProgressService,
    required TodayWorkoutBuilder todayWorkoutBuilder,
    required WorkoutAdaptationService workoutAdaptationService,
    required ConflictResolver conflictResolver,
    required List<DecisionRule> rules,
    required NutritionRule nutritionRule,
    RecoveryEngine recoveryEngine = const RecoveryEngine(),
    HealthDecisionBuilder healthDecisionBuilder = const HealthDecisionBuilder(),
  })  : _programProgressService = programProgressService,
        _todayWorkoutBuilder = todayWorkoutBuilder,
        _workoutAdaptationService = workoutAdaptationService,
        _conflictResolver = conflictResolver,
        _rules = rules,
        _nutritionRule = nutritionRule,
        _recoveryEngine = recoveryEngine,
        _healthDecisionBuilder = healthDecisionBuilder;

  // ============================================================
  // Daily Plan
  // ============================================================

  DailyPlan buildDailyPlan(
    TrainingProgram trainingProgram,
    HealthProfile healthProfile, {
    DateTime? now,
    DailyCheckIn? checkIn,
    ProgressSnapshot? progressSnapshot,
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
      progressSnapshot: progressSnapshot,
    );

    return _buildDailyPlanFromContext(
      context: context,
      progress: progress,
      plannedWorkout: plannedWorkout,
      healthProfile: healthProfile,
      currentDate: currentDate,
      recoveryStatus: recoveryStatus,
      progressSnapshot: progressSnapshot,
    );
  }

  Future<DailyPlan> buildDailyPlanAndPersist(
    TrainingProgram trainingProgram,
    HealthProfile healthProfile, {
    DateTime? now,
    DailyCheckIn? checkIn,
    ProgressSnapshot? progressSnapshot,
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
      progressSnapshot: progressSnapshot,
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
    final healthDecision = _healthDecisionBuilder.build(
      generatedAt: currentDate,
      finalDecision: finalDecision,
      recoveryStatus: recoveryStatus,
      progressSnapshot: progressSnapshot,
    );

    return DailyPlan(
      context: adaptedContext,
      programProgress: progress,
      todayWorkout: finalWorkout,
      finalDecision: finalDecision,
      nutritionPlan: nutritionPlan,
      recoveryStatus: recoveryStatus,
      progressSnapshot: progressSnapshot,
      healthDecision: healthDecision,
      confidence: finalDecision.confidence.clamp(0.0, 1.0),
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
    ProgressSnapshot? progressSnapshot,
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
    final healthDecision = _healthDecisionBuilder.build(
      generatedAt: currentDate,
      finalDecision: finalDecision,
      recoveryStatus: recoveryStatus,
      progressSnapshot: progressSnapshot,
    );

    return DailyPlan(
      context: adaptedContext,
      programProgress: progress,
      todayWorkout: finalWorkout,
      finalDecision: finalDecision,
      nutritionPlan: nutritionPlan,
      recoveryStatus: recoveryStatus,
      progressSnapshot: progressSnapshot,
      healthDecision: healthDecision,
      confidence: finalDecision.confidence.clamp(0.0, 1.0),
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

  /// Fallback health recommendation when no DailyPlan is available.
  HealthDecision getDefaultDecision({
    DateTime? now,
  }) {
    return _healthDecisionBuilder.build(
      generatedAt: now ?? DateTime.now(),
      finalDecision: WorkoutDecision.keepPlannedWorkout(confidence: 0.5),
      recoveryStatus: null,
      progressSnapshot: null,
    );
  }
}
