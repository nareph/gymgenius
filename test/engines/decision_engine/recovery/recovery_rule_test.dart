import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/recovery_status.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/activity_level.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';
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
import 'package:gymgenius/domain/enums/program_phase.dart';
import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/recommended_intensity.dart';
import 'package:gymgenius/domain/enums/soreness_level.dart';
import 'package:gymgenius/domain/enums/split_type.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/decision_engine/Progression/deload_planner.dart';
import 'package:gymgenius/engines/decision_engine/Progression/mesocycle_planner.dart';
import 'package:gymgenius/engines/decision_engine/Progression/week_progression_calculator.dart';
import 'package:gymgenius/engines/decision_engine/models/decision_context.dart';
import 'package:gymgenius/engines/decision_engine/models/program_progress.dart';
import 'package:gymgenius/engines/decision_engine/rules/recovery_rule.dart';
import 'package:gymgenius/engines/decision_engine/services/conflict_resolver.dart';
import 'package:gymgenius/engines/decision_engine/services/volume_adjustment_service.dart';
import 'package:gymgenius/engines/recovery_engine/recovery_engine.dart';
import 'package:gymgenius/engines/recovery_engine/recovery_thresholds.dart';

import '../../nutrition_engine/calorie_macro_test.dart';

Exercise _exercise({required String id, int sets = 4}) {
  return Exercise(
    id: id,
    name: 'Ex $id',
    description: 'Split: Push',
    category: ExerciseCategory.compound,
    movementPattern: MovementPattern.push,
    primaryMuscles: const [MuscleGroup.chest],
    equipment: EquipmentType.bodyweight,
    difficulty: ExerciseDifficulty.beginner,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    sets: sets,
    reps: '8-12',
    restSeconds: 90,
    isBodyweight: true,
    isTimed: false,
    instructions: 'Do it',
    tips: const [],
    commonMistakes: const [],
  );
}

TrainingProgram _program() {
  final now = DateTime(2026, 8, 11);
  return TrainingProgram(
    id: 'p1',
    userId: 'u1',
    name: 'Stub',
    goal: FitnessGoal.buildMuscle,
    split: SplitType.pushPullLegs,
    experience: ExperienceLevel.intermediate,
    durationWeeks: 12,
    weeklySchedule: const {},
    generatorType: GeneratorType.local,
    generatorVersion: '1.0',
    createdAt: now,
    expiresAt: now.add(const Duration(days: 84)),
  );
}

ProgramProgress _progress() {
  return const ProgramProgress(
    currentWeek: 1,
    totalWeeks: 12,
    currentPhase: ProgramPhase.base,
    mesocycleInfo: MesocycleInfo(mesocycle: 1, microcycle: 1),
    weekProgression: WeekProgression(
      phase: ProgramPhase.base,
      volumeMultiplier: 1.0,
      intensityMultiplier: 1.0,
      targetRpe: 7.0,
      isDeload: false,
    ),
    deloadPlan: DeloadPlan(
      isDeload: false,
      volumeMultiplier: 1.0,
      intensityMultiplier: 1.0,
    ),
    weeksRemaining: 11,
    completion: 0.0,
  );
}

RecoveryStatus _status({required int readiness}) {
  final mult = RecoveryThresholds.volumeMultiplier(readiness);
  return RecoveryStatus(
    userId: 'u1',
    date: DateTime(2026, 8, 11),
    recoveryScore: readiness,
    fatigueScore: 100 - readiness,
    readinessScore: readiness,
    recommendedIntensity: RecoveryThresholds.intensity(readiness),
    volumeMultiplier: mult,
    reasons: const ['test'],
  );
}

DecisionContext _context({
  RecoveryStatus? recovery,
  ActivityLevel activity = ActivityLevel.moderatelyActive,
}) {
  final date = DateTime(2026, 8, 11);
  final exercises = [_exercise(id: '1'), _exercise(id: '2')];
  return DecisionContext(
    now: date,
    healthProfile: buildTestProfile(activity: activity),
    trainingProgram: _program(),
    programProgress: _progress(),
    todayWorkout: TodayWorkout(
      date: date,
      dayKey: 'tuesday',
      plannedExercises: exercises,
      finalExercises: exercises,
      splitDisplayName: '',
    ),
    recoveryStatus: recovery,
  );
}

