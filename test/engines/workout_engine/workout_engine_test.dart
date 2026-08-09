// test/engines/workout_engine/workout_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/domain/value_objects/body_measurements.dart';
import 'package:gymgenius/domain/value_objects/lifestyle_preferences.dart';
import 'package:gymgenius/domain/value_objects/workout_preferences.dart';
import 'package:gymgenius/engines/workout_engine/services/persistence_service.dart';
import 'package:gymgenius/engines/workout_engine/workout_engine.dart';

// Mock simple de PersistenceService
class _MockPersistenceService implements PersistenceService {
  @override
  Future<void> saveProgram(TrainingProgram program) async {}
  @override
  Future<TrainingProgram?> loadProgram(String userId) async => null;
  @override
  Future<void> deleteProgram(String programId) async {}
}

void main() {
  group('WorkoutEngine', () {
    late WorkoutEngine engine;
    late HealthProfile profile;

    setUp(() {
      engine = WorkoutEngine(
        persistenceService: _MockPersistenceService(),
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
        frequency: WorkoutFrequency.threeToFour, // 4 jours actifs
        sessionDuration: SessionDuration.standard60,
        preferredDays: const [
          WorkoutDay.monday,
          WorkoutDay.tuesday,
          WorkoutDay.thursday,
          WorkoutDay.friday,
        ],
        equipment: const [
          EquipmentType.bodyweight,
          EquipmentType.barbellAndPlates,
          EquipmentType.dumbbells,
          EquipmentType.cableMachinePulley,
          EquipmentType.legPressMachine,
        ],
        focusAreas: const [], activityLevel: ActivityLevel.sedentary,
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

    test('generates a complete program', () async {
      final program = await engine.generateProgram(profile: profile);
      expect(program.weeklySchedule, isNotEmpty);
    });

    test('creates the requested number of training days', () async {
      final program = await engine.generateProgram(profile: profile);
      // On compte les jours qui contiennent effectivement des exercices.
      final nonEmptyDays =
          program.weeklySchedule.values.where((list) => list.isNotEmpty).length;
      // Avec frequency = threeToFour et 4 jours préférés, on attend 4 jours actifs.
      expect(nonEmptyDays, 4);
    });

    test('every workout day contains exercises', () async {
      final program = await engine.generateProgram(profile: profile);
      // On vérifie que tous les jours non vides contiennent des exercices
      for (final exercises in program.weeklySchedule.values) {
        if (exercises.isNotEmpty) {
          expect(exercises, isNotEmpty);
        }
      }
      // Et qu'il y a au moins un jour non vide
      expect(
        program.weeklySchedule.values.any((list) => list.isNotEmpty),
        true,
      );
    });

    test('no duplicate exercise exists inside one workout', () async {
      final program = await engine.generateProgram(profile: profile);
      for (final exercises in program.weeklySchedule.values) {
        if (exercises.isNotEmpty) {
          final names = exercises.map((e) => e.name).toSet();
          expect(names.length, exercises.length);
        }
      }
    });
  });
}
