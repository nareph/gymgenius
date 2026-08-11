import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/entities/weekly_progress_report.dart';
import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/exercise_difficulty.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/force_type.dart';
import 'package:gymgenius/domain/enums/generator_type.dart';
import 'package:gymgenius/domain/enums/laterality.dart';
import 'package:gymgenius/domain/enums/mechanics.dart';
import 'package:gymgenius/domain/enums/movement_pattern.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/plane_of_motion.dart';
import 'package:gymgenius/domain/enums/soreness_level.dart';
import 'package:gymgenius/domain/enums/split_type.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/ai_coach/ai_coach_engine.dart';
import 'package:gymgenius/engines/ai_coach/ai_config.dart';
import 'package:gymgenius/engines/ai_coach/providers/ai_provider.dart';
import 'package:gymgenius/engines/ai_coach/providers/coach_request_options.dart';
import 'package:gymgenius/engines/ai_coach/providers/local_coach_provider.dart';
import 'package:gymgenius/engines/ai_coach/prompts/coach_prompts.dart';
import 'package:gymgenius/engines/ai_coach/validators/coach_response_validator.dart';
import 'package:gymgenius/engines/decision_engine/Progression/program_progress_service.dart';
import 'package:gymgenius/engines/decision_engine/builders/today_workout_builder.dart';
import 'package:gymgenius/engines/decision_engine/decision_engine.dart';
import 'package:gymgenius/engines/decision_engine/models/daily_plan.dart';
import 'package:gymgenius/engines/decision_engine/rules/deload_rule.dart';
import 'package:gymgenius/engines/decision_engine/rules/equipment_rule.dart';
import 'package:gymgenius/engines/decision_engine/rules/injury_rule.dart';
import 'package:gymgenius/engines/decision_engine/rules/nutrition/nutrition_plan_builder.dart';
import 'package:gymgenius/engines/decision_engine/rules/nutrition/nutrition_rule.dart';
import 'package:gymgenius/engines/decision_engine/rules/progress_rule.dart';
import 'package:gymgenius/engines/decision_engine/rules/progression_rule.dart';
import 'package:gymgenius/engines/decision_engine/rules/recovery_rule.dart';
import 'package:gymgenius/engines/decision_engine/rules/safety_rule.dart';
import 'package:gymgenius/engines/decision_engine/services/conflict_resolver.dart';
import 'package:gymgenius/engines/decision_engine/services/deload_service.dart';
import 'package:gymgenius/engines/decision_engine/services/exercise_substitution_service.dart';
import 'package:gymgenius/engines/decision_engine/services/intensity_adjustment_service.dart';
import 'package:gymgenius/engines/decision_engine/services/recovery_session_service.dart';
import 'package:gymgenius/engines/decision_engine/services/volume_adjustment_service.dart';
import 'package:gymgenius/engines/decision_engine/services/workout_adaptation_service.dart';
import 'package:gymgenius/engines/nutrition_engine/nutrition_engine.dart';
import 'package:gymgenius/engines/recovery_engine/recovery_engine.dart';
import 'package:gymgenius/engines/workout_engine/providers/exercise_replacement_provider.dart';

import '../nutrition_engine/calorie_macro_test.dart';

/// Counts complete calls; throws to simulate provider failure.
class _CountingFailProvider implements AIProvider {
  int calls = 0;

  @override
  String get id => 'failing';

  @override
  bool get isAvailable => true;

  @override
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    CoachRequestOptions options = const CoachRequestOptions(),
  }) async {
    calls++;
    throw Exception('provider unavailable');
  }
}

DecisionEngine _decisionEngine() {
  final nutritionRule = NutritionRule(
    planBuilder: NutritionPlanBuilder(nutritionEngine: NutritionEngine()),
  );
  return DecisionEngine(
    programProgressService: const ProgramProgressService(),
    todayWorkoutBuilder: const TodayWorkoutBuilder(),
    workoutAdaptationService: WorkoutAdaptationService(
      volumeAdjustmentService: const VolumeAdjustmentService(),
      intensityAdjustmentService: const IntensityAdjustmentService(),
      exerciseSubstitutionService: ExerciseSubstitutionService(
        replacementProvider: const ExerciseReplacementProvider(),
      ),
      recoverySessionService: const RecoverySessionService(),
      deloadService: const DeloadService(),
    ),
    conflictResolver: const ConflictResolver(),
    nutritionRule: nutritionRule,
    recoveryEngine: const RecoveryEngine(),
    rules: [
      const InjuryRule(),
      const SafetyRule(),
      const RecoveryRule(),
      const DeloadRule(),
      const ProgressionRule(),
      const EquipmentRule(),
      const ProgressRule(),
      nutritionRule,
    ],
  );
}

