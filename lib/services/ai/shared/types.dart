// lib/services/ai/shared/types.dart

/// Exercise pool entry
class ExercisePoolEntry {
  final String name;
  final String type; // compound, isolation
  final String? weight; // Bodyweight, Light, Moderate, Heavy
  final bool usesWeight;
  final bool isTimed;

  const ExercisePoolEntry({
    required this.name,
    required this.type,
    this.weight,
    this.usesWeight = false,
    this.isTimed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      if (weight != null) 'weight': weight,
      'usesWeight': usesWeight,
      'isTimed': isTimed,
    };
  }
}

/// Constants used across AI generation
class AIConstants {
  static const daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static const sessionDurations = {
    'short_30_max': 30,
    'medium_45': 45,
    'standard_60': 60,
    'long_75_90': 75,
    'very_long_90_plus': 90,
  };

  static Map<int, List<String>> getDefaultWorkoutDays(int count) {
    return {
      2: ['monday', 'thursday'],
      3: ['monday', 'wednesday', 'friday'],
      4: ['monday', 'tuesday', 'thursday', 'friday'],
      5: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      6: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'],
    };
  }
}
