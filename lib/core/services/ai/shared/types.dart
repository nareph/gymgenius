export 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';

/// AI-specific onboarding data (converted from HealthProfile)
class OnboardingDataAI {
  final String? goal;
  final String? gender;
  final String? experience;
  final String? frequency;
  final String? sessionDurationMinutes;
  final List<String>? workoutDays;
  final List<String>? equipment;
  final List<String>? focusAreas;
  final PhysicalStats? physicalStats;
  final List<String>? regenerationInstructions;

  OnboardingDataAI({
    this.goal,
    this.gender,
    this.experience,
    this.frequency,
    this.sessionDurationMinutes,
    this.workoutDays,
    this.equipment,
    this.focusAreas,
    this.physicalStats,
    this.regenerationInstructions,
  });

  OnboardingDataAI copyWith({
    String? goal,
    String? gender,
    String? experience,
    String? frequency,
    String? sessionDurationMinutes,
    List<String>? workoutDays,
    List<String>? equipment,
    List<String>? focusAreas,
    PhysicalStats? physicalStats,
    List<String>? regenerationInstructions,
  }) {
    return OnboardingDataAI(
      goal: goal ?? this.goal,
      gender: gender ?? this.gender,
      experience: experience ?? this.experience,
      frequency: frequency ?? this.frequency,
      sessionDurationMinutes:
          sessionDurationMinutes ?? this.sessionDurationMinutes,
      workoutDays: workoutDays ?? this.workoutDays,
      equipment: equipment ?? this.equipment,
      focusAreas: focusAreas ?? this.focusAreas,
      physicalStats: physicalStats ?? this.physicalStats,
      regenerationInstructions:
          regenerationInstructions ?? this.regenerationInstructions,
    );
  }

  factory OnboardingDataAI.fromMap(Map<String, dynamic> map) {
    return OnboardingDataAI(
      goal: map['goal'] as String?,
      gender: map['gender'] as String?,
      experience: map['experience'] as String?,
      frequency: map['frequency'] as String?,
      sessionDurationMinutes: map['session_duration_minutes'] as String?,
      workoutDays: (map['workout_days'] as List<dynamic>?)?.cast<String>(),
      equipment: (map['equipment'] as List<dynamic>?)?.cast<String>(),
      focusAreas: (map['focus_areas'] as List<dynamic>?)?.cast<String>(),
      physicalStats: map['physical_stats'] != null
          ? PhysicalStats.fromMap(map['physical_stats'])
          : null,
      regenerationInstructions:
          (map['regeneration_instructions'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'goal': goal,
      'gender': gender,
      'experience': experience,
      'frequency': frequency,
      'session_duration_minutes': sessionDurationMinutes,
      'workout_days': workoutDays,
      'equipment': equipment,
      'focus_areas': focusAreas,
      'physical_stats': physicalStats?.toMap(),
      if (regenerationInstructions != null)
        'regeneration_instructions': regenerationInstructions,
    };
  }
}

class PhysicalStats {
  final int? age;
  final double? weightKg;
  final double? heightM;
  final double? targetWeightKg;

  PhysicalStats({
    this.age,
    this.weightKg,
    this.heightM,
    this.targetWeightKg,
  });

  factory PhysicalStats.fromMap(Map<String, dynamic> map) {
    return PhysicalStats(
      age: map['age'] as int?,
      weightKg: map['weight_kg'] as double?,
      heightM: map['height_m'] as double?,
      targetWeightKg: map['target_weight_kg'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'weight_kg': weightKg,
      'height_m': heightM,
      'target_weight_kg': targetWeightKg,
    };
  }
}

class AggregatedPerformanceData {
  final String exerciseName;
  final double? averageReps;
  final double? maxWeightLiftedKg;
  final double? completedRate;
  final String? targetReps;
  final String? targetWeight;

  AggregatedPerformanceData({
    required this.exerciseName,
    this.averageReps,
    this.maxWeightLiftedKg,
    this.completedRate,
    this.targetReps,
    this.targetWeight,
  });
}

/// Exercise pool entry for AI generation
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

  static List<String> defaultWorkoutDays(int count) {
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
}
