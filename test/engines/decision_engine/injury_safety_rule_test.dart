import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';
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
import 'package:gymgenius/domain/enums/split_type.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/decision_engine/Progression/deload_planner.dart';
import 'package:gymgenius/engines/decision_engine/Progression/mesocycle_planner.dart';
import 'package:gymgenius/engines/decision_engine/Progression/week_progression_calculator.dart';
import 'package:gymgenius/engines/decision_engine/models/decision_context.dart';
import 'package:gymgenius/engines/decision_engine/models/program_progress.dart';
import 'package:gymgenius/engines/decision_engine/rules/injury_rule.dart';
import 'package:gymgenius/engines/decision_engine/rules/safety_rule.dart';
import 'package:gymgenius/engines/decision_engine/services/conflict_resolver.dart';

import '../nutrition_engine/calorie_macro_test.dart';

Exercise _exercise({
  required String id,
  List<MuscleGroup> muscles = const [MuscleGroup.chest],
}) {
  return Exercise(
    id: id,
    name: 'Ex $id',
    description: 'Split: Push',
    category: ExerciseCategory.compound,
    movementPattern: MovementPattern.push,
    primaryMuscles: muscles,
    equipment: EquipmentType.bodyweight,
    difficulty: ExerciseDifficulty.beginner,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    sets: 3,
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

DecisionContext _context({
  List<MuscleGroup> avoided = const [],
  List<Exercise>? exercises,
}) {
  final date = DateTime(2026, 8, 11);
  final session = exercises ??
      [
        _exercise(id: '1', muscles: const [MuscleGroup.chest]),
        _exercise(id: '2', muscles: const [MuscleGroup.shoulders]),
      ];
  final profile = buildTestProfile();
  return DecisionContext(
    now: date,
    healthProfile: profile.copyWith(
      training: profile.training.copyWith(avoidedMuscles: avoided),
    ),
    trainingProgram: _program(),
    programProgress: _progress(),
    todayWorkout: TodayWorkout(
      date: date,
      dayKey: 'tuesday',
      plannedExercises: session,
      finalExercises: session,
    ),
  );
}

void main() {
  const injury = InjuryRule();
  const safety = SafetyRule();
  const resolver = ConflictResolver();

  group('InjuryRule', () {
    test('keeps the plan when HealthProfile has no avoided muscles', () {
      final decision = injury.evaluate(_context());
      expect(decision.requiresAdaptation, isFalse);
    });

    test('substitutes exercises that hit avoided muscles', () {
      final decision = injury.evaluate(
        _context(avoided: const [MuscleGroup.chest]),
      );
      expect(decision.requiresAdaptation, isTrue);
      expect(decision.adjustment, WorkoutAdjustment.replaceExercise);
      expect(decision.reasons, contains(DecisionReason.medicalRestriction));
    });

    test('keeps the plan when avoided muscles are not in today session', () {
      final decision = injury.evaluate(
        _context(avoided: const [MuscleGroup.hamstrings]),
      );
      expect(decision.requiresAdaptation, isFalse);
    });
  });

  group('SafetyRule', () {
    test('keeps the plan when only some exercises are restricted', () {
      final decision = safety.evaluate(
        _context(avoided: const [MuscleGroup.chest]),
      );
      expect(decision.requiresAdaptation, isFalse);
    });

    test('switches to recovery when the whole session is contraindicated', () {
      final decision = safety.evaluate(
        _context(
          avoided: const [MuscleGroup.chest, MuscleGroup.shoulders],
        ),
      );
      expect(decision.requiresAdaptation, isTrue);
      expect(decision.adjustment, WorkoutAdjustment.recoverySession);
      expect(decision.reasons, contains(DecisionReason.medicalRestriction));
    });
  });

  group('Injury vs Safety conflict', () {
    test('full-session restriction prefers recovery over substitution', () {
      final context = _context(
        avoided: const [MuscleGroup.chest, MuscleGroup.shoulders],
      );
      final winner = resolver.resolve([
        injury.evaluate(context),
        safety.evaluate(context),
      ]);
      expect(winner.adjustment, WorkoutAdjustment.recoverySession);
    });
  });
}
