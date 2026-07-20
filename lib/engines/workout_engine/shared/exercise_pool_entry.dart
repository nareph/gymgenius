// lib/engines/workout_engine/shared/exercise_pool_entry.dart

enum EquipmentType {
  bodyweight,
  barbell,
  dumbbell,
  kettlebell,
  resistanceBand,
  cable,
  machine,
  pullUpBar,
  bench,
}

enum ExerciseCategory {
  compound,
  isolation,
}

class ExercisePoolEntry {
  final String name;
  final ExerciseCategory category;
  final EquipmentType equipmentType;
  final List<String> targetMuscles; // e.g., ['chest', 'triceps', 'shoulders']
  final String?
      weightSuggestion; // 'Light', 'Moderate', 'Heavy', or null for bodyweight
  final bool usesWeight;
  final bool isTimed;
  final String description; // Detailed description with steps

  const ExercisePoolEntry({
    required this.name,
    required this.category,
    required this.equipmentType,
    required this.targetMuscles,
    this.weightSuggestion,
    this.usesWeight = false,
    this.isTimed = false,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': category.name,
      'equipmentType': equipmentType.name,
      'targetMuscles': targetMuscles,
      if (weightSuggestion != null) 'weightSuggestion': weightSuggestion,
      'usesWeight': usesWeight,
      'isTimed': isTimed,
      'description': description,
    };
  }
}
