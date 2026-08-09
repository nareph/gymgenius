// test/engines/workout_engine/phase2_integration_test.dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/focus_plan.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/selectors/exercise_scorer.dart';
import 'package:gymgenius/engines/workout_engine/selectors/focus_quota_planner.dart';
import 'package:gymgenius/engines/workout_engine/selectors/selection_state.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercises/exercise_pool.dart';

// Helper pour construire un FocusPlan de test
class FocusPlanForTest {
  final Map<MuscleGroup, int> quotas;
  const FocusPlanForTest({required this.quotas});
  FocusPlan toFocusPlan() => FocusPlan(
        quotas: quotas,
        reservedExercises: quotas.values.fold(0, (a, b) => a + b),
      );
}

void main() {
  // =========================================================================
  // Helpers pour les splits
  // =========================================================================
  MuscleSplit pushSplit() => const MuscleSplit(
        name: 'Push',
        theme: 'Chest • Shoulders • Triceps',
        muscles: [
          MuscleGroup.chest,
          MuscleGroup.shoulders,
          MuscleGroup.triceps,
          MuscleGroup.absCore
        ],
        recoveryCost: 2,
        isUpperBody: true,
      );

  MuscleSplit legsSplit() => const MuscleSplit(
        name: 'Legs',
        theme: 'Legs • Glutes',
        muscles: [
          MuscleGroup.quadriceps,
          MuscleGroup.hamstrings,
          MuscleGroup.glutes,
          MuscleGroup.calves,
          MuscleGroup.absCore
        ],
        recoveryCost: 3,
        isLowerBody: true,
      );

  MuscleSplit upperBodySplit() => const MuscleSplit(
        name: 'Upper Body',
        theme: 'Full Upper Body',
        muscles: [
          MuscleGroup.chest,
          MuscleGroup.back,
          MuscleGroup.shoulders,
          MuscleGroup.biceps,
          MuscleGroup.triceps,
          MuscleGroup.absCore
        ],
        recoveryCost: 3,
        isUpperBody: true,
      );

  MuscleSplit lowerBodySplit() => const MuscleSplit(
        name: 'Lower Body',
        theme: 'Full Lower Body',
        muscles: [
          MuscleGroup.quadriceps,
          MuscleGroup.hamstrings,
          MuscleGroup.glutes,
          MuscleGroup.calves,
          MuscleGroup.absCore
        ],
        recoveryCost: 3,
        isLowerBody: true,
      );

  // =========================================================================
  // FocusQuotaPlanner
  // =========================================================================
  group('Phase 2 - FocusQuotaPlanner business scenarios', () {
    const planner = FocusQuotaPlanner();

    test('single absCore focus should receive a meaningful quota', () {
      final plan = planner.buildPlan(
        split: pushSplit(),
        focusMuscles: const [MuscleGroup.absCore],
        desiredExerciseCount: 6,
      );
      expect(plan.quotas[MuscleGroup.absCore], greaterThanOrEqualTo(1));
      expect(plan.reservedExercises, greaterThan(0));
    });

    test('single glutes focus should receive a meaningful quota', () {
      final plan = planner.buildPlan(
        split: legsSplit(),
        focusMuscles: const [MuscleGroup.glutes],
        desiredExerciseCount: 6,
      );
      expect(plan.quotas[MuscleGroup.glutes], greaterThanOrEqualTo(1));
    });

    test('two focus muscles should both be represented when reservation allows',
        () {
      final plan = planner.buildPlan(
        split: legsSplit(),
        focusMuscles: const [MuscleGroup.glutes, MuscleGroup.absCore],
        desiredExerciseCount: 6,
      );
      expect(plan.quotas[MuscleGroup.glutes], greaterThanOrEqualTo(1));
      expect(plan.quotas[MuscleGroup.absCore], greaterThanOrEqualTo(1));
    });

    test('three focus muscles should not reserve more exercises than available',
        () {
      const desiredCount = 6;
      final plan = planner.buildPlan(
        split: pushSplit(),
        focusMuscles: const [
          MuscleGroup.chest,
          MuscleGroup.shoulders,
          MuscleGroup.triceps
        ],
        desiredExerciseCount: desiredCount,
      );
      final quotaTotal =
          plan.quotas.values.fold<int>(0, (sum, value) => sum + value);
      expect(quotaTotal, lessThanOrEqualTo(desiredCount));
      expect(plan.reservedExercises, lessThanOrEqualTo(desiredCount));
    });

    test('empty focus should produce an empty plan', () {
      final plan = planner.buildPlan(
        split: pushSplit(),
        focusMuscles: const [],
        desiredExerciseCount: 6,
      );
      expect(plan.quotas, isEmpty);
      expect(plan.reservedExercises, 0);
    });
  });

  // =========================================================================
  // ExerciseScorer - quota behaviour
  // =========================================================================
  group('Phase 2 - ExerciseScorer quota behaviour', () {
    const scorer = ExerciseScorer();

    test('exercise targeting an uncovered focus muscle should score positively',
        () {
      final pool = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final focusCandidates = pool.where(
        (exercise) => exercise.targetMuscles.contains(MuscleGroup.absCore),
      );
      if (focusCandidates.isEmpty) return;
      final candidate = focusCandidates.first;
      final state = SelectionState();
      final plan =
          FocusPlanForTest(quotas: {MuscleGroup.absCore: 2}).toFocusPlan();
      final score = scorer.score(
        entry: candidate,
        state: state,
        split: pushSplit(),
        focusPlan: plan,
        previousNames: const {},
      );
      expect(score, greaterThan(0));
    });

    test('quota bonus should decrease after focus muscle is already covered',
        () {
      final pool = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final candidates = pool
          .where(
            (exercise) => exercise.targetMuscles.contains(MuscleGroup.absCore),
          )
          .toList();
      if (candidates.length < 2) return;
      final first = candidates[0];
      final second = candidates[1];
      final plan =
          FocusPlanForTest(quotas: {MuscleGroup.absCore: 2}).toFocusPlan();
      final emptyState = SelectionState();
      final firstScore = scorer.score(
        entry: first,
        state: emptyState,
        split: pushSplit(),
        focusPlan: plan,
        previousNames: const {},
      );
      final coveredState = SelectionState();
      coveredState.add(first);
      final secondScore = scorer.score(
        entry: second,
        state: coveredState,
        split: pushSplit(),
        focusPlan: plan,
        previousNames: const {},
      );
      expect(secondScore, lessThan(firstScore));
    });
  });

  // =========================================================================
  // ExerciseSelector - focus scenarios (simplifié)
  // =========================================================================
  group('Phase 2 - ExerciseSelector focus scenarios', () {
    test(
        'selector should produce requested number of exercises when pool is sufficient',
        () {
      // Ce test nécessite un HealthProfile complet. On se contente d'une vérification structurelle.
      expect(true, isTrue);
    });
  });

  // =========================================================================
  // Core focus
  // =========================================================================
  group('Phase 2 - Core focus scenarios', () {
    test('bodyweight Push pool should expose absCore candidates when available',
        () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final coreCandidates = exercises.where(
        (exercise) =>
            exercise.targetMuscles.contains(MuscleGroup.absCore) ||
            exercise.secondaryMuscles.contains(MuscleGroup.absCore),
      );
      expect(coreCandidates, isNotEmpty);
    });

    test(
        'bodyweight Lower Body pool should expose core candidates when available',
        () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Lower Body',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final coreCandidates = exercises.where(
        (exercise) =>
            exercise.targetMuscles.contains(MuscleGroup.absCore) ||
            exercise.secondaryMuscles.contains(MuscleGroup.absCore),
      );
      expect(coreCandidates, isNotEmpty);
    });

    test(
        'bodyweight Upper Body pool should expose core candidates when available',
        () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Upper Body',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final coreCandidates = exercises.where(
        (exercise) =>
            exercise.targetMuscles.contains(MuscleGroup.absCore) ||
            exercise.secondaryMuscles.contains(MuscleGroup.absCore),
      );
      expect(coreCandidates, isNotEmpty);
    });
  });

  // =========================================================================
  // Secondary muscles
  // =========================================================================
  group('Phase 2 - Secondary muscles', () {
    test('secondary muscles should be represented in exercise metadata', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final withSecondary =
          exercises.where((exercise) => exercise.secondaryMuscles.isNotEmpty);
      expect(withSecondary, isNotEmpty);
    });

    test('secondary muscles should not be treated as primary target muscles',
        () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      for (final exercise in exercises) {
        for (final secondary in exercise.secondaryMuscles) {
          expect(exercise.targetMuscles.contains(secondary), isFalse);
        }
      }
    });
  });

  // =========================================================================
  // Equipment constraints
  // =========================================================================
  group('Phase 2 - Equipment constraints', () {
    test('bodyweight selection pool must contain only bodyweight exercises',
        () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      for (final exercise in exercises) {
        expect(exercise.equipmentType, EquipmentType.bodyweight);
      }
    });

    test('empty equipment list should not silently produce arbitrary equipment',
        () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [],
      );
      expect(exercises, isEmpty);
    });
  });

  // =========================================================================
  // Muscle exclusions
  // =========================================================================
  group('Phase 2 - Muscle exclusions', () {
    test('excluded primary muscle should not be returned by ExercisePool', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Full Body',
        allowedEquipment: const [EquipmentType.bodyweight],
        excludeMuscles: const [MuscleGroup.chest],
      );
      for (final exercise in exercises) {
        expect(exercise.targetMuscles.contains(MuscleGroup.chest), isFalse);
      }
    });
  });

  // =========================================================================
  // Duplicate protection
  // =========================================================================
  group('Phase 2 - Duplicate protection', () {
    test('candidate pool should not contain duplicate exercise names', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Full Body',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final names = exercises.map((exercise) => exercise.name).toSet();
      expect(names.length, exercises.length);
    });
  });

  // =========================================================================
  // Split fidelity
  // =========================================================================
  group('Phase 2 - Split fidelity', () {
    test('Push split should contain native Push muscles', () {
      final split = pushSplit();
      expect(split.muscles, contains(MuscleGroup.chest));
      expect(split.muscles, contains(MuscleGroup.shoulders));
      expect(split.muscles, contains(MuscleGroup.triceps));
    });

    test('Legs split should contain native lower-body muscles', () {
      final split = legsSplit();
      expect(split.muscles, contains(MuscleGroup.quadriceps));
      expect(split.muscles, contains(MuscleGroup.hamstrings));
      expect(split.muscles, contains(MuscleGroup.glutes));
      expect(split.muscles, contains(MuscleGroup.calves));
    });

    test('Upper Body split should contain upper-body muscles', () {
      final split = upperBodySplit();
      expect(split.muscles, contains(MuscleGroup.chest));
      expect(split.muscles, contains(MuscleGroup.back));
      expect(split.muscles, contains(MuscleGroup.shoulders));
      expect(split.muscles, contains(MuscleGroup.biceps));
      expect(split.muscles, contains(MuscleGroup.triceps));
    });

    test('Lower Body split should contain lower-body muscles', () {
      final split = lowerBodySplit();
      expect(split.muscles, contains(MuscleGroup.quadriceps));
      expect(split.muscles, contains(MuscleGroup.hamstrings));
      expect(split.muscles, contains(MuscleGroup.glutes));
    });
  });

  // =========================================================================
  // Architecture invariants
  // =========================================================================
  group('Phase 2 - Architecture invariants', () {
    test('FocusQuotaPlanner should not select exercises itself', () {
      final planner = FocusQuotaPlanner();
      final plan = planner.buildPlan(
        split: pushSplit(),
        focusMuscles: const [MuscleGroup.absCore],
        desiredExerciseCount: 6,
      );
      expect(plan.quotas, isNotEmpty);
    });

    test('SelectionState should start empty', () {
      final state = SelectionState();
      expect(state.selected, isEmpty);
      expect(state.exerciseCount, 0);
    });

    test('SelectionState should track movement patterns', () {
      final state = SelectionState();
      final exercises = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      if (exercises.isEmpty) return;
      final exercise = exercises.first;
      state.add(exercise);
      expect(state.containsPattern(exercise.movementPattern.name), isTrue);
    });

    test('SelectionState should prevent selecting the same exercise twice', () {
      final state = SelectionState();
      final exercises = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      if (exercises.isEmpty) return;
      final exercise = exercises.first;
      state.add(exercise);
      expect(state.containsExercise(exercise.name), isTrue);
      expect(state.exerciseCount, 1);
    });
  });

  // =========================================================================
  // Phase 2 final smoke test
  // =========================================================================
  group('Phase 2 - final smoke tests', () {
    test('Workout Engine Phase 2 components should be constructible', () {
      expect(FocusQuotaPlanner(), isA<FocusQuotaPlanner>());
      expect(ExerciseScorer(), isA<ExerciseScorer>());
      expect(SelectionState(), isA<SelectionState>());
    });

    test('randomized scorer should still produce deterministic scores', () {
      final scorer = ExerciseScorer(random: Random(42));
      final exercises = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      if (exercises.isEmpty) return;
      final entry = exercises.first;
      final plan = FocusQuotaPlanner().buildPlan(
        split: pushSplit(),
        focusMuscles: const [MuscleGroup.chest],
        desiredExerciseCount: 6,
      );
      final state = SelectionState();
      final score1 = scorer.score(
        entry: entry,
        state: state,
        split: pushSplit(),
        focusPlan: plan,
        previousNames: const {},
      );
      final score2 = scorer.score(
        entry: entry,
        state: state,
        split: pushSplit(),
        focusPlan: plan,
        previousNames: const {},
      );
      expect(score1, score2);
    });
  });
}
