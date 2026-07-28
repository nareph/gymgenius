// lib/domain/entities/exercise.dart

import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/movement_pattern.dart';
import 'package:gymgenius/domain/enums/exercise_difficulty.dart';
import 'package:gymgenius/domain/enums/mechanics.dart';
import 'package:gymgenius/domain/enums/force_type.dart';
import 'package:gymgenius/domain/enums/laterality.dart';
import 'package:gymgenius/domain/enums/plane_of_motion.dart';
import 'package:gymgenius/domain/value_objects/tempo.dart';

/// Domain Entity representing a complete exercise.
///
/// This rich model is used by:
/// - WorkoutEngine (exercise selection, progression)
/// - ProgressEngine (strength tracking, volume analysis)
/// - DecisionEngine (recommendations)
/// - AI Coach (explanations, tips)
class Exercise {
  // Identity & Naming
  final String id;
  final String name;
  final String description;

  // Biomechanical Classification
  final ExerciseCategory category;
  final MovementPattern movementPattern;
  final List<MuscleGroup> primaryMuscles;
  final List<MuscleGroup> secondaryMuscles;

  // Equipment & Difficulty
  final EquipmentType equipment;
  final ExerciseDifficulty difficulty;
  final Mechanics mechanics;
  final ForceType forceType;
  final Laterality laterality;
  final PlaneOfMotion planeOfMotion;

  // Training Parameters (defaults)
  final int sets;
  final String reps;
  final int restSeconds;
  final String? weightSuggestion;
  final bool isBodyweight;
  final bool isTimed;
  final int? targetDurationSeconds;

  // Coaching Content
  final String instructions;
  final List<String> tips;
  final List<String> commonMistakes;

  // Performance Metrics (RPE, RIR)
  final int? rpe;
  final int? rir;

