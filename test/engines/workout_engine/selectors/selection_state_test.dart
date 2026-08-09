// test/engines/workout_engine/selectors/selection_state_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/enums/movement_pattern.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/exercise_difficulty.dart';
import 'package:gymgenius/domain/enums/mechanics.dart';
import 'package:gymgenius/domain/enums/force_type.dart';
import 'package:gymgenius/domain/enums/laterality.dart';
import 'package:gymgenius/domain/enums/plane_of_motion.dart';
import 'package:gymgenius/engines/workout_engine/selectors/selection_state.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

void main() {
  group('SelectionState', () {
    late SelectionState state;
    late ExercisePoolEntry benchPress;
    late ExercisePoolEntry inclinePress;

    setUp(() {
      state = SelectionState();

      benchPress = ExercisePoolEntry(
        id: 'bench_press',
        name: 'Bench Press',
        category: ExerciseCategory.compound,
        difficulty: ExerciseDifficulty.intermediate,
        equipmentType: EquipmentType.barbellAndPlates,
        targetMuscles: const [MuscleGroup.chest, MuscleGroup.triceps],
        secondaryMuscles: const [MuscleGroup.shoulders],
        movementPattern: MovementPattern.push,
        mechanics: Mechanics.openChain,
        forceType: ForceType.push,
        laterality: Laterality.bilateral,
        planeOfMotion: PlaneOfMotion.sagittal,
        description: 'Bench press',
        usesWeight: true,
        isTimed: false,
      );

      inclinePress = ExercisePoolEntry(
        id: 'incline_bench_press',
        name: 'Incline Bench Press',
        category: ExerciseCategory.compound,
        difficulty: ExerciseDifficulty.intermediate,
        equipmentType: EquipmentType.barbellAndPlates,
        targetMuscles: const [MuscleGroup.chest],
        secondaryMuscles: const [MuscleGroup.shoulders],
        movementPattern: MovementPattern.push,
        mechanics: Mechanics.openChain,
        forceType: ForceType.push,
        laterality: Laterality.bilateral,
        planeOfMotion: PlaneOfMotion.sagittal,
        description: 'Incline bench press',
        usesWeight: true,
        isTimed: false,
      );
    });

    //----------------------------------------------------------------------
    // Initial state
    //----------------------------------------------------------------------

    test('starts empty', () {
      expect(state.selected, isEmpty);
      expect(state.exerciseCount, 0);
      // Vérifier qu'aucun exercice ni pattern n'est enregistré
      expect(state.containsExercise('Bench Press'), false);
      expect(state.containsPattern('push'), false);
    });

    //----------------------------------------------------------------------
    // add()
    //----------------------------------------------------------------------

    test('adding an exercise updates selected list', () {
      state.add(benchPress);
      expect(state.selected.length, 1);
      expect(state.selected.first.name, 'Bench Press');
    });

    //----------------------------------------------------------------------
    // used names
    //----------------------------------------------------------------------

    test('containsExercise becomes true after add', () {
      expect(state.containsExercise('Bench Press'), false);
      state.add(benchPress);
      expect(state.containsExercise('Bench Press'), true);
    });

    //----------------------------------------------------------------------
    // movement pattern
    //----------------------------------------------------------------------

    test('movement pattern is registered', () {
      expect(state.containsPattern('push'), false);
      state.add(benchPress);
      expect(state.containsPattern('push'), true);
    });

    //----------------------------------------------------------------------
    // coverageCount()
    //----------------------------------------------------------------------

    test('coverageCount counts targeted muscles correctly', () {
      state.add(benchPress);
      expect(state.coverageCount(MuscleGroup.chest), 1);
      expect(state.coverageCount(MuscleGroup.triceps), 1);
      expect(state.coverageCount(MuscleGroup.back), 0);
    });

    //----------------------------------------------------------------------
    // coversMuscle()
    //----------------------------------------------------------------------

    test('coversMuscle returns true only for covered muscles', () {
      state.add(benchPress);
      expect(state.coversMuscle(MuscleGroup.chest), isTrue);
      expect(state.coversMuscle(MuscleGroup.triceps), isTrue);
      expect(state.coversMuscle(MuscleGroup.back), isFalse);
    });

    //----------------------------------------------------------------------
    // coverage increments
    //----------------------------------------------------------------------

    test('coverageCount increments when multiple exercises hit same muscle',
        () {
      state.add(benchPress);
      state.add(inclinePress);
      expect(state.coverageCount(MuscleGroup.chest), 2);
      expect(state.coverageCount(MuscleGroup.triceps), 1);
    });

    //----------------------------------------------------------------------
    // isComplete()
    //----------------------------------------------------------------------

    test('isComplete returns true only after desired exercise count', () {
      expect(state.isComplete(2), isFalse);
      state.add(benchPress);
      expect(state.isComplete(2), isFalse);
      state.add(inclinePress);
      expect(state.isComplete(2), isTrue);
    });

    //----------------------------------------------------------------------
    // clear()
    //----------------------------------------------------------------------

    test('clear resets the entire state', () {
      state.add(benchPress);
      state.add(inclinePress);

      // Vérifie que l'état n'est pas vide
      expect(state.selected, isNotEmpty);
      expect(state.exerciseCount, 2);
      expect(state.containsExercise('Bench Press'), true);
      expect(state.containsPattern('push'), true);

      state.clear();

      // Tout est réinitialisé
      expect(state.selected, isEmpty);
      expect(state.exerciseCount, 0);
      expect(state.containsExercise('Bench Press'), false);
      expect(state.containsPattern('push'), false);
      expect(state.coverageCount(MuscleGroup.chest), 0);
      expect(state.coverageCount(MuscleGroup.triceps), 0);
    });

    //----------------------------------------------------------------------
    // duplicate protection
    //----------------------------------------------------------------------

    test('containsExercise detects existing exercises', () {
      state.add(benchPress);
      expect(state.containsExercise('Bench Press'), isTrue);
      expect(state.containsExercise('Squat'), isFalse);
    });
  });
}
