// test/engines/workout_engine/selectors/exercise_scorer_test.dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/movement_pattern.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/exercise_difficulty.dart';
import 'package:gymgenius/domain/enums/mechanics.dart';
import 'package:gymgenius/domain/enums/force_type.dart';
import 'package:gymgenius/domain/enums/laterality.dart';
import 'package:gymgenius/domain/enums/plane_of_motion.dart';
import 'package:gymgenius/engines/workout_engine/models/focus_plan.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/selectors/exercise_scorer.dart';
import 'package:gymgenius/engines/workout_engine/selectors/selection_state.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

void main() {
  group('ExerciseScorer', () {
    late ExerciseScorer scorer;
    late SelectionState state;
    late MuscleSplit pushSplit;
    late ExercisePoolEntry benchPress;
    late ExercisePoolEntry pushUp;
    late ExercisePoolEntry tricepsPushdown;

    setUp(() {
      scorer = ExerciseScorer(random: Random(42));
      state = SelectionState();

      pushSplit = const MuscleSplit(
        name: 'Push',
        theme: '',
        muscles: [
          MuscleGroup.chest,
          MuscleGroup.shoulders,
          MuscleGroup.triceps,
          MuscleGroup.absCore,
        ],
        recoveryCost: 2,
        isUpperBody: true,
      );

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

      pushUp = ExercisePoolEntry(
        id: 'push_up',
        name: 'Push Up',
        category: ExerciseCategory.compound,
        difficulty: ExerciseDifficulty.beginner,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: const [MuscleGroup.chest],
        secondaryMuscles: const [MuscleGroup.triceps, MuscleGroup.shoulders],
        movementPattern: MovementPattern.push,
        mechanics: Mechanics.openChain,
        forceType: ForceType.push,
        laterality: Laterality.bilateral,
        planeOfMotion: PlaneOfMotion.sagittal,
        description: 'Push up',
        usesWeight: false,
        isTimed: false,
      );

      tricepsPushdown = ExercisePoolEntry(
        id: 'triceps_pushdown',
        name: 'Triceps Pushdown',
        category: ExerciseCategory.isolation,
        difficulty: ExerciseDifficulty.beginner,
        equipmentType: EquipmentType.cableMachinePulley,
        targetMuscles: const [MuscleGroup.triceps],
        secondaryMuscles: const [],
        movementPattern: MovementPattern.push,
        mechanics: Mechanics.openChain,
        forceType: ForceType.push,
        laterality: Laterality.bilateral,
        planeOfMotion: PlaneOfMotion.sagittal,
        description: 'Triceps pushdown',
        usesWeight: true,
        isTimed: false,
      );
    });

    //----------------------------------------------------------------------
    // Focus quota bonus
    //----------------------------------------------------------------------

    test('missing focus quota increases score', () {
      final plan = FocusPlan(
        quotas: {MuscleGroup.chest: 2},
        reservedExercises: 2,
        secondaryFocusMuscles: const [],
      );
      final value = scorer.score(
        entry: benchPress,
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );
      // Au moins le bonus de deux quotas manquants (2 * 120 = 240)
      expect(value, greaterThanOrEqualTo(240));
    });

    //----------------------------------------------------------------------
    // Quota completed
    //----------------------------------------------------------------------

    test('completed quota removes large bonus', () {
      const quota = 1;
      final plan = FocusPlan(
        quotas: {MuscleGroup.chest: quota},
        reservedExercises: quota,
        secondaryFocusMuscles: const [],
      );

      // État avec le quota déjà couvert
      final coveredState = SelectionState();
      coveredState.add(benchPress);
      final scoreCovered = scorer.score(
        entry: pushUp,
        state: coveredState,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      // État sans le quota couvert
      final emptyState = SelectionState();
      final scoreUncovered = scorer.score(
        entry: pushUp,
        state: emptyState,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      // Le score avec quota couvert doit être inférieur (moins de bonus)
      expect(scoreCovered, lessThan(scoreUncovered));
    });

    //----------------------------------------------------------------------
    // Split fidelity
    //----------------------------------------------------------------------

    test('split exercises receive additional score', () {
      final plan = FocusPlan(
        quotas: {},
        reservedExercises: 0,
        secondaryFocusMuscles: const [],
      );

      final scoreSplit = scorer.score(
        entry: benchPress,
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      final outOfSplitExercise = ExercisePoolEntry(
        id: 'squat',
        name: 'Squat',
        category: ExerciseCategory.compound,
        difficulty: ExerciseDifficulty.intermediate,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: const [MuscleGroup.quadriceps],
        secondaryMuscles: const [],
        movementPattern: MovementPattern.squat,
        mechanics: Mechanics.openChain,
        forceType: ForceType.push,
        laterality: Laterality.bilateral,
        planeOfMotion: PlaneOfMotion.sagittal,
        description: 'Squat',
        usesWeight: false,
        isTimed: false,
      );

      final scoreOutside = scorer.score(
        entry: outOfSplitExercise,
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      expect(scoreSplit, greaterThan(scoreOutside));
    });

    //----------------------------------------------------------------------
    // Compound bonus
    //----------------------------------------------------------------------

    test('compound exercise scores higher than isolation exercise', () {
      const plan = FocusPlan(
        quotas: {},
        reservedExercises: 0,
        secondaryFocusMuscles: [],
      );

      final compoundScore = scorer.score(
        entry: benchPress,
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      final isolationScore = scorer.score(
        entry: tricepsPushdown,
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      expect(compoundScore, greaterThan(isolationScore));
    });

    //----------------------------------------------------------------------
    // Muscle richness
    //----------------------------------------------------------------------

    test('exercise with more primary muscles scores higher', () {
      const plan = FocusPlan(
        quotas: {},
        reservedExercises: 0,
        secondaryFocusMuscles: [],
      );

      final benchScore = scorer.score(
        entry: benchPress, // 2 cibles primaires
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      final pushdownScore = scorer.score(
        entry: tricepsPushdown, // 1 cible primaire
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      expect(benchScore, greaterThan(pushdownScore));
    });

    //----------------------------------------------------------------------
    // Secondary muscles contribute to score
    //----------------------------------------------------------------------

    test('secondary muscles increase score', () {
      const plan = FocusPlan(
        quotas: {},
        reservedExercises: 0,
        secondaryFocusMuscles: [],
      );

      final pushupScore = scorer.score(
        entry: pushUp, // 2 secondaires
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      final pushdownScore = scorer.score(
        entry: tricepsPushdown, // 0 secondaire
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      expect(pushupScore, greaterThan(pushdownScore));
    });

    //----------------------------------------------------------------------
    // Movement diversity
    //----------------------------------------------------------------------

    test('repeated movement pattern receives penalty', () {
      const plan = FocusPlan(
        quotas: {},
        reservedExercises: 0,
        secondaryFocusMuscles: [],
      );

      // Score quand le pattern n'est pas encore utilisé (état vide)
      final scoreWithoutRepeat = scorer.score(
        entry: pushUp,
        state: state, // state est vide
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      // Ajouter un exercice avec le même pattern (push) dans l'état
      state.add(benchPress);

      // Score quand le pattern est déjà présent
      final scoreWithRepeat = scorer.score(
        entry: pushUp,
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      // La pénalité doit réduire le score
      expect(scoreWithRepeat, lessThan(scoreWithoutRepeat));
    });

    //----------------------------------------------------------------------
    // Previous program penalty
    //----------------------------------------------------------------------

    test('exercise already present in previous program receives penalty', () {
      const plan = FocusPlan(
        quotas: {},
        reservedExercises: 0,
        secondaryFocusMuscles: [],
      );

      final penalizedScore = scorer.score(
        entry: benchPress,
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: {'Bench Press'},
      );

      final freshScore = scorer.score(
        entry: benchPress,
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      expect(penalizedScore, lessThan(freshScore));
    });

    //----------------------------------------------------------------------
    // bestCandidate()
    //----------------------------------------------------------------------

    test('bestCandidate returns highest scored exercise', () {
      final plan = FocusPlan(
        quotas: {MuscleGroup.chest: 2},
        reservedExercises: 2,
        secondaryFocusMuscles: const [],
      );

      final candidate = scorer.bestCandidate(
        pool: [tricepsPushdown, pushUp, benchPress],
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      expect(candidate, isNotNull);
      expect(candidate!.entry.name, 'Bench Press');
    });

    //----------------------------------------------------------------------
    // Already selected exercises are ignored
    //----------------------------------------------------------------------

    test('bestCandidate ignores already selected exercises', () {
      state.add(benchPress);

      final plan = FocusPlan(
        quotas: {MuscleGroup.chest: 2},
        reservedExercises: 2,
        secondaryFocusMuscles: const [],
      );

      final candidate = scorer.bestCandidate(
        pool: [benchPress, pushUp],
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      expect(candidate, isNotNull);
      expect(candidate!.entry.name, 'Push Up');
    });

    //----------------------------------------------------------------------
    // Empty pool
    //----------------------------------------------------------------------

    test('bestCandidate returns null for empty pool', () {
      final candidate = scorer.bestCandidate(
        pool: const [],
        state: state,
        split: pushSplit,
        focusPlan: const FocusPlan(
          quotas: {},
          reservedExercises: 0,
          secondaryFocusMuscles: [],
        ),
        previousNames: const {},
      );
      expect(candidate, isNull);
    });

    //----------------------------------------------------------------------
    // Pool exhausted
    //----------------------------------------------------------------------

    test('bestCandidate returns null when every exercise is already selected',
        () {
      state.add(benchPress);
      state.add(pushUp);
      state.add(tricepsPushdown);

      final candidate = scorer.bestCandidate(
        pool: [benchPress, pushUp, tricepsPushdown],
        state: state,
        split: pushSplit,
        focusPlan: const FocusPlan(
          quotas: {},
          reservedExercises: 0,
          secondaryFocusMuscles: [],
        ),
        previousNames: const {},
      );

      expect(candidate, isNull);
    });

    //----------------------------------------------------------------------
    // Previous program should influence selection
    //----------------------------------------------------------------------

    test('bestCandidate avoids previous program when possible', () {
      // On crée un exercice similaire à benchPress mais avec un nom différent
      final similarPress = ExercisePoolEntry(
        id: 'similar_press',
        name: 'Similar Press',
        category: ExerciseCategory.compound,
        difficulty: ExerciseDifficulty.intermediate,
        equipmentType: EquipmentType.dumbbells,
        targetMuscles: const [MuscleGroup.chest, MuscleGroup.triceps],
        secondaryMuscles: const [MuscleGroup.shoulders],
        movementPattern: MovementPattern.push,
        mechanics: Mechanics.openChain,
        forceType: ForceType.push,
        laterality: Laterality.bilateral,
        planeOfMotion: PlaneOfMotion.sagittal,
        description: 'Similar press',
        usesWeight: true,
        isTimed: false,
      );

      final candidate = scorer.bestCandidate(
        pool: [benchPress, similarPress],
        state: state,
        split: pushSplit,
        focusPlan: const FocusPlan(
          quotas: {},
          reservedExercises: 0,
          secondaryFocusMuscles: [],
        ),
        previousNames: {'Bench Press'},
      );

      expect(candidate, isNotNull);
      // Comme benchPress est pénalisé, on s'attend à ce que similarPress soit choisi
      expect(candidate!.entry.name, 'Similar Press');
    });

    //----------------------------------------------------------------------
    // Tie-break prefers compound exercise
    //----------------------------------------------------------------------

    test('tie-break prefers compound exercise', () {
      final isolationChest = ExercisePoolEntry(
        id: 'chest_fly',
        name: 'Chest Fly',
        category: ExerciseCategory.isolation,
        difficulty: ExerciseDifficulty.intermediate,
        equipmentType: EquipmentType.dumbbells,
        targetMuscles: const [MuscleGroup.chest],
        secondaryMuscles: const [],
        movementPattern: MovementPattern.push,
        mechanics: Mechanics.openChain,
        forceType: ForceType.push,
        laterality: Laterality.bilateral,
        planeOfMotion: PlaneOfMotion.sagittal,
        description: 'Chest fly',
        usesWeight: true,
        isTimed: false,
      );

      final candidate = scorer.bestCandidate(
        pool: [isolationChest, benchPress],
        state: state,
        split: pushSplit,
        focusPlan: const FocusPlan(
          quotas: {},
          reservedExercises: 0,
          secondaryFocusMuscles: [],
        ),
        previousNames: const {},
      );

      expect(candidate, isNotNull);
      expect(candidate!.entry.isCompound, isTrue);
    });

    //----------------------------------------------------------------------
    // Secondary focus muscles
    //----------------------------------------------------------------------

    test('secondary focus muscles receive bonus', () {
      final plan = FocusPlan(
        quotas: {MuscleGroup.chest: 1},
        reservedExercises: 1,
        secondaryFocusMuscles: const [
          MuscleGroup.shoulders,
          MuscleGroup.triceps
        ],
      );

      // Exercice ciblant un muscle secondaire (shoulders)
      final shoulderExercise = ExercisePoolEntry(
        id: 'shoulder_press',
        name: 'Shoulder Press',
        category: ExerciseCategory.compound,
        difficulty: ExerciseDifficulty.intermediate,
        equipmentType: EquipmentType.dumbbells,
        targetMuscles: const [MuscleGroup.shoulders],
        secondaryMuscles: const [],
        movementPattern: MovementPattern.push,
        mechanics: Mechanics.openChain,
        forceType: ForceType.push,
        laterality: Laterality.bilateral,
        planeOfMotion: PlaneOfMotion.sagittal,
        description: 'Shoulder press',
        usesWeight: true,
        isTimed: false,
      );

      // Score avec bonus secondaire
      final scoreWithBonus = scorer.score(
        entry: shoulderExercise,
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      // Score sans bonus (un exercice qui cible un muscle non secondaire)
      final outOfFocusExercise = ExercisePoolEntry(
        id: 'leg_curl',
        name: 'Leg Curl',
        category: ExerciseCategory.isolation,
        difficulty: ExerciseDifficulty.beginner,
        equipmentType: EquipmentType.legCurlMachine,
        targetMuscles: const [MuscleGroup.hamstrings],
        secondaryMuscles: const [],
        movementPattern: MovementPattern.pull,
        mechanics: Mechanics.openChain,
        forceType: ForceType.pull,
        laterality: Laterality.bilateral,
        planeOfMotion: PlaneOfMotion.sagittal,
        description: 'Leg curl',
        usesWeight: true,
        isTimed: false,
      );

      final scoreWithoutBonus = scorer.score(
        entry: outOfFocusExercise,
        state: state,
        split: pushSplit,
        focusPlan: plan,
        previousNames: const {},
      );

      expect(scoreWithBonus, greaterThan(scoreWithoutBonus));
    });
  });
}
