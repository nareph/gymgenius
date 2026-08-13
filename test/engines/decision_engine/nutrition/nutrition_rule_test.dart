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
import 'package:gymgenius/engines/decision_engine/rules/nutrition/nutrition_plan_builder.dart';
import 'package:gymgenius/engines/decision_engine/rules/nutrition/nutrition_rule.dart';
import 'package:gymgenius/engines/nutrition_engine/nutrition_engine.dart';

import '../../nutrition_engine/calorie_macro_test.dart';

TrainingProgram _stubProgram() {
  final now = DateTime(2026, 8, 11);
  return TrainingProgram(
    id: 'prog-stub',
    userId: 'user-stub',
    name: 'Stub Program',
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

ProgramProgress _stubProgress() {
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

Exercise _stubExercise() {
  return const Exercise(
    id: 'ex-1',
    name: 'Push-up',
    description: 'Split: Push',
    category: ExerciseCategory.compound,
    movementPattern: MovementPattern.push,
    primaryMuscles: [MuscleGroup.chest],
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
    instructions: 'Do push-ups',
    tips: [],
    commonMistakes: [],
  );
}

TodayWorkout _restDayWorkout(DateTime date) {
  return TodayWorkout(
    date: date,
    dayKey: 'sunday',
    plannedExercises: const [],
    finalExercises: const [],
  );
}

TodayWorkout _trainingDayWorkout(DateTime date) {
  final exercises = [_stubExercise()];
  return TodayWorkout(
    date: date,
    dayKey: 'tuesday',
    plannedExercises: exercises,
    finalExercises: exercises,
  );
}

void main() {
  group('NutritionRule', () {
    late NutritionRule rule;

    setUp(() {
      rule = NutritionRule(
        planBuilder: NutritionPlanBuilder(
          nutritionEngine: NutritionEngine(),
        ),
      );
    });

    test('evaluate keeps planned workout on rest day', () {
      final date = DateTime(2026, 8, 11);
      final decision = rule.evaluate(
        DecisionContext(
          now: date,
          healthProfile: buildTestProfile(),
          trainingProgram: _stubProgram(),
          programProgress: _stubProgress(),
          todayWorkout: _restDayWorkout(date),
        ),
      );

      expect(decision.requiresAdaptation, isFalse);
      expect(decision.adjustment, WorkoutAdjustment.none);
      expect(decision.reasons, contains(DecisionReason.scheduledWorkout));
    });

    test('evaluate keeps planned workout for fat loss goal on training day',
        () {
      final date = DateTime(2026, 8, 11);
      final decision = rule.evaluate(
        DecisionContext(
          now: date,
          healthProfile: buildTestProfile(goal: FitnessGoal.loseFat),
          trainingProgram: _stubProgram(),
          programProgress: _stubProgress(),
          todayWorkout: _trainingDayWorkout(date),
        ),
      );

      expect(decision.requiresAdaptation, isFalse);
      expect(decision.confidence, 0.95);
    });
  });

  group('NutritionPlanBuilder', () {
    late NutritionPlanBuilder builder;

    setUp(() {
      builder = NutritionPlanBuilder(nutritionEngine: NutritionEngine());
    });

    test('rest and recovery sessions use rest-day calories', () {
      final date = DateTime(2026, 8, 11);
      final profile = buildTestProfile();
      final rest = builder.build(
        context: DecisionContext(
          now: date,
          healthProfile: profile,
          trainingProgram: _stubProgram(),
          programProgress: _stubProgress(),
          todayWorkout: _restDayWorkout(date),
        ),
        finalWorkout: _restDayWorkout(date),
      );
      final recoveryWorkout = TodayWorkout(
        date: date,
        dayKey: 'tuesday',
        plannedExercises: [_stubExercise()],
        finalExercises: [_stubExercise()],
        isRecoverySession: true,
        volumeMultiplier: 0.5,
      );
      final recovery = builder.build(
        context: DecisionContext(
          now: date,
          healthProfile: profile,
          trainingProgram: _stubProgram(),
          programProgress: _stubProgress(),
          todayWorkout: recoveryWorkout,
        ),
        finalWorkout: recoveryWorkout,
      );
      final training = builder.build(
        context: DecisionContext(
          now: date,
          healthProfile: profile,
          trainingProgram: _stubProgram(),
          programProgress: _stubProgress(),
          todayWorkout: _trainingDayWorkout(date),
        ),
        finalWorkout: _trainingDayWorkout(date),
      );

      expect(rest.isTrainingDay, isFalse);
      expect(recovery.isTrainingDay, isFalse);
      expect(rest.dailyCalories, recovery.dailyCalories);
      expect(training.dailyCalories, greaterThan(rest.dailyCalories));
    });

    test('reduced volume scales calories between rest and full training', () {
      final date = DateTime(2026, 8, 11);
      final profile = buildTestProfile();
      final reducedWorkout = TodayWorkout(
        date: date,
        dayKey: 'tuesday',
        plannedExercises: [_stubExercise()],
        finalExercises: [_stubExercise()],
        volumeMultiplier: 0.7,
      );
      final reduced = builder.build(
        context: DecisionContext(
          now: date,
          healthProfile: profile,
          trainingProgram: _stubProgram(),
          programProgress: _stubProgress(),
          todayWorkout: reducedWorkout,
        ),
        finalWorkout: reducedWorkout,
      );
      final full = builder.build(
        context: DecisionContext(
          now: date,
          healthProfile: profile,
          trainingProgram: _stubProgram(),
          programProgress: _stubProgress(),
          todayWorkout: _trainingDayWorkout(date),
        ),
        finalWorkout: _trainingDayWorkout(date),
      );
      final rest = builder.build(
        context: DecisionContext(
          now: date,
          healthProfile: profile,
          trainingProgram: _stubProgram(),
          programProgress: _stubProgress(),
          todayWorkout: _restDayWorkout(date),
        ),
        finalWorkout: _restDayWorkout(date),
      );

      expect(reduced.isTrainingDay, isTrue);
      expect(reduced.dailyCalories, lessThan(full.dailyCalories));
      expect(reduced.dailyCalories, greaterThan(rest.dailyCalories));
    });
  });
}
