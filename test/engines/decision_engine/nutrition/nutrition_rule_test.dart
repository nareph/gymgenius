import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/exercise_difficulty.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/force_type.dart';
import 'package:gymgenius/domain/enums/laterality.dart';
import 'package:gymgenius/domain/enums/mechanics.dart';
import 'package:gymgenius/domain/enums/movement_pattern.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/plane_of_motion.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';
import 'package:gymgenius/engines/decision_engine/models/decision_context.dart';
import 'package:gymgenius/engines/decision_engine/rules/nutrition/nutrition_plan_builder.dart';
import 'package:gymgenius/engines/decision_engine/rules/nutrition/nutrition_rule.dart';
import 'package:gymgenius/engines/nutrition_engine/nutrition_engine.dart';

import '../../nutrition_engine/calorie_macro_test.dart';

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
          trainingProgram: throw UnimplementedError(),
          programProgress: throw UnimplementedError(),
          todayWorkout: _restDayWorkout(date),
        ),
      );

      expect(decision.requiresAdaptation, isFalse);
      expect(decision.adjustment, WorkoutAdjustment.none);
      expect(decision.reasons, contains(DecisionReason.scheduledWorkout));
    });

    test('evaluate keeps planned workout for fat loss goal on training day', () {
      final date = DateTime(2026, 8, 11);
      final decision = rule.evaluate(
        DecisionContext(
          now: date,
          healthProfile: buildTestProfile(goal: FitnessGoal.loseFat),
          trainingProgram: throw UnimplementedError(),
          programProgress: throw UnimplementedError(),
          todayWorkout: _trainingDayWorkout(date),
        ),
      );

      expect(decision.requiresAdaptation, isFalse);
      expect(decision.confidence, 0.95);
    });
  });
}
