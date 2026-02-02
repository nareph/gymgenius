// lib/services/ai/types.dart

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
  final List<String>? regenerationInstructions; // Ajouté

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
    this.regenerationInstructions, // Ajouté
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
    List<String>? regenerationInstructions, // Ajouté
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
          regenerationInstructions ?? this.regenerationInstructions, // Ajouté
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
          (map['regeneration_instructions'] as List<dynamic>?)
              ?.cast<String>(), // Ajouté
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

  toMap() {
    return {
      'age': age,
      'weightKg': weightKg,
      'heightM': heightM,
      'targetWeightKg': targetWeightKg,
    };
  }
}

class MuscleSplit {
  final String name;
  final List<String> muscles;
  final String theme;

  MuscleSplit({
    required this.name,
    required this.muscles,
    required this.theme,
  });
}

class AiExercise {
  final String name;
  final int sets;
  final String reps;
  final String? weightSuggestionKg;
  final int? restBetweenSetsSeconds;
  final String description;
  final bool? usesWeight;
  final bool? isTimed;
  final int? targetDurationSeconds;

  AiExercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weightSuggestionKg,
    this.restBetweenSetsSeconds,
    required this.description,
    this.usesWeight,
    this.isTimed,
    this.targetDurationSeconds,
  });

  factory AiExercise.fromMap(Map<String, dynamic> map) {
    return AiExercise(
      name: map['name'] as String,
      sets: map['sets'] as int,
      reps: map['reps'] as String,
      weightSuggestionKg: map['weightSuggestionKg'] as String?,
      restBetweenSetsSeconds: map['restBetweenSetsSeconds'] as int?,
      description: map['description'] as String,
      usesWeight: map['usesWeight'] as bool?,
      isTimed: map['isTimed'] as bool?,
      targetDurationSeconds: map['targetDurationSeconds'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weightSuggestionKg': weightSuggestionKg,
      'restBetweenSetsSeconds': restBetweenSetsSeconds,
      'description': description,
      'usesWeight': usesWeight,
      'isTimed': isTimed,
      'targetDurationSeconds': targetDurationSeconds,
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
