// test/engines/workout_engine/selectors/exercise_selector_test.dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/domain/value_objects/body_measurements.dart';
import 'package:gymgenius/domain/value_objects/lifestyle_preferences.dart';
import 'package:gymgenius/domain/value_objects/workout_preferences.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/selectors/exercise_selector.dart';

void main() {
  group('ExerciseSelector', () {
    late ExerciseSelector selector;
    late MuscleSplit pushSplit;
    late HealthProfile profile;

    setUp(() {
      selector = ExerciseSelector(random: Random(42));
      pushSplit = const MuscleSplit(
        name: 'Push',
        theme: '',
        muscles: [
          MuscleGroup.chest,
          MuscleGroup.shoulders,
          MuscleGroup.triceps,
          MuscleGroup.absCore
        ],
        recoveryCost: 2,
        isUpperBody: true,
      );

      final body = BodyMeasurements(
        gender: Gender.male,
        age: 25,
        heightCm: 180,
        currentWeightKg: 80,
        targetWeightKg: 82,
      );
      final training = WorkoutPreferences(
        goal: FitnessGoal.buildMuscle,
        experience: ExperienceLevel.intermediate,
        frequency: WorkoutFrequency.threeToFour,
        sessionDuration: SessionDuration.standard60,
        preferredDays: const [],
        equipment: const [
          EquipmentType.bodyweight,
          EquipmentType.barbellAndPlates,
          EquipmentType.dumbbells
        ],
        focusAreas: const [],
        activityLevel: ActivityLevel.sedentary,
      );
      final lifestyle = LifestylePreferences(
        country: 'FR',
        budget: BudgetLevel.medium,
      );
      profile = HealthProfile(
        userId: 'test_user',
        body: body,
        training: training,
        lifestyle: lifestyle,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        answeredQuestionIds: const [],
      );
    });

    test('returns desired number of exercises', () {
      final exercises = selector.select(
        split: pushSplit,
        profile: profile,
        desiredCount: 5,
      );
      expect(exercises.length, 5);
    });

    test('never selects duplicate exercises', () {
      final exercises = selector.select(
        split: pushSplit,
        profile: profile,
        desiredCount: 6,
      );
      final names = exercises.map((e) => e.name).toSet();
      expect(names.length, exercises.length);
    });

    test('respects available equipment', () {
      final exercises = selector.select(
        split: pushSplit,
        profile: profile,
        desiredCount: 6,
      );
      expect(
        exercises
            .every((e) => profile.training.equipment.contains(e.equipmentType)),
        isTrue,
      );
    });

    test('bodyweight-only profile still generates workout', () {
      final bodyweightTraining = profile.training.copyWith(
        equipment: const [EquipmentType.bodyweight],
      );
      final bodyweightProfile = profile.copyWith(training: bodyweightTraining);
      final exercises = selector.select(
        split: pushSplit,
        profile: bodyweightProfile,
        desiredCount: 5,
      );
      expect(exercises, isNotEmpty);
      expect(
          exercises.every((e) => e.equipmentType == EquipmentType.bodyweight),
          isTrue);
    });

    test('focus muscle appears in workout', () {
      final focusedTraining = profile.training.copyWith(
        focusAreas: const [MuscleGroup.chest],
      );
      final focusedProfile = profile.copyWith(training: focusedTraining);
      final exercises = selector.select(
        split: pushSplit,
        profile: focusedProfile,
        desiredCount: 6,
      );
      final chestExercises = exercises.where(
        (e) => e.targetMuscles.contains(MuscleGroup.chest),
      );
      expect(chestExercises.length, greaterThanOrEqualTo(2));
    });

    test('multiple focus muscles are represented', () {
      final focusedTraining = profile.training.copyWith(
        focusAreas: const [MuscleGroup.chest, MuscleGroup.triceps],
      );
      final focusedProfile = profile.copyWith(training: focusedTraining);
      final exercises = selector.select(
        split: pushSplit,
        profile: focusedProfile,
        desiredCount: 6,
      );
      expect(
        exercises.any((e) => e.targetMuscles.contains(MuscleGroup.chest)),
        isTrue,
      );
      expect(
        exercises.any((e) => e.targetMuscles.contains(MuscleGroup.triceps)),
        isTrue,
      );
    });

    test('focus does not eliminate split muscles', () {
      final focusedTraining = profile.training.copyWith(
        focusAreas: const [MuscleGroup.chest],
      );
      final focusedProfile = profile.copyWith(training: focusedTraining);
      final exercises = selector.select(
        split: pushSplit,
        profile: focusedProfile,
        desiredCount: 6,
      );
      expect(
        exercises.any((e) => e.targetMuscles.contains(MuscleGroup.shoulders)),
        isTrue,
      );
      expect(
        exercises.any((e) => e.targetMuscles.contains(MuscleGroup.triceps)),
        isTrue,
      );
    });

    test('profile avoided muscles are never selected', () {
      final restricted = profile.copyWith(
        training: profile.training.copyWith(
          avoidedMuscles: const [MuscleGroup.triceps],
        ),
      );
      final exercises = selector.select(
        split: pushSplit,
        profile: restricted,
        desiredCount: 6,
      );
      expect(
        exercises.every((e) => !e.targetMuscles.contains(MuscleGroup.triceps)),
        isTrue,
      );
    });

    test('excluded muscles are never selected', () {
      final exercises = selector.select(
        split: pushSplit,
        profile: profile,
        desiredCount: 6,
        excludeMuscles: const [MuscleGroup.triceps],
      );
      expect(
        exercises.every((e) => !e.targetMuscles.contains(MuscleGroup.triceps)),
        isTrue,
      );
    });

    test('returns fewer exercises when pool is exhausted', () {
      final bodyweightProfile = profile.copyWith(
        training: profile.training.copyWith(
          equipment: const [EquipmentType.bodyweight],
        ),
      );
      final exercises = selector.select(
        split: pushSplit,
        profile: bodyweightProfile,
        desiredCount: 20,
      );
      expect(exercises.length, lessThanOrEqualTo(20));
    });

    test('never returns more than desired count', () {
      final exercises = selector.select(
        split: pushSplit,
        profile: profile,
        desiredCount: 5,
      );
      expect(exercises.length, lessThanOrEqualTo(5));
    });
  });
}
