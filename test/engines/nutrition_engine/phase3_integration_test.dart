import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
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
import 'package:gymgenius/domain/enums/split_type.dart';
import 'package:gymgenius/engines/decision_engine/Progression/program_progress_service.dart';
import 'package:gymgenius/engines/decision_engine/builders/today_workout_builder.dart';
import 'package:gymgenius/engines/decision_engine/decision_engine.dart';
import 'package:gymgenius/engines/decision_engine/rules/decision_rule.dart';
import 'package:gymgenius/engines/decision_engine/services/conflict_resolver.dart';
import 'package:gymgenius/engines/decision_engine/services/deload_service.dart';
import 'package:gymgenius/engines/decision_engine/services/exercise_substitution_service.dart';
import 'package:gymgenius/engines/decision_engine/services/intensity_adjustment_service.dart';
import 'package:gymgenius/engines/decision_engine/services/recovery_session_service.dart';
import 'package:gymgenius/engines/decision_engine/services/volume_adjustment_service.dart';
import 'package:gymgenius/engines/decision_engine/services/workout_adaptation_service.dart';
import 'package:gymgenius/engines/nutrition_engine/nutrition_engine.dart';
import 'package:gymgenius/engines/workout_engine/providers/exercise_replacement_provider.dart';

import 'calorie_macro_test.dart';

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

TrainingProgram _stubProgram({required DateTime now}) {
  final dayNames = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
  final todayKey = dayNames[now.weekday - 1];

  return TrainingProgram(
    id: 'prog-1',
    userId: 'user-1',
    name: 'Test Program',
    goal: FitnessGoal.buildMuscle,
    split: SplitType.pushPullLegs,
    experience: ExperienceLevel.intermediate,
    durationWeeks: 4,
    weeklySchedule: {
      todayKey: [_stubExercise()],
      for (final day in dayNames)
        if (day != todayKey) day: <Exercise>[],
    },
    generatorType: GeneratorType.local,
    generatorVersion: 'test',
    createdAt: now.subtract(const Duration(days: 1)),
    expiresAt: now.add(const Duration(days: 28)),
  );
}

void main() {
  group('NutritionEngine integration', () {
    test('Cameroon profile yields coherent training-day plan', () {
      final engine = NutritionEngine();
      final profile = buildTestProfile(
        country: 'Cameroon',
        goal: FitnessGoal.buildMuscle,
      );

      final plan = engine.computeDailyPlanSync(
        profile: profile,
        isTrainingDay: true,
        date: DateTime(2026, 8, 11),
      );

      expect(plan.country, 'Cameroon');
      expect(plan.dailyCalories, inInclusiveRange(1800, 4500));
      expect(plan.proteinG, greaterThan(100));
      expect(plan.meals, isNotEmpty);
      expect(plan.meals.every((m) => m.ingredients.isNotEmpty), isTrue);
      expect(plan.reasons, isNotEmpty);
      expect(plan.isTrainingDay, isTrue);
    });

    test('restrictions remove conflicting meals', () {
      final engine = NutritionEngine();
      final profile = buildTestProfile(
        country: 'Cameroon',
        restrictions: const ['fish', 'peanut'],
      );

      final plan = engine.computeDailyPlanSync(
        profile: profile,
        isTrainingDay: false,
        date: DateTime(2026, 8, 11),
      );

      for (final meal in plan.meals) {
        final blob = '${meal.name} ${meal.ingredients.join(' ')}'.toLowerCase();
        expect(blob.contains('fish'), isFalse);
        expect(blob.contains('ndolé'), isFalse);
        expect(blob.contains('groundnut'), isFalse);
      }
    });
  });

  group('DecisionEngine + NutritionPlan', () {
    late DecisionEngine engine;

    setUp(() {
      engine = DecisionEngine(
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
        nutritionEngine: NutritionEngine(),
        rules: const <DecisionRule>[],
      );
    });

    test('DailyPlan.nutritionPlan is non-null for complete profile', () {
      final now = DateTime(2026, 8, 11); // Tuesday
      final profile = buildTestProfile();
      final program = _stubProgram(now: now);

      final dailyPlan = engine.buildDailyPlan(program, profile, now: now);

      expect(dailyPlan.nutritionPlan, isNotNull);
      expect(dailyPlan.nutritionPlan!.userId, profile.userId);
      expect(dailyPlan.nutritionPlan!.meals, isNotEmpty);
      expect(dailyPlan.nutritionPlan!.dailyCalories, greaterThan(1200));
      expect(dailyPlan.hasNutrition, isTrue);
    });
  });
}
