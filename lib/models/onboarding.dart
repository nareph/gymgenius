// lib/models/onboarding.dart

// --- Helper Function ---
// This private helper function safely parses a dynamic value into a number (int or double).
// It can handle values that are already numbers, strings, or null.
T? _parseNum<T extends num>(dynamic value) {
  if (value == null) return null;
  if (value is T) return value; // Already the correct type.

  // Try to parse from a String.
  if (value is String) {
    if (value.trim().isEmpty) return null; // Don't parse empty strings.
    if (T == int) return int.tryParse(value) as T?;
    if (T == double) return double.tryParse(value) as T?;
    return num.tryParse(value) as T?;
  }

  // Handle cases where the number is of a different numeric type (e.g., int to double).
  if (value is num) {
    if (T == int) return value.toInt() as T?;
    if (T == double) return value.toDouble() as T?;
    return value as T?;
  }

  // Return null if the type is unexpected.
  return null;
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

  /// Factory constructor to create a PhysicalStats instance from a map.
  /// It defensively parses numeric values that might be stored as strings.
  factory PhysicalStats.fromMap(Map<String, dynamic> map) {
    return PhysicalStats(
      // --- FIX APPLIED HERE ---
      // Use the safe parsing helper for all numeric fields.
      age: _parseNum<int>(map['age']),
      weightKg: _parseNum<double>(map['weight_kg']),
      heightM: _parseNum<double>(map['height_m']),
      targetWeightKg: _parseNum<double>(map['target_weight_kg']),
    );
  }

  /// Converts the PhysicalStats instance to a map for Firestore/caching.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (age != null) map['age'] = age;
    if (weightKg != null) map['weight_kg'] = weightKg;
    if (heightM != null) map['height_m'] = heightM;
    if (targetWeightKg != null) map['target_weight_kg'] = targetWeightKg;
    return map;
  }

  /// Checks if the core stats required for AI generation are present.
  bool get isSufficientForAi {
    return age != null && weightKg != null && heightM != null;
  }

  /// Checks if any stat has been set.
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
  final String? sessionDurationPreference;
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
    this.sessionDurationPreference,
    this.workoutDays,
    this.equipment,
    this.focusAreas,
    this.physicalStats,
    this.completed = false,
  });

  /// Checks if all data required for AI routine generation is available.
  bool get isSufficientForAiGeneration {
    final bool allRequiredFieldsPresent = goal != null &&
        goal!.isNotEmpty &&
        gender != null &&
        gender!.isNotEmpty &&
        experience != null &&
        experience!.isNotEmpty &&
        frequency != null &&
        frequency!.isNotEmpty &&
        sessionDurationPreference != null &&
        sessionDurationPreference!.isNotEmpty &&
        workoutDays != null &&
        workoutDays!.isNotEmpty &&
        equipment != null &&
        equipment!.isNotEmpty &&
        physicalStats != null &&
        physicalStats!.isSufficientForAi;

    return allRequiredFieldsPresent;
  }

  /// Factory constructor to create OnboardingData from a map.
  factory OnboardingData.fromMap(Map<String, dynamic> map) {
    return OnboardingData(
      goal: map['goal'] as String?,
      gender: map['gender'] as String?,
      experience: map['experience'] as String?,
      frequency: map['frequency'] as String?,
      sessionDurationPreference: map['session_duration_minutes'] as String?,
      workoutDays: map['workout_days'] != null
          ? List<String>.from(map['workout_days'] as List<dynamic>)
          : null,
      equipment: map['equipment'] != null
          ? List<String>.from(map['equipment'] as List<dynamic>)
          : null,
      focusAreas: map['focus_areas'] != null
          ? List<String>.from(map['focus_areas'] as List<dynamic>)
          : null,
      // This part is now safer because PhysicalStats.fromMap handles type issues.
      physicalStats: map['physical_stats'] != null &&
              (map['physical_stats'] is Map) &&
              (map['physical_stats'] as Map).isNotEmpty
          ? PhysicalStats.fromMap(map['physical_stats'] as Map<String, dynamic>)
          : null,
      completed: map['completed'] as bool? ?? false,
    );
  }

  /// Converts the OnboardingData instance to a map.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (goal != null) map['goal'] = goal;
    if (gender != null) map['gender'] = gender;
    if (experience != null) map['experience'] = experience;
    if (frequency != null) map['frequency'] = frequency;
    if (sessionDurationPreference != null) {
      map['session_duration_minutes'] = sessionDurationPreference;
    }
    if (workoutDays != null && workoutDays!.isNotEmpty) {
      map['workout_days'] = workoutDays;
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

  /// Creates a copy of the instance with updated fields.
  OnboardingData copyWith({
    String? goal,
    String? gender,
    String? experience,
    String? frequency,
    String? sessionDurationPreference,
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
      sessionDurationPreference:
          sessionDurationPreference ?? this.sessionDurationPreference,
      workoutDays: workoutDays ?? this.workoutDays,
      equipment: equipment ?? this.equipment,
      focusAreas: focusAreas ?? this.focusAreas,
      physicalStats: physicalStats ?? this.physicalStats,
      completed: completed ?? this.completed,
    );
  }
}