  // Execution Tempo
  final Tempo? tempo;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.movementPattern,
    required this.primaryMuscles,
    this.secondaryMuscles = const [],
    required this.equipment,
    required this.difficulty,
    required this.mechanics,
    required this.forceType,
    required this.laterality,
    required this.planeOfMotion,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.weightSuggestion,
    required this.isBodyweight,
    required this.isTimed,
    this.targetDurationSeconds,
    required this.instructions,
    this.tips = const [],
    this.commonMistakes = const [],
    this.rpe,
    this.rir,
    this.tempo,
  });

  // ============================================================
  // Computed Getters
  // ============================================================

  bool get isCompound => primaryMuscles.length > 1;
  bool get isIsolation => primaryMuscles.length == 1;
  bool get isWeighted => !isBodyweight && weightSuggestion != null;

  String get primaryMusclesDisplay =>
      primaryMuscles.map((m) => m.displayName).join(', ');

  String get equipmentDisplay => equipment.displayName;
  String get difficultyDisplay => difficulty.displayName;

  String get weightDisplay {
    if (isBodyweight) return 'Bodyweight';
    if (weightSuggestion != null && weightSuggestion!.isNotEmpty) {
      return '$weightSuggestion kg';
    }
    return 'Bodyweight';
  }

  // ============================================================
  // Serialization
  // ============================================================

  /// Converts this Exercise to a Map for storage or API.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'movementPattern': movementPattern.name,
      'primaryMuscles': primaryMuscles.map((m) => m.name).toList(),
      'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
      'equipment': equipment.name,
      'difficulty': difficulty.name,
      'mechanics': mechanics.name,
      'forceType': forceType.name,
      'laterality': laterality.name,
      'planeOfMotion': planeOfMotion.name,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      if (weightSuggestion != null) 'weightSuggestion': weightSuggestion,
      'isBodyweight': isBodyweight,
      'isTimed': isTimed,
      if (targetDurationSeconds != null)
        'targetDurationSeconds': targetDurationSeconds,
      'instructions': instructions,
      'tips': tips,
      'commonMistakes': commonMistakes,
      if (rpe != null) 'rpe': rpe,
      if (rir != null) 'rir': rir,
      if (tempo != null) 'tempo': tempo!.toMap(),
    };
  }

  /// Creates an Exercise from a Map.
  factory Exercise.fromMap(Map<String, dynamic> map) {
    final primaryMuscles = (map['primaryMuscles'] as List?)
            ?.map((e) => MuscleGroup.values.firstWhere(
                  (m) => m.name == e,
                  orElse: () => MuscleGroup.chest,
                ))
            .toList() ??
        [];

    final secondaryMuscles = (map['secondaryMuscles'] as List?)
            ?.map((e) => MuscleGroup.values.firstWhere(
                  (m) => m.name == e,
                  orElse: () => MuscleGroup.chest,
                ))
            .toList() ??
        [];

    final tempoMap = map['tempo'] as Map<String, dynamic>?;

    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      category: ExerciseCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ExerciseCategory.compound,
      ),
      movementPattern: MovementPattern.values.firstWhere(
        (e) => e.name == map['movementPattern'],
        orElse: () => MovementPattern.push,
      ),
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      equipment: EquipmentType.values.firstWhere(
        (e) => e.name == map['equipment'],
        orElse: () => EquipmentType.bodyweight,
      ),
      difficulty: ExerciseDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => ExerciseDifficulty.beginner,
      ),
      mechanics: Mechanics.values.firstWhere(
        (e) => e.name == map['mechanics'],
        orElse: () => Mechanics.openChain,
      ),
      forceType: ForceType.values.firstWhere(
        (e) => e.name == map['forceType'],
        orElse: () => ForceType.push,
      ),
      laterality: Laterality.values.firstWhere(
        (e) => e.name == map['laterality'],
        orElse: () => Laterality.bilateral,
      ),
      planeOfMotion: PlaneOfMotion.values.firstWhere(
        (e) => e.name == map['planeOfMotion'],
        orElse: () => PlaneOfMotion.sagittal,
      ),
      sets: map['sets'] as int,
      reps: map['reps'] as String,
      restSeconds: map['restSeconds'] as int,
      weightSuggestion: map['weightSuggestion'] as String?,
      isBodyweight: map['isBodyweight'] as bool? ?? false,
      isTimed: map['isTimed'] as bool? ?? false,
      targetDurationSeconds: map['targetDurationSeconds'] as int?,
      instructions: map['instructions'] as String? ?? '',
      tips: (map['tips'] as List?)?.cast<String>() ?? [],
      commonMistakes: (map['commonMistakes'] as List?)?.cast<String>() ?? [],
      rpe: map['rpe'] as int?,
      rir: map['rir'] as int?,
      tempo: tempoMap != null ? Tempo.fromMap(tempoMap) : null,
    );
  }

  // ============================================================
  // Copy Method
  // ============================================================

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    ExerciseCategory? category,
    MovementPattern? movementPattern,
    List<MuscleGroup>? primaryMuscles,
    List<MuscleGroup>? secondaryMuscles,
    EquipmentType? equipment,
    ExerciseDifficulty? difficulty,
    Mechanics? mechanics,
    ForceType? forceType,
    Laterality? laterality,
    PlaneOfMotion? planeOfMotion,
    int? sets,
    String? reps,
    int? restSeconds,
    String? weightSuggestion,
    bool? isBodyweight,
    bool? isTimed,
    int? targetDurationSeconds,
    String? instructions,
    List<String>? tips,
    List<String>? commonMistakes,
    int? rpe,
    int? rir,
    Tempo? tempo,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      movementPattern: movementPattern ?? this.movementPattern,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      mechanics: mechanics ?? this.mechanics,
      forceType: forceType ?? this.forceType,
      laterality: laterality ?? this.laterality,
      planeOfMotion: planeOfMotion ?? this.planeOfMotion,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      weightSuggestion: weightSuggestion ?? this.weightSuggestion,
      isBodyweight: isBodyweight ?? this.isBodyweight,
      isTimed: isTimed ?? this.isTimed,
      targetDurationSeconds:
          targetDurationSeconds ?? this.targetDurationSeconds,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      rpe: rpe ?? this.rpe,
      rir: rir ?? this.rir,
      tempo: tempo ?? this.tempo,
    );
  }

  // ============================================================
  // Equality
  // ============================================================

  @override
  bool operator ==(Object other) {
    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Exercise($name, ${sets}x$reps)';
}