void main() {
  const rule = RecoveryRule();
  const volumeService = VolumeAdjustmentService();
  const engine = RecoveryEngine();
  const resolver = ConflictResolver();

  group('RecoveryThresholds alignment', () {
    test('engine multiplier matches shared thresholds for all tiers', () {
      expect(RecoveryThresholds.volumeMultiplier(85), 1.00);
      expect(RecoveryThresholds.volumeMultiplier(70), 0.85);
      expect(RecoveryThresholds.volumeMultiplier(50), 0.70);
      expect(RecoveryThresholds.volumeMultiplier(20), 0.55);
    });

    test('RecoveryRule uses RecoveryStatus.volumeMultiplier', () {
      final status = RecoveryStatus(
        userId: 'u1',
        date: DateTime(2026, 8, 11),
        recoveryScore: 45,
        fatigueScore: 55,
        readinessScore: 45,
        recommendedIntensity: RecommendedIntensity.light,
        volumeMultiplier: 0.70,
        reasons: const [],
      );
      final decision = rule.evaluate(_context(recovery: status));
      expect(decision.requiresAdaptation, isTrue);
      expect(decision.volumeMultiplier, 0.70);
      expect(decision.adjustment, WorkoutAdjustment.reduceVolume);
    });
  });

  group('RecoveryRule readiness tiers', () {
    test('no check-in → keep planned', () {
      final d = rule.evaluate(_context());
      expect(d.requiresAdaptation, isFalse);
      expect(d.adjustment, WorkoutAdjustment.none);
    });

    test('readiness ≥ 80 → keep planned, full volume', () {
      final d = rule.evaluate(_context(recovery: _status(readiness: 85)));
      expect(d.requiresAdaptation, isFalse);
      expect(d.volumeMultiplier, isNull);
    });

    test('readiness 65–79 → mild reduction 0.85', () {
      final d = rule.evaluate(_context(recovery: _status(readiness: 70)));
      expect(d.requiresAdaptation, isTrue);
      expect(d.volumeMultiplier, 0.85);
      expect(d.reasons, contains(DecisionReason.lowRecovery));
    });

    test('readiness 60–64 → mild reduction 0.85', () {
      final d = rule.evaluate(_context(recovery: _status(readiness: 60)));
      expect(d.volumeMultiplier, 0.85);
    });

    test('readiness 40–59 → moderate reduction 0.70', () {
      final d = rule.evaluate(_context(recovery: _status(readiness: 45)));
      expect(d.volumeMultiplier, 0.70);
    });

    test('readiness < 40 → significant reduction 0.55', () {
      final d = rule.evaluate(_context(recovery: _status(readiness: 30)));
      expect(d.volumeMultiplier, 0.55);
    });

    test('RecommendedIntensity.rest does not force restDay adjustment', () {
      final d = rule.evaluate(_context(recovery: _status(readiness: 20)));
      expect(d.adjustment, WorkoutAdjustment.reduceVolume);
      expect(d.adjustment, isNot(WorkoutAdjustment.restDay));
    });

    test('very-active profile gets a softer volume cut than moderately active',
        () {
      final status = _status(readiness: 45);
      final moderate = rule.evaluate(_context(recovery: status));
      final veryActive = rule.evaluate(
        _context(
          recovery: status,
          activity: ActivityLevel.veryActive,
        ),
      );

      expect(moderate.volumeMultiplier, 0.70);
      expect(veryActive.volumeMultiplier, 0.85);
      expect(
          veryActive.volumeMultiplier, greaterThan(moderate.volumeMultiplier!));
    });
  });

  group('VolumeAdjustmentService applies multiplier to sets', () {
    test('sets are scaled and never drop below 1', () {
      final date = DateTime(2026, 8, 11);
      final exercises = [
        _exercise(id: 'a', sets: 4),
        _exercise(id: 'b', sets: 3),
        _exercise(id: 'c', sets: 1),
      ];
      final workout = TodayWorkout(
        date: date,
        dayKey: 'tuesday',
        plannedExercises: exercises,
        finalExercises: exercises,
        splitDisplayName: '',
      );

      final adapted = volumeService.reduceVolume(
        workout,
        volumeMultiplier: 0.55,
      );

      expect(adapted.isAdapted, isTrue);
      expect(adapted.volumeMultiplier, 0.55);
      expect(adapted.plannedExercises.map((e) => e.sets), [4, 3, 1]);
      expect(adapted.finalExercises[0].sets, 2); // 4 * 0.55 = 2.2 → 2
      expect(adapted.finalExercises[1].sets, 2); // 3 * 0.55 = 1.65 → 2
      expect(adapted.finalExercises[2].sets, 1); // min 1
    });

    test('full multiplier leaves sets unchanged', () {
      final date = DateTime(2026, 8, 11);
      final exercises = [_exercise(id: 'a', sets: 4)];
      final workout = TodayWorkout(
        date: date,
        dayKey: 'tuesday',
        plannedExercises: exercises,
        finalExercises: exercises,
        splitDisplayName: '',
      );
      final adapted =
          volumeService.reduceVolume(workout, volumeMultiplier: 1.0);
      expect(adapted.finalExercises.first.sets, 4);
      expect(identical(adapted, workout) || !adapted.isAdapted, isTrue);
    });
  });

  group('ConflictResolver priority', () {
    test('restDay from safety wins over recovery reduceVolume', () {
      final recoveryDecision = rule.evaluate(
        _context(recovery: _status(readiness: 30)),
      );
      final safety = WorkoutDecision(
        requiresAdaptation: true,
        adjustment: WorkoutAdjustment.restDay,
        confidence: 1.0,
        reasons: const [DecisionReason.recoveryRequired],
      );
      final winner = resolver.resolve([recoveryDecision, safety]);
      expect(winner.adjustment, WorkoutAdjustment.restDay);
    });
  });

  group('Engine → Rule coherence', () {
    test('poor check-in produces matching multiplier in rule', () {
      final checkIn = DailyCheckIn(
        userId: 'u1',
        date: DateTime(2026, 8, 11),
        sleepHours: 3.0,
        sorenessLevel: SorenessLevel.severe,
        energyLevel: EnergyLevel.veryLow,
        mood: 1,
      );
      final status = engine.compute(checkIn);
      final decision = rule.evaluate(_context(recovery: status));
      expect(decision.volumeMultiplier, status.volumeMultiplier);
      expect(status.volumeMultiplier, lessThan(1.0));
    });
  });
}
