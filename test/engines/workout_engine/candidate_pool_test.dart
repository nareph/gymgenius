// test/engines/workout_engine/candidate_pool_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercises/exercise_pool.dart';

void main() {
  group('Workout Engine - candidate pool integration', () {
    test('bodyweight pool should contain exercises for Push', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      expect(exercises, isNotEmpty);
      for (final exercise in exercises) {
        expect(exercise.equipmentType, EquipmentType.bodyweight);
      }
    });

    test('bodyweight Legs pool should contain only bodyweight exercises', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Legs',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      expect(exercises, isNotEmpty);
      for (final exercise in exercises) {
        expect(exercise.equipmentType, EquipmentType.bodyweight);
      }
    });

    test('bodyweight Upper Body pool should contain only bodyweight exercises',
        () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Upper Body',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      expect(exercises, isNotEmpty);
      for (final exercise in exercises) {
        expect(exercise.equipmentType, EquipmentType.bodyweight);
      }
    });

    test('bodyweight Lower Body pool should contain only bodyweight exercises',
        () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Lower Body',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      expect(exercises, isNotEmpty);
      for (final exercise in exercises) {
        expect(exercise.equipmentType, EquipmentType.bodyweight);
      }
    });
  });

  group('Workout Engine - focus muscle pool validation', () {
    test('Abs core exercises should exist in the Full Body split', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Full Body',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final coreExercises = exercises.where(
        (exercise) => exercise.targetMuscles.contains(MuscleGroup.absCore),
      );
      expect(coreExercises, isNotEmpty);
    });

    test('core exercises should expose absCore as a target or secondary muscle',
        () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Full Body',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final relevant = exercises.where(
        (exercise) =>
            exercise.targetMuscles.contains(MuscleGroup.absCore) ||
            exercise.secondaryMuscles.contains(MuscleGroup.absCore),
      );
      expect(relevant, isNotEmpty);
    });

    test('focus muscle should not be confused with equipment filtering', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [EquipmentType.bodyweight],
        focusMuscles: const [MuscleGroup.absCore],
      );
      expect(exercises, isNotEmpty);
      // focusMuscles est doux, pas d'exigence stricte
    });
  });

  group('Workout Engine - excluded muscles', () {
    test('excluded muscles should never appear in target muscles', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Full Body',
        allowedEquipment: const [EquipmentType.bodyweight],
        excludeMuscles: const [MuscleGroup.chest],
      );
      for (final exercise in exercises) {
        expect(exercise.targetMuscles.contains(MuscleGroup.chest), isFalse);
      }
    });

    test('multiple excluded muscles should be respected', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Full Body',
        allowedEquipment: const [EquipmentType.bodyweight],
        excludeMuscles: const [MuscleGroup.chest, MuscleGroup.shoulders],
      );
      for (final exercise in exercises) {
        expect(exercise.targetMuscles.contains(MuscleGroup.chest), isFalse);
        expect(exercise.targetMuscles.contains(MuscleGroup.shoulders), isFalse);
      }
    });
  });

  group('Workout Engine - exercise pool integrity', () {
    test('Push pool should not contain duplicate exercise names', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final seen = <String>{};
      for (final exercise in exercises) {
        expect(seen.contains(exercise.name), isFalse,
            reason:
                'Duplicate exercise "${exercise.name}" found in Push pool.');
        seen.add(exercise.name);
      }
      // Optionnel : vérifier que le compte est cohérent
      expect(seen.length, exercises.length);
    });

    test('Full Body pool should not contain duplicate exercise names', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Full Body',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final seen = <String>{};
      for (final exercise in exercises) {
        expect(seen.contains(exercise.name), isFalse,
            reason:
                'Duplicate exercise "${exercise.name}" found in Full Body pool.');
        seen.add(exercise.name);
      }
      expect(seen.length, exercises.length);
    });

    test('Upper Body pool should not contain duplicate exercise names', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Upper Body',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final seen = <String>{};
      for (final exercise in exercises) {
        expect(seen.contains(exercise.name), isFalse,
            reason:
                'Duplicate exercise "${exercise.name}" found in Upper Body pool.');
        seen.add(exercise.name);
      }
      expect(seen.length, exercises.length);
    });

    test('Lower Body pool should not contain duplicate exercise names', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Lower Body',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final seen = <String>{};
      for (final exercise in exercises) {
        expect(seen.contains(exercise.name), isFalse,
            reason:
                'Duplicate exercise "${exercise.name}" found in Lower Body pool.');
        seen.add(exercise.name);
      }
      expect(seen.length, exercises.length);
    });
  });

  group('Workout Engine - split integrity', () {
    const splitNames = [
      'Push',
      'Pull',
      'Legs',
      'Chest',
      'Back',
      'Arms',
      'Chest & Triceps',
      'Back & Biceps',
      'Shoulders & Core',
      'Upper Body',
      'Lower Body',
      'Full Body'
    ];

    for (final splitName in splitNames) {
      test('$splitName should have a bodyweight candidate pool', () {
        final exercises = ExercisePool.getExercises(
          splitName: splitName,
          allowedEquipment: const [EquipmentType.bodyweight],
        );
        expect(exercises, isNotEmpty);
      });
    }
  });

  group('Workout Engine - Core integration', () {
    test('Push pool may contain core exercises', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Push',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final coreCount = exercises
          .where(
            (exercise) => exercise.targetMuscles.contains(MuscleGroup.absCore),
          )
          .length;
      expect(coreCount, greaterThanOrEqualTo(0));
    });

    test('Lower Body pool may contain core exercises', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Lower Body',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final coreCount = exercises
          .where(
            (exercise) => exercise.targetMuscles.contains(MuscleGroup.absCore),
          )
          .length;
      expect(coreCount, greaterThanOrEqualTo(0));
    });

    test('Upper Body pool may contain core exercises', () {
      final exercises = ExercisePool.getExercises(
        splitName: 'Upper Body',
        allowedEquipment: const [EquipmentType.bodyweight],
      );
      final coreCount = exercises
          .where(
            (exercise) => exercise.targetMuscles.contains(MuscleGroup.absCore),
          )
          .length;
      expect(coreCount, greaterThanOrEqualTo(0));
    });
  });
}
