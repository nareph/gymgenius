// lib/services/ai/generators/local_generator.dart
import 'dart:math';
import 'package:gymgenius/services/ai/types.dart';
import 'package:gymgenius/services/ai/shared/exercise_pool.dart';

/// Local rule-based routine generator for development
/// This is used when AI API is disabled or unavailable
class LocalRoutineGenerator {
  final Random _random = Random();

  static const _daysOfWeek = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday"
  ];

  /// Generate routine locally using rule-based logic
  Map<String, dynamic> generate({
    required OnboardingDataAI onboardingData,
    required List<MuscleSplit> selectedSplit,
    required int workoutDaysCount,
    required bool useSpecifiedDays,
  }) {
    // Determine workout days
    List<String> workoutDays;
    if (useSpecifiedDays && onboardingData.workoutDays != null) {
      workoutDays =
          onboardingData.workoutDays!.map((d) => d.toLowerCase()).toList();
    } else {
      workoutDays = _getDefaultWorkoutDays(workoutDaysCount);
    }

    // Generate daily workouts
    final dailyWorkouts = <String, List<Map<String, dynamic>>>{};

    // Initialize all days with empty arrays
    for (final day in _daysOfWeek) {
      dailyWorkouts[day] = [];
    }

    // Fill in workout days
    for (int i = 0; i < workoutDays.length && i < selectedSplit.length; i++) {
      final day = workoutDays[i];
      final split = selectedSplit[i];

      dailyWorkouts[day] = _generateDailyWorkout(
        split: split,
        sessionDuration: onboardingData.sessionDurationMinutes,
        equipment: onboardingData.equipment,
        experience: onboardingData.experience,
      );
    }

    // Determine duration
    final durationInWeeks = _calculateDuration(
      experience: onboardingData.experience,
      workoutDaysCount: workoutDaysCount,
    );

    // Generate name
    final name = _generateRoutineName(
      workoutDaysCount: workoutDaysCount,
      selectedSplit: selectedSplit,
    );

    return {
      'name': name,
      'durationInWeeks': durationInWeeks,
      'dailyWorkouts': dailyWorkouts,
    };
  }

  List<String> _getDefaultWorkoutDays(int count) {
    switch (count) {
      case 2:
        return ['monday', 'thursday'];
      case 3:
        return ['monday', 'wednesday', 'friday'];
      case 4:
        return ['monday', 'tuesday', 'thursday', 'friday'];
      case 5:
        return ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
      case 6:
        return [
          'monday',
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday'
        ];
      default:
        return ['monday', 'wednesday', 'friday'];
    }
  }

  List<Map<String, dynamic>> _generateDailyWorkout({
    required MuscleSplit split,
    String? sessionDuration,
    List<String>? equipment,
    String? experience,
  }) {
    // Determine exercise count based on session duration
    int exerciseCount = 5; // default
    switch (sessionDuration) {
      case 'short_30_max':
        exerciseCount = 3 + _random.nextInt(2); // 3-4
        break;
      case 'medium_45':
        exerciseCount = 4 + _random.nextInt(2); // 4-5
        break;
      case 'standard_60':
        exerciseCount = 5 + _random.nextInt(2); // 5-6
        break;
      case 'long_75_90':
        exerciseCount = 6 + _random.nextInt(3); // 6-8
        break;
      case 'very_long_90_plus':
        exerciseCount = 7 + _random.nextInt(3); // 7-9
        break;
    }

    final exercises = <Map<String, dynamic>>[];
    final hasEquipment = equipment != null &&
        equipment.isNotEmpty &&
        !equipment.contains('bodyweight');

    for (int i = 0; i < exerciseCount; i++) {
      exercises.add(_generateExercise(
        split: split,
        index: i,
        experience: experience,
        hasEquipment: hasEquipment,
      ));
    }

    return exercises;
  }

  Map<String, dynamic> _generateExercise({
    required MuscleSplit split,
    required int index,
    String? experience,
    bool hasEquipment = false,
  }) {
    // Get exercise pool for this split
    final exercisePool = ExercisePool.getExercises(split.name, hasEquipment);
    final exercise = exercisePool[_random.nextInt(exercisePool.length)];

    // Determine sets based on experience
    final sets = switch (experience?.toLowerCase()) {
      'beginner' => 2 + _random.nextInt(2), // 2-3
      'intermediate' => 3 + _random.nextInt(2), // 3-4
      'advanced' || 'expert' => 4 + _random.nextInt(2), // 4-5
      _ => 3,
    };

    // Determine reps based on experience and exercise type
    final reps = _generateReps(experience, exercise['type'] as String?);

    // Generate description
    final description = _generateDescription(
      exerciseName: exercise['name'] as String,
      muscles: split.muscles,
      splitTheme: split.theme,
    );

    return {
      'name': exercise['name'] as String,
      'sets': sets,
      'reps': reps,
      'weightSuggestionKg': exercise['weight'] ?? 'Bodyweight',
      'restBetweenSetsSeconds': 60 + _random.nextInt(60), // 60-120s
      'description': description,
      'usesWeight': exercise['usesWeight'] as bool? ?? false,
      'isTimed': exercise['isTimed'] as bool? ?? false,
    };
  }

  String _generateReps(String? experience, String? exerciseType) {
    if (exerciseType == 'isolation') {
      return switch (experience?.toLowerCase()) {
        'beginner' => '10-15',
        'intermediate' => '12-15',
        'advanced' || 'expert' => '15-20',
        _ => '10-15',
      };
    } else {
      return switch (experience?.toLowerCase()) {
        'beginner' => '6-8',
        'intermediate' => '8-12',
        'advanced' || 'expert' => '10-15',
        _ => '8-12',
      };
    }
  }

  String _generateDescription({
    required String exerciseName,
    required List<String> muscles,
    required String splitTheme,
  }) {
    final primaryMuscles = muscles.take(3).join(', ');
    return '**Target: $primaryMuscles | Split: $splitTheme**\n\n'
        '1. Position yourself correctly for $exerciseName.\n'
        '2. Engage your core and maintain proper posture.\n'
        '3. Execute the movement with control, focusing on the target muscles.\n'
        '4. Complete the full range of motion.\n'
        '5. Return to starting position with control.';
  }

  int _calculateDuration({
    String? experience,
    int workoutDaysCount = 3,
  }) {
    final baseDuration = switch (experience?.toLowerCase()) {
      'beginner' => 6,
      'intermediate' => 8,
      'advanced' || 'expert' => 10,
      _ => 6,
    };

    return baseDuration + _random.nextInt(3) - 1; // ±1 week variation
  }

  String _generateRoutineName({
    required int workoutDaysCount,
    required List<MuscleSplit> selectedSplit,
  }) {
    final splitNames =
        selectedSplit.map((s) => s.name).take(workoutDaysCount).toList();
    final joinedNames = splitNames.join('/');

    final prefixes = ['Progressive', 'Complete', 'Ultimate', 'Dynamic'];
    final prefix = prefixes[_random.nextInt(prefixes.length)];

    return '$prefix $workoutDaysCount-Day $joinedNames Split';
  }
}
