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
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/decision_engine/Progression/program_progress_service.dart';
import 'package:gymgenius/engines/decision_engine/builders/today_workout_builder.dart';
import 'package:gymgenius/engines/decision_engine/decision_engine.dart';
import 'package:gymgenius/engines/decision_engine/policies/program_refresh_policy.dart';
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

DecisionEngine _buildEngine() {
  final nutritionRule = NutritionRule(
    planBuilder: NutritionPlanBuilder(
      nutritionEngine: NutritionEngine(),
    ),
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

Exercise _exercise({required String id, int sets = 4}) {
  return Exercise(
    id: id,
    name: 'Ex $id',
    description: 'Split: Push',
    category: ExerciseCategory.compound,
    movementPattern: MovementPattern.push,
    primaryMuscles: const [MuscleGroup.chest],
    equipment: EquipmentType.dumbbells,
    difficulty: ExerciseDifficulty.beginner,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    sets: sets,
    reps: '8-12',
    restSeconds: 90,
    isBodyweight: false,
    isTimed: false,
    instructions: 'Do it',
    tips: const [],
    commonMistakes: const [],
  );
}

TrainingProgram _programWithTodayWorkout(DateTime now) {
  const days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
  final dayKey = days[now.weekday - 1];
  return TrainingProgram(
    id: 'p1',
    userId: 'u1',
    name: 'Phase6',
    goal: FitnessGoal.buildMuscle,
    split: SplitType.pushPullLegs,
    experience: ExperienceLevel.intermediate,
    durationWeeks: 12,
    weeklySchedule: {
      dayKey: [_exercise(id: '1', sets: 4), _exercise(id: '2', sets: 4)],
    },
    generatorType: GeneratorType.local,
    generatorVersion: '1.0',
    createdAt: now.subtract(const Duration(days: 7)),
    expiresAt: now.add(const Duration(days: 77)),
  );
}

DailyCheckIn _checkIn({
  required DateTime date,
  required double sleepHours,
  required SorenessLevel soreness,
  required EnergyLevel energy,
  required int mood,
}) {
  return DailyCheckIn(
    userId: 'u1',
    date: date,
    sleepHours: sleepHours,
    sorenessLevel: soreness,
    energyLevel: energy,
    mood: mood,
    weightKg: 80,
  );
}

void main() {
  final now = DateTime(2026, 8, 11); // Tuesday
  late DecisionEngine engine;

  setUp(() {
    engine = _buildEngine();
  });

  group('Phase 6 DecisionEngine multi-domain', () {
    test('low recovery reduces volume and fills DailyPlan domains', () {
      final program = _programWithTodayWorkout(now);
      final profile = buildTestProfile();
      final checkIn = _checkIn(
        date: now,
        sleepHours: 4.5,
        soreness: SorenessLevel.severe,
        energy: EnergyLevel.veryLow,
        mood: 1,
      );
      final progress = ProgressSnapshot(
        userId: 'u1',
        computedAt: now,
        period: ProgressPeriod.weekly,
        weightPlateauDetected: false,
      );

      final plan = engine.buildDailyPlan(
        program,
        profile,
        now: now,
        checkIn: checkIn,
        progressSnapshot: progress,
      );

      expect(plan.hasRecovery, isTrue);
      expect(plan.hasNutrition, isTrue);
      expect(plan.hasProgress, isTrue);
      expect(plan.hasHealthDecision, isTrue);
      expect(plan.finalDecision.requiresAdaptation, isTrue);
      expect(
        plan.finalDecision.adjustment,
        WorkoutAdjustment.reduceVolume,
      );
      expect(plan.isAdapted, isTrue);
      expect(plan.confidence, inInclusiveRange(0.0, 1.0));
      expect(plan.healthDecision!.primaryAction, isNotEmpty);
    });

    test('good recovery keeps planned workout', () {
      final program = _programWithTodayWorkout(now);
      final profile = buildTestProfile();
      final checkIn = _checkIn(
        date: now,
        sleepHours: 8,
        soreness: SorenessLevel.none,
        energy: EnergyLevel.high,
        mood: 5,
      );

      final plan = engine.buildDailyPlan(
        program,
        profile,
        now: now,
        checkIn: checkIn,
      );

      expect(plan.hasRecovery, isTrue);
      expect(plan.finalDecision.requiresAdaptation, isFalse);
      expect(plan.finalDecision.adjustment, WorkoutAdjustment.none);
      expect(plan.isAdapted, isFalse);
      expect(
        plan.healthDecision!.primaryAction,
        'complete_scheduled_workout',
      );
    });

    test('progress snapshot is observe-only and never adapts alone', () {
      final program = _programWithTodayWorkout(now);
      final profile = buildTestProfile();
      final progress = ProgressSnapshot(
        userId: 'u1',
        computedAt: now,
        period: ProgressPeriod.weekly,
        strengthPlateauDetected: true,
        weightPlateauDetected: true,
      );

      final plan = engine.buildDailyPlan(
        program,
        profile,
        now: now,
        progressSnapshot: progress,
      );

      expect(plan.hasProgress, isTrue);
      expect(plan.progressSnapshot!.anyPlateauDetected, isTrue);
      expect(plan.finalDecision.requiresAdaptation, isFalse);
      expect(plan.healthDecision!.primaryAction, 'monitor_plateau');
      expect(plan.shouldRefreshProgram, isFalse);
    });

    test('expired program asks for refresh without adapting today', () {
      final program = _programWithTodayWorkout(now).copyWith(
        expiresAt: now.subtract(const Duration(days: 1)),
      );
      final profile = buildTestProfile();

      final plan = engine.buildDailyPlan(program, profile, now: now);

      expect(plan.shouldRefreshProgram, isTrue);
      expect(plan.programRefresh!.reason, ProgramRefreshReason.expired);
      expect(plan.finalDecision.requiresAdaptation, isFalse);
    });

    test('missing check-in and progress still produces DailyPlan', () {
      final program = _programWithTodayWorkout(now);
      final profile = buildTestProfile();

      final plan = engine.buildDailyPlan(program, profile, now: now);

      expect(plan.hasRecovery, isFalse);
      expect(plan.hasProgress, isFalse);
      expect(plan.hasNutrition, isTrue);
      expect(plan.hasHealthDecision, isTrue);
      expect(plan.finalDecision, isNotNull);
    });

    test('same inputs produce identical outputs', () {
      final program = _programWithTodayWorkout(now);
      final profile = buildTestProfile();
      final checkIn = _checkIn(
        date: now,
        sleepHours: 6,
        soreness: SorenessLevel.mild,
        energy: EnergyLevel.moderate,
        mood: 3,
      );

      final a = engine.buildDailyPlan(
        program,
        profile,
        now: now,
        checkIn: checkIn,
      );
      final b = engine.buildDailyPlan(
        program,
        profile,
        now: now,
        checkIn: checkIn,
      );

      expect(a.finalDecision.adjustment, b.finalDecision.adjustment);
      expect(a.confidence, b.confidence);
      expect(a.healthDecision!.primaryAction, b.healthDecision!.primaryAction);
      expect(
          a.recoveryStatus!.readinessScore, b.recoveryStatus!.readinessScore);
    });
  });
}