Exercise _exercise(String id) => Exercise(
      id: id,
      name: 'Ex $id',
      description: 'Push',
      category: ExerciseCategory.compound,
      movementPattern: MovementPattern.push,
      primaryMuscles: const [MuscleGroup.chest],
      equipment: EquipmentType.dumbbells,
      difficulty: ExerciseDifficulty.beginner,
      mechanics: Mechanics.closedChain,
      forceType: ForceType.push,
      laterality: Laterality.bilateral,
      planeOfMotion: PlaneOfMotion.sagittal,
      sets: 4,
      reps: '8-12',
      restSeconds: 90,
      isBodyweight: false,
      isTimed: false,
      instructions: 'Do it',
      tips: const [],
      commonMistakes: const [],
    );

TrainingProgram _program(DateTime now) {
  const days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
  return TrainingProgram(
    id: 'p1',
    userId: 'user-1',
    name: 'Coach',
    goal: FitnessGoal.buildMuscle,
    split: SplitType.pushPullLegs,
    experience: ExperienceLevel.intermediate,
    durationWeeks: 12,
    weeklySchedule: {
      days[now.weekday - 1]: [_exercise('1'), _exercise('2')],
    },
    generatorType: GeneratorType.local,
    generatorVersion: '1.0',
    createdAt: now.subtract(const Duration(days: 7)),
    expiresAt: now.add(const Duration(days: 77)),
  );
}

DailyPlan _lowRecoveryPlan(DateTime now) {
  return _decisionEngine().buildDailyPlan(
    _program(now),
    buildTestProfile(),
    now: now,
    checkIn: DailyCheckIn(
      userId: 'user-1',
      date: now,
      sleepHours: 4.5,
      sorenessLevel: SorenessLevel.severe,
      energyLevel: EnergyLevel.veryLow,
      mood: 1,
      weightKg: 80,
    ),
  );
}

void main() {
  final now = DateTime(2026, 8, 11);

  test('DailyPlan → daily coaching (local path without cloud key)', () async {
    expect(AIConfig.canUseCoachCloud, isFalse,
        reason: 'tests run without GEMINI_API_KEY');

    final plan = _lowRecoveryPlan(now);
    expect(plan.finalDecision.adjustment, WorkoutAdjustment.reduceVolume);

    final engine = AICoachEngine(
      primary: _CountingFailProvider(),
      local: const LocalCoachProvider(),
    );

    final coaching = await engine.generateDailyCoaching(plan);

    expect(coaching.message, isNotEmpty);
    expect(coaching.usedFallback, isTrue);
    expect(coaching.providerId, 'local');
    expect(
      coaching.recommendations.any(
        (r) => (r.actionTag ?? '') == 'increase_volume',
      ),
      isFalse,
    );
    expect(coaching.message.toLowerCase(), contains('reduced'));
  });

  test('low recovery chat does not invent numbers', () async {
    final plan = _lowRecoveryPlan(now);
    final engine = AICoachEngine(primary: const LocalCoachProvider());

    final answer = await engine.chat(
      plan: plan,
      question: 'Why was volume reduced?',
    );

    expect(answer.message, isNotEmpty);
    expect(answer.message.toLowerCase(), isNot(contains('increase volume')));
  });

  test('weekly summary uses WeeklyProgressReport figures', () async {
    final plan = _lowRecoveryPlan(now);
    final report = WeeklyProgressReport(
      userId: 'user-1',
      weekStart: now.subtract(const Duration(days: 6)),
      weekEnd: now,
      workoutsCompleted: 2,
      workoutsPlanned: 4,
      consistencyScore: 50,
      weightChangeKg: 0.2,
      positives: const ['Logged weight'],
      improvements: const ['Complete more sessions'],
    );

    final engine = AICoachEngine(primary: const LocalCoachProvider());
    final summary = await engine.generateWeeklySummary(
      plan: plan,
      report: report,
    );

    expect(summary.message, contains('2/4'));
    expect(summary.message, contains('50%'));
    expect(summary.message, contains('0.2'));
  });

  test('validator rejects conflicting volume-up advice for reduced plans', () {
    final plan = _lowRecoveryPlan(now);
    final context = AICoachEngine(primary: const LocalCoachProvider())
        .buildContext(plan);
    expect(context.volumeWasReduced, isTrue);

    final raw = jsonEncode({
      'message': 'Push harder',
      'recommendations': [
        {
          'category': 'workout',
          'text': 'Increase volume today',
          'reason': 'x',
          'alignsWithDecision': false,
          'actionTag': 'increase_volume',
        }
      ],
    });

    final parsed = CoachResponseValidator().tryParse(
      raw: raw,
      context: context,
      providerId: 'mock',
      promptVersion: CoachPrompts.promptVersion,
    );

    expect(parsed, isNotNull);
    expect(parsed!.recommendations, isEmpty);
  });
}
