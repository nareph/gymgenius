// ============================================================
// FILE: lib/data/datasources/local/hive/models/exercise_hive_model.dart
// ============================================================

import 'package:hive/hive.dart';

part 'exercise_hive_model.g.dart';

@HiveType(typeId: 8)
class ExerciseHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category;

  @HiveField(4)
  String movementPattern;

  @HiveField(5)
  List<String> primaryMuscles;

  @HiveField(6)
  List<String> secondaryMuscles;

  @HiveField(7)
  String equipment;

  @HiveField(8)
  String difficulty;

  @HiveField(9)
  String mechanics;

  @HiveField(10)
  String forceType;

  @HiveField(11)
  String laterality;

  @HiveField(12)
  String planeOfMotion;

  @HiveField(13)
  int sets;

  @HiveField(14)
  String reps;

  @HiveField(15)
  int restSeconds;

  @HiveField(16)
  String? weightSuggestion;

  @HiveField(17)
  bool isBodyweight;

  @HiveField(18)
  bool isTimed;

  @HiveField(19)
  int? targetDurationSeconds;

  @HiveField(20)
  String instructions;

  @HiveField(21)
  List<String> tips;

  @HiveField(22)
  List<String> commonMistakes;

  @HiveField(23)
  int? rpe;

  @HiveField(24)
  int? rir;

  @HiveField(25)
  TempoHiveModel? tempo;

  ExerciseHiveModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.movementPattern,
    required this.primaryMuscles,
    required this.secondaryMuscles,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'movementPattern': movementPattern,
      'primaryMuscles': primaryMuscles,
      'secondaryMuscles': secondaryMuscles,
      'equipment': equipment,
      'difficulty': difficulty,
      'mechanics': mechanics,
      'forceType': forceType,
      'laterality': laterality,
      'planeOfMotion': planeOfMotion,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'weightSuggestion': weightSuggestion,
      'isBodyweight': isBodyweight,
      'isTimed': isTimed,
      'targetDurationSeconds': targetDurationSeconds,
      'instructions': instructions,
      'tips': tips,
      'commonMistakes': commonMistakes,
      'rpe': rpe,
      'rir': rir,
      'tempo': tempo?.toMap(),
    };
  }

  factory ExerciseHiveModel.fromMap(dynamic map) {
    final safeMap = Map<String, dynamic>.from(map as Map);
    return ExerciseHiveModel(
      id: safeMap['id'] as String? ?? '',
      name: safeMap['name'] as String? ?? '',
      description: safeMap['description'] as String? ?? '',
      category: safeMap['category'] as String? ?? '',
      movementPattern: safeMap['movementPattern'] as String? ?? '',
      primaryMuscles:
          (safeMap['primaryMuscles'] as List?)?.cast<String>() ?? [],
      secondaryMuscles:
          (safeMap['secondaryMuscles'] as List?)?.cast<String>() ?? [],
      equipment: safeMap['equipment'] as String? ?? '',
      difficulty: safeMap['difficulty'] as String? ?? '',
      mechanics: safeMap['mechanics'] as String? ?? '',
      forceType: safeMap['forceType'] as String? ?? '',
      laterality: safeMap['laterality'] as String? ?? '',
      planeOfMotion: safeMap['planeOfMotion'] as String? ?? '',
      sets: (safeMap['sets'] as num?)?.toInt() ?? 0,
      reps: safeMap['reps'] as String? ?? '',
      restSeconds: (safeMap['restSeconds'] as num?)?.toInt() ?? 60,
      weightSuggestion: safeMap['weightSuggestion'] as String?,
      isBodyweight: safeMap['isBodyweight'] as bool? ?? false,
      isTimed: safeMap['isTimed'] as bool? ?? false,
      targetDurationSeconds:
          (safeMap['targetDurationSeconds'] as num?)?.toInt(),
      instructions: safeMap['instructions'] as String? ?? '',
      tips: (safeMap['tips'] as List?)?.cast<String>() ?? [],
      commonMistakes:
          (safeMap['commonMistakes'] as List?)?.cast<String>() ?? [],
      rpe: (safeMap['rpe'] as num?)?.toInt(),
      rir: (safeMap['rir'] as num?)?.toInt(),
      tempo: safeMap['tempo'] != null
          ? TempoHiveModel.fromMap(safeMap['tempo'] as Map)
          : null,
    );
  }
}

@HiveType(typeId: 9)
class TempoHiveModel extends HiveObject {
  @HiveField(0)
  int eccentric;

  @HiveField(1)
  int pause;

  @HiveField(2)
  int concentric;

  @HiveField(3)
  int? pauseAfter;

  TempoHiveModel({
    required this.eccentric,
    required this.pause,
    required this.concentric,
    this.pauseAfter,
  });

  Map<String, dynamic> toMap() {
    return {
      'eccentric': eccentric,
      'pause': pause,
      'concentric': concentric,
      'pauseAfter': pauseAfter,
    };
  }

  factory TempoHiveModel.fromMap(dynamic map) {
    final safeMap = Map<String, dynamic>.from(map as Map);
    return TempoHiveModel(
      eccentric: (safeMap['eccentric'] as num?)?.toInt() ?? 0,
      pause: (safeMap['pause'] as num?)?.toInt() ?? 0,
      concentric: (safeMap['concentric'] as num?)?.toInt() ?? 0,
      pauseAfter: (safeMap['pauseAfter'] as num?)?.toInt(),
    );
  }
}
