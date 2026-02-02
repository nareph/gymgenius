// lib/services/ai/shared/exercise_pool.dart
import 'package:gymgenius/services/ai/shared/types.dart';

/// Centralized exercise pool for workout generation
class ExercisePool {
  /// Get exercises for a specific muscle split
  static List<Map<String, dynamic>> getExercises(
    String splitName,
    bool hasEquipment,
  ) {
    final pool = _exercisePools[splitName] ?? _exercisePools['Push']!;

    return pool
        .where((exercise) => !hasEquipment ? !exercise.usesWeight : true)
        .map((e) => e.toMap())
        .toList();
  }

  /// All exercise pools organized by split type
  static final Map<String, List<ExercisePoolEntry>> _exercisePools = {
    'Push': [
      const ExercisePoolEntry(
        name: 'Push-ups',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Pike Push-ups',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Diamond Push-ups',
        type: 'isolation',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Tricep Dips',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Decline Push-ups',
        type: 'compound',
        usesWeight: false,
      ),
      // Equipment-based exercises
      const ExercisePoolEntry(
        name: 'Bench Press',
        type: 'compound',
        weight: 'Moderate',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Shoulder Press',
        type: 'compound',
        weight: 'Light',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Lateral Raises',
        type: 'isolation',
        weight: 'Light',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Tricep Extensions',
        type: 'isolation',
        weight: 'Light',
        usesWeight: true,
      ),
    ],
    'Pull': [
      const ExercisePoolEntry(
        name: 'Pull-ups',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Chin-ups',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Inverted Rows',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Superman Holds',
        type: 'isolation',
        usesWeight: false,
        isTimed: true,
      ),
      // Equipment-based
      const ExercisePoolEntry(
        name: 'Barbell Rows',
        type: 'compound',
        weight: 'Moderate',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Lat Pulldowns',
        type: 'compound',
        weight: 'Moderate',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Bicep Curls',
        type: 'isolation',
        weight: 'Light',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Face Pulls',
        type: 'isolation',
        weight: 'Light',
        usesWeight: true,
      ),
    ],
    'Legs': [
      const ExercisePoolEntry(
        name: 'Bodyweight Squats',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Lunges',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Bulgarian Split Squats',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Calf Raises',
        type: 'isolation',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Glute Bridges',
        type: 'isolation',
        usesWeight: false,
      ),
      // Equipment-based
      const ExercisePoolEntry(
        name: 'Barbell Squats',
        type: 'compound',
        weight: 'Heavy',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Deadlifts',
        type: 'compound',
        weight: 'Heavy',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Leg Press',
        type: 'compound',
        weight: 'Heavy',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Leg Curls',
        type: 'isolation',
        weight: 'Moderate',
        usesWeight: true,
      ),
    ],
    'Chest & Triceps': [
      const ExercisePoolEntry(
        name: 'Push-ups',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Decline Push-ups',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Tricep Dips',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Diamond Push-ups',
        type: 'isolation',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Bench Press',
        type: 'compound',
        weight: 'Moderate',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Incline Dumbbell Press',
        type: 'compound',
        weight: 'Moderate',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Cable Flyes',
        type: 'isolation',
        weight: 'Light',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Tricep Extensions',
        type: 'isolation',
        weight: 'Light',
        usesWeight: true,
      ),
    ],
    'Back & Biceps': [
      const ExercisePoolEntry(
        name: 'Pull-ups',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Inverted Rows',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Barbell Rows',
        type: 'compound',
        weight: 'Moderate',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Lat Pulldowns',
        type: 'compound',
        weight: 'Moderate',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Bicep Curls',
        type: 'isolation',
        weight: 'Light',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Hammer Curls',
        type: 'isolation',
        weight: 'Light',
        usesWeight: true,
      ),
    ],
    'Shoulders & Core': [
      const ExercisePoolEntry(
        name: 'Pike Push-ups',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Plank',
        type: 'isolation',
        usesWeight: false,
        isTimed: true,
      ),
      const ExercisePoolEntry(
        name: 'Side Plank',
        type: 'isolation',
        usesWeight: false,
        isTimed: true,
      ),
      const ExercisePoolEntry(
        name: 'Mountain Climbers',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Shoulder Press',
        type: 'compound',
        weight: 'Light',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Lateral Raises',
        type: 'isolation',
        weight: 'Light',
        usesWeight: true,
      ),
      const ExercisePoolEntry(
        name: 'Front Raises',
        type: 'isolation',
        weight: 'Light',
        usesWeight: true,
      ),
    ],
    'Upper Body': [
      const ExercisePoolEntry(
        name: 'Push-ups',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Pull-ups',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Dips',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Pike Push-ups',
        type: 'compound',
        usesWeight: false,
      ),
    ],
    'Lower Body': [
      const ExercisePoolEntry(
        name: 'Squats',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Lunges',
        type: 'compound',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Glute Bridges',
        type: 'isolation',
        usesWeight: false,
      ),
      const ExercisePoolEntry(
        name: 'Calf Raises',
        type: 'isolation',
        usesWeight: false,
      ),
    ],
  };
}
