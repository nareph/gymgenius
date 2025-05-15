// lib/models/onboarding.dart

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
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      heightM: (map['height_m'] as num?)?.toDouble(),
      targetWeightKg: (map['target_weight_kg'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (age != null) map['age'] = age;
    if (weightKg != null) map['weight_kg'] = weightKg;
    if (heightM != null) map['height_m'] = heightM;
    if (targetWeightKg != null) map['target_weight_kg'] = targetWeightKg;
    return map;
  }

  bool get isSufficientForAi {
    return age != null && weightKg != null && heightM != null;
  }

  bool get isNotEmpty =>
      age != null ||
      weightKg != null ||
      heightM != null ||
      targetWeightKg != null;
}

class OnboardingData {
  final String? goal;
  final String? gender;
  final String? experience;
  final String? frequency;
  final String?
      sessionDurationPreference; // <<--- CHAMP AJOUTÉ (correspond à l'ID "session_duration_minutes")
  final List<String>? workoutDays;
  final List<String>? equipment;
  final List<String>? focusAreas;
  final PhysicalStats? physicalStats;
  final bool completed;

  OnboardingData({
    this.goal,
    this.gender,
    this.experience,
    this.frequency,
    this.sessionDurationPreference, // <<--- AJOUTÉ AU CONSTRUCTEUR
    this.workoutDays,
    this.equipment,
    this.focusAreas,
    this.physicalStats,
    this.completed = false,
  });

  bool get isSufficientForAiGeneration {
    // Tous les champs sont requis, sauf focusAreas.
    // Pour physicalStats, nous vérifions si l'objet existe ET s'il est suffisant pour l'IA.
    final bool allRequiredFieldsPresent = goal != null &&
        goal!.isNotEmpty &&
        gender != null &&
        gender!.isNotEmpty &&
        experience != null &&
        experience!.isNotEmpty &&
        frequency != null &&
        frequency!.isNotEmpty &&
        sessionDurationPreference != null && // <<--- VÉRIFICATION AJOUTÉE
        sessionDurationPreference!.isNotEmpty &&
        workoutDays != null &&
        workoutDays!.isNotEmpty &&
        equipment != null &&
        equipment!.isNotEmpty &&
        physicalStats != null &&
        physicalStats!.isSufficientForAi;

    return allRequiredFieldsPresent;
  }

  factory OnboardingData.fromMap(Map<String, dynamic> map) {
    return OnboardingData(
      goal: map['goal'] as String?,
      gender: map['gender'] as String?,
      experience: map['experience'] as String?,
      frequency: map['frequency'] as String?,
      sessionDurationPreference: map['session_duration_minutes']
          as String?, // <<--- AJOUTÉ (utilise l'ID de la question)
      workoutDays: map['workout_days'] != null
          ? List<String>.from(map['workout_days'] as List<dynamic>)
          : null,
      equipment: map['equipment'] != null
          ? List<String>.from(map['equipment'] as List<dynamic>)
          : null,
      focusAreas: map['focus_areas'] != null
          ? List<String>.from(map['focus_areas'] as List<dynamic>)
          : null,
      physicalStats: map['physical_stats'] != null &&
              (map['physical_stats'] is Map) && // Vérification plus sûre
              (map['physical_stats'] as Map).isNotEmpty
          ? PhysicalStats.fromMap(map['physical_stats'] as Map<String, dynamic>)
          : null,
      completed: map['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (goal != null) map['goal'] = goal;
    if (gender != null) map['gender'] = gender;
    if (experience != null) map['experience'] = experience;
    if (frequency != null) map['frequency'] = frequency;
    if (sessionDurationPreference != null)
      map['session_duration_minutes'] =
          sessionDurationPreference; // <<--- AJOUTÉ (utilise l'ID de la question)
    if (workoutDays != null && workoutDays!.isNotEmpty) {
      map['workout_days'] =
          workoutDays; // Assurez-vous que la clé ici est "workout_days"
    }
    if (equipment != null && equipment!.isNotEmpty) {
      map['equipment'] = equipment;
    }
    if (focusAreas != null && focusAreas!.isNotEmpty) {
      map['focus_areas'] = focusAreas;
    }
    if (physicalStats != null && physicalStats!.isNotEmpty) {
      map['physical_stats'] = physicalStats!.toMap();
    }
    map['completed'] = completed;
    return map;
  }

  OnboardingData copyWith({
    String? goal,
    String? gender,
    String? experience,
    String? frequency,
    String? sessionDurationPreference, // <<--- AJOUTÉ
    List<String>? workoutDays,
    List<String>? equipment,
    List<String>? focusAreas,
    PhysicalStats? physicalStats,
    bool? completed,
  }) {
    return OnboardingData(
      goal: goal ?? this.goal,
      gender: gender ?? this.gender,
      experience: experience ?? this.experience,
      frequency: frequency ?? this.frequency,
      sessionDurationPreference: sessionDurationPreference ??
          this.sessionDurationPreference, // <<--- AJOUTÉ
      workoutDays: workoutDays ?? this.workoutDays,
      equipment: equipment ?? this.equipment,
      focusAreas: focusAreas ?? this.focusAreas,
      physicalStats: physicalStats ?? this.physicalStats,
      completed: completed ?? this.completed,
    );
  }
}
