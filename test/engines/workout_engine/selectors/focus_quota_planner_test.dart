// test/engines/workout_engine/selectors/focus_quota_planner_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/selectors/focus_quota_planner.dart';

void main() {
  group('FocusQuotaPlanner', () {
    const planner = FocusQuotaPlanner();

    const push = MuscleSplit(
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

    const pull = MuscleSplit(
      name: 'Pull',
      theme: '',
      muscles: [
        MuscleGroup.back,
        MuscleGroup.biceps,
        MuscleGroup.forearms,
      ],
      recoveryCost: 2,
      isUpperBody: true,
    );

    test('returns empty plan when no focus muscles', () {
      final plan = planner.buildPlan(
        split: push,
        focusMuscles: const [],
        desiredExerciseCount: 6,
      );

      expect(plan.quotas, isEmpty);
      expect(plan.reservedExercises, 0);
    });

    test('single focus reserves two exercises in a 6 exercise workout', () {
      final plan = planner.buildPlan(
        split: push,
        focusMuscles: const [
          MuscleGroup.chest,
        ],
        desiredExerciseCount: 6,
      );

      expect(
        plan.quotas[MuscleGroup.chest] ?? 0,
        2,
      );

      expect(plan.reservedExercises, 2);
    });

    test('single focus reserves only one exercise in a 4 exercise workout', () {
      final plan = planner.buildPlan(
        split: push,
        focusMuscles: const [
          MuscleGroup.chest,
        ],
        desiredExerciseCount: 4,
      );

      expect(
        plan.quotas[MuscleGroup.chest] ?? 0,
        1,
      );

      expect(plan.reservedExercises, 1);
    });

    test('two compatible focuses split reserved exercises equally', () {
      final plan = planner.buildPlan(
        split: push,
        focusMuscles: const [
          MuscleGroup.chest,
          MuscleGroup.shoulders,
        ],
        desiredExerciseCount: 6,
      );

      expect(
        plan.quotas[MuscleGroup.chest] ?? 0,
        1,
      );

      expect(
        plan.quotas[MuscleGroup.shoulders] ?? 0,
        1,
      );

      expect(plan.reservedExercises, 2);
    });

    test('native focus muscles receive priority when quota is limited', () {
      final plan = planner.buildPlan(
        split: push,
        focusMuscles: const [
          MuscleGroup.chest,
          MuscleGroup.back,
          MuscleGroup.shoulders,
        ],
        desiredExerciseCount: 6,
      );

      expect(plan.reservedExercises, 2);

      expect(
        plan.quotas[MuscleGroup.chest] ?? 0,
        greaterThan(0),
      );

      expect(
        plan.quotas[MuscleGroup.shoulders] ?? 0,
        greaterThan(0),
      );

      expect(
        plan.quotas[MuscleGroup.back] ?? 0,
        0,
      );
    });

    test('non-native focus does not create an out-of-split quota', () {
      final plan = planner.buildPlan(
        split: push,
        focusMuscles: const [
          MuscleGroup.chest,
          MuscleGroup.back,
        ],
        desiredExerciseCount: 7,
      );

      expect(
        plan.quotas[MuscleGroup.back] ?? 0,
        0,
      );

      expect(
        plan.quotas[MuscleGroup.chest] ?? 0,
        greaterThan(0),
      );

      expect(
        plan.reservedExercises,
        plan.quotas.values.fold<int>(
          0,
          (sum, value) => sum + value,
        ),
      );
    });

    test('never reserves more than three exercises', () {
      final plan = planner.buildPlan(
        split: push,
        focusMuscles: const [
          MuscleGroup.chest,
        ],
        desiredExerciseCount: 12,
      );

      expect(
        plan.reservedExercises,
        3,
      );

      expect(
        plan.quotas[MuscleGroup.chest] ?? 0,
        3,
      );
    });

    test('pull split prioritizes native muscles over non-native chest', () {
      final plan = planner.buildPlan(
        split: pull,
        focusMuscles: const [
          MuscleGroup.back,
          MuscleGroup.chest,
          MuscleGroup.biceps,
        ],
        desiredExerciseCount: 6,
      );

      expect(
        plan.quotas[MuscleGroup.back] ?? 0,
        greaterThan(0),
      );

      expect(
        plan.quotas[MuscleGroup.biceps] ?? 0,
        greaterThanOrEqualTo(0),
      );

      expect(
        plan.quotas[MuscleGroup.chest] ?? 0,
        0,
      );
    });

    test('reservedExercises equals total allocated quotas', () {
      final plan = planner.buildPlan(
        split: push,
        focusMuscles: const [
          MuscleGroup.chest,
          MuscleGroup.shoulders,
        ],
        desiredExerciseCount: 6,
      );

      final totalQuota = plan.quotas.values.fold<int>(
        0,
        (sum, value) => sum + value,
      );

      expect(
        plan.reservedExercises,
        totalQuota,
      );
    });

    test('secondary focus muscles belong to the split', () {
      final plan = planner.buildPlan(
        split: push,
        focusMuscles: const [
          MuscleGroup.chest,
        ],
        desiredExerciseCount: 6,
      );

      for (final muscle in plan.secondaryFocusMuscles) {
        expect(
          push.targets(muscle),
          isTrue,
        );
      }
    });

    test('primary focus muscles are never duplicated as secondary focus', () {
      final plan = planner.buildPlan(
        split: push,
        focusMuscles: const [
          MuscleGroup.chest,
          MuscleGroup.shoulders,
        ],
        desiredExerciseCount: 6,
      );

      for (final muscle in plan.quotas.keys) {
        expect(
          plan.secondaryFocusMuscles.contains(muscle),
          isFalse,
        );
      }
    });

    test('push split keeps triceps as secondary focus', () {
      final plan = planner.buildPlan(
        split: push,
        focusMuscles: const [
          MuscleGroup.chest,
        ],
        desiredExerciseCount: 6,
      );

      expect(
        plan.secondaryFocusMuscles,
        contains(MuscleGroup.triceps),
      );
    });

    test('full body exposes remaining muscles as secondary focus', () {
      const fullBody = MuscleSplit(
        name: 'Full Body',
        theme: '',
        muscles: [
          MuscleGroup.chest,
          MuscleGroup.back,
          MuscleGroup.shoulders,
          MuscleGroup.biceps,
          MuscleGroup.triceps,
          MuscleGroup.quadriceps,
          MuscleGroup.hamstrings,
          MuscleGroup.glutes,
          MuscleGroup.calves,
          MuscleGroup.absCore,
        ],
        recoveryCost: 4,
        isFullBody: true,
      );

      final plan = planner.buildPlan(
        split: fullBody,
        focusMuscles: const [
          MuscleGroup.chest,
        ],
        desiredExerciseCount: 6,
      );

      expect(
        plan.secondaryFocusMuscles,
        containsAll(
          [
            MuscleGroup.back,
            MuscleGroup.quadriceps,
            MuscleGroup.absCore,
          ],
        ),
      );
    });

    test('reserved exercises never exceed desired exercise count', () {
      final plan = planner.buildPlan(
        split: push,
        focusMuscles: const [
          MuscleGroup.chest,
        ],
        desiredExerciseCount: 5,
      );

      expect(
        plan.reservedExercises,
        lessThanOrEqualTo(5),
      );
    });
  });
}
