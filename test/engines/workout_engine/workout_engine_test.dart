import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/models/workout_profile.dart';
import 'package:gymgenius/engines/workout_engine/split_generator.dart';
import 'package:gymgenius/engines/workout_engine/workout_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplitGenerator', () {
    test('returns 3-day PPL split for 3 workout days', () {
      final split = SplitGenerator.determineMuscleSplit(3, 'beginner');

      expect(split.length, 3);
      expect(split.map((s) => s.name).toList(), ['Push', 'Pull', 'Legs']);
    });

    test('caps beginners at 4-day split for 5+ days', () {
      final split = SplitGenerator.determineMuscleSplit(5, 'beginner');

      expect(split.length, 4);
      expect(split.first.name, 'Chest & Triceps');
    });

    test('allows 5-day split for intermediate users', () {
      final split = SplitGenerator.determineMuscleSplit(5, 'intermediate');

      expect(split.length, 5);
      expect(split.map((s) => s.name).toList(), [
        'Chest',
        'Back',
        'Legs',
        'Arms',
        'Shoulders & Core',
      ]);
    });

    test('calculateWorkoutDays respects preferred days within frequency', () {
      final result = SplitGenerator.calculateWorkoutDays(
        frequency: '3-5',
        preferredDays: ['monday', 'wednesday', 'friday'],
      );

      expect(result.count, 3);
      expect(result.useSpecifiedDays, isTrue);
    });

    test('calculateWorkoutDays defaults to 3 when no frequency given', () {
      final result = SplitGenerator.calculateWorkoutDays();

      expect(result.count, 3);
      expect(result.useSpecifiedDays, isFalse);
    });
  });

  group('WorkoutEngine', () {
    late WorkoutEngine engine;

    setUp(() {
      engine = WorkoutEngine(seed: 42);
    });

    test('generateTrainingProgram produces valid program structure', () {
      const profile = WorkoutProfile(
        experience: 'beginner',
        frequency: '3-5',
        sessionDuration: 'standard_60',
        equipment: ['bodyweight'],
      );

      const split = [
        MuscleSplit(
          name: 'Push',
          muscles: ['Chest', 'Shoulders', 'Triceps'],
          theme: 'Push Day',
        ),
        MuscleSplit(
          name: 'Pull',
          muscles: ['Back', 'Biceps'],
          theme: 'Pull Day',
        ),
        MuscleSplit(
          name: 'Legs',
          muscles: ['Quadriceps', 'Hamstrings'],
          theme: 'Leg Day',
        ),
      ];

      final program = engine.generateTrainingProgram(
        profile: profile,
        selectedSplit: split,
        workoutDaysCount: 3,
        useSpecifiedDays: false,
      );

      expect(program['name'], isNotEmpty);
      expect(program['durationInWeeks'], isA<int>());
      expect(program['weeklySchedule'], isA<Map<String, dynamic>>());

      final schedule = program['weeklySchedule'] as Map<String, dynamic>;
      final mondayExercises = schedule['monday'] as List;
      expect(mondayExercises, isNotEmpty);

      final firstExercise = mondayExercises.first as Map<String, dynamic>;
      expect(firstExercise['name'], isNotEmpty);
      expect(firstExercise['sets'], isA<int>());
      expect(firstExercise['reps'], isNotEmpty);
      expect(firstExercise['usesWeight'], isA<bool>());
      expect(firstExercise['isTimed'], isA<bool>());
    });

    test('validateAndNormalize detects timed exercises from reps', () {
      // Utilisation du nouveau format 'weeklySchedule'
      final normalized = engine.validateAndNormalize({
        'name': 'Test Program',
        'durationInWeeks': 4,
        'weeklySchedule': {
          'monday': [
            {
              'name': 'Plank',
              'sets': 3,
              'reps': '45s',
              'description': 'Hold plank',
            },
          ],
        },
      });

      final schedule = normalized['weeklySchedule'] as Map;
      final exercises = schedule['monday'] as List<dynamic>;
      final plank = exercises.first as Map<String, dynamic>;

      expect(plank['isTimed'], isTrue);
      expect(plank['targetDurationSeconds'], 45);
      expect(plank['usesWeight'], isFalse);
    });

    test('validateAndNormalize handles rep-based exercises', () {
      final normalized = engine.validateAndNormalize({
        'name': 'Test Program',
        'durationInWeeks': 4,
        'weeklySchedule': {
          'monday': [
            {
              'name': 'Bench Press',
              'sets': 4,
              'reps': '8-12',
              'weightSuggestionKg': '60',
            },
          ],
        },
      });

      final schedule = normalized['weeklySchedule'] as Map;
      final exercises = schedule['monday'] as List<dynamic>;
      final bench = exercises.first as Map<String, dynamic>;

      expect(bench['isTimed'], isFalse);
      expect(bench['usesWeight'], isTrue);
      expect(bench.containsKey('targetDurationSeconds'), isFalse);
    });
  });
}
