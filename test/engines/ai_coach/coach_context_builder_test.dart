import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/progress_snapshot.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
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
import 'package:gymgenius/domain/enums/progress_period.dart';
import 'package:gymgenius/domain/enums/soreness_level.dart';
import 'package:gymgenius/domain/enums/split_type.dart';
import 'package:gymgenius/engines/ai_coach/builders/coach_context_builder.dart';
import 'package:gymgenius/engines/decision_engine/Progression/program_progress_service.dart';
import 'package:gymgenius/engines/decision_engine/builders/today_workout_builder.dart';
import 'package:gymgenius/engines/decision_engine/decision_engine.dart';
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

DecisionEngine _engine() {
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
    userId: 'u1',
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

void main() {
  final now = DateTime(2026, 8, 11);
  const builder = CoachContextBuilder();

  test('builds context from DailyPlan domains', () {
    final plan = _engine().buildDailyPlan(
      _program(now),
      buildTestProfile(),
      now: now,
      checkIn: DailyCheckIn(
        userId: 'u1',
        date: now,
        sleepHours: 4.5,
        sorenessLevel: SorenessLevel.severe,
        energyLevel: EnergyLevel.veryLow,
        mood: 1,
        weightKg: 80,
      ),
      progressSnapshot: ProgressSnapshot(
        userId: 'u1',
        computedAt: now,
        period: ProgressPeriod.weekly,
        weightPlateauDetected: true,
        reasons: const ['weight_plateau'],
      ),
    );

    final ctx = builder.build(plan);

    expect(ctx.userId, 'user-1');
    expect(ctx.goal, isNotNull);
    expect(ctx.experience, isNotNull);
    expect(ctx.isAdapted, isTrue);
    expect(ctx.volumeWasReduced, isTrue);
    expect(ctx.readinessScore, isNotNull);
    expect(ctx.nutritionCalories, isNotNull);
    expect(ctx.nutritionStatus, isNotNull);
    expect(ctx.weightPlateau, isTrue);
    expect(ctx.progressReasons, contains('weight_plateau'));
    expect(ctx.healthPrimaryAction, isNotNull);
    expect(ctx.toPromptMap()['workoutAdjustment'], isNotEmpty);
  });
}
