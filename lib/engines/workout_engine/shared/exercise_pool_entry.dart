import '../../../domain/enums/exports.dart';

class ExercisePoolEntry {
  /// Unique identifier.
  final String id;

  /// Exercise name.
  final String name;

  /// Compound / Isolation.
  final ExerciseCategory category;

  /// Beginner / Intermediate / Advanced.
  final ExerciseDifficulty difficulty;

  /// Required equipment.
  final EquipmentType equipmentType;

  /// Main muscles.
  final List<MuscleGroup> targetMuscles;

  /// Secondary muscles.
  final List<MuscleGroup> secondaryMuscles;

  /// Splits in which this exercise can be used.
  ///
  /// This is applicability metadata, not a second exercise definition.
  /// One canonical exercise may belong to multiple splits.
  final Set<String> compatibleSplits;

  /// Suggested weight.
  final String? weightSuggestion;

  /// Uses external weight.
  final bool usesWeight;

  /// Timed exercise.
  final bool isTimed;

  /// Movement information.
  final MovementPattern movementPattern;
  final Mechanics mechanics;
  final ForceType forceType;
  final Laterality laterality;
  final PlaneOfMotion planeOfMotion;

  /// Coach description.
  final String description;

  const ExercisePoolEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.equipmentType,
    required this.targetMuscles,
    this.secondaryMuscles = const [],
    this.compatibleSplits = const {},
    this.weightSuggestion,
    this.usesWeight = false,
    this.isTimed = false,
    required this.movementPattern,
    required this.mechanics,
    required this.forceType,
    required this.laterality,
    required this.planeOfMotion,
    required this.description,
  });

  bool get isCompound => category == ExerciseCategory.compound;

  bool get isIsolation => category == ExerciseCategory.isolation;

  /// Returns true when this exercise can be used for the given split.
  bool isCompatibleWithSplit(String splitName) {
    return compatibleSplits.contains(splitName);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': category.name,
      'difficulty': difficulty.name,
      'equipmentType': equipmentType.name,
      'targetMuscles': targetMuscles.map((e) => e.name).toList(),
      'secondaryMuscles': secondaryMuscles.map((e) => e.name).toList(),
      'compatibleSplits': compatibleSplits.toList(),
      if (weightSuggestion != null) 'weightSuggestion': weightSuggestion,
      'usesWeight': usesWeight,
      'isTimed': isTimed,
      'movementPattern': movementPattern.name,
      'mechanics': mechanics.name,
      'forceType': forceType.name,
      'laterality': laterality.name,
      'planeOfMotion': planeOfMotion.name,
      'description': description,
    };
  }
}
