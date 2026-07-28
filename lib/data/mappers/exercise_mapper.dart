// ============================================================
// FILE: lib/data/mappers/exercise_mapper.dart
// ============================================================

import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/movement_pattern.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/exercise_difficulty.dart';
import 'package:gymgenius/domain/enums/mechanics.dart';
import 'package:gymgenius/domain/enums/force_type.dart';
import 'package:gymgenius/domain/enums/laterality.dart';
import 'package:gymgenius/domain/enums/plane_of_motion.dart';
import 'package:gymgenius/domain/value_objects/tempo.dart';
import 'package:gymgenius/data/datasources/local/hive/models/exercise_hive_model.dart';

class ExerciseMapper {
  const ExerciseMapper._();

  static Exercise toDomain(ExerciseHiveModel model) {
    return Exercise(
      id: model.id,
      name: model.name,
      description: model.description,
      category: _mapCategory(model.category),
      movementPattern: _mapMovementPattern(model.movementPattern),
      primaryMuscles: model.primaryMuscles.map(_mapMuscleGroup).toList(),
      secondaryMuscles: model.secondaryMuscles.map(_mapMuscleGroup).toList(),
      equipment: _mapEquipment(model.equipment),
      difficulty: _mapDifficulty(model.difficulty),
      mechanics: _mapMechanics(model.mechanics),
      forceType: _mapForceType(model.forceType),
      laterality: _mapLaterality(model.laterality),
      planeOfMotion: _mapPlaneOfMotion(model.planeOfMotion),
      sets: model.sets,
      reps: model.reps,
      restSeconds: model.restSeconds,
      weightSuggestion: model.weightSuggestion,
      isBodyweight: model.isBodyweight,
      isTimed: model.isTimed,
      targetDurationSeconds: model.targetDurationSeconds,
      instructions: model.instructions,
      tips: model.tips,
      commonMistakes: model.commonMistakes,
      rpe: model.rpe,
      rir: model.rir,
      tempo: model.tempo != null
          ? Tempo(
              eccentric: model.tempo!.eccentric,
              pause: model.tempo!.pause,
              concentric: model.tempo!.concentric,
              pauseAfter: model.tempo!.pauseAfter,
            )
          : null,
    );
  }

  static ExerciseHiveModel toHive(Exercise entity) {
    return ExerciseHiveModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      category: entity.category.name,
      movementPattern: entity.movementPattern.name,
      primaryMuscles: entity.primaryMuscles.map((m) => m.name).toList(),
      secondaryMuscles: entity.secondaryMuscles.map((m) => m.name).toList(),
      equipment: entity.equipment.name,
      difficulty: entity.difficulty.name,
      mechanics: entity.mechanics.name,
      forceType: entity.forceType.name,
      laterality: entity.laterality.name,
      planeOfMotion: entity.planeOfMotion.name,
      sets: entity.sets,
      reps: entity.reps,
      restSeconds: entity.restSeconds,
      weightSuggestion: entity.weightSuggestion,
      isBodyweight: entity.isBodyweight,
      isTimed: entity.isTimed,
      targetDurationSeconds: entity.targetDurationSeconds,
      instructions: entity.instructions,
      tips: entity.tips,
      commonMistakes: entity.commonMistakes,
      rpe: entity.rpe,
      rir: entity.rir,
      tempo: entity.tempo != null
          ? TempoHiveModel(
              eccentric: entity.tempo!.eccentric,
              pause: entity.tempo!.pause,
              concentric: entity.tempo!.concentric,
              pauseAfter: entity.tempo!.pauseAfter,
            )
          : null,
    );
  }

  // Helpers de conversion (String → Enum)
  static ExerciseCategory _mapCategory(String value) =>
      ExerciseCategory.values.firstWhere((e) => e.name == value,
          orElse: () => ExerciseCategory.compound);
  static MovementPattern _mapMovementPattern(String value) => MovementPattern
      .values
      .firstWhere((e) => e.name == value, orElse: () => MovementPattern.push);
  static MuscleGroup _mapMuscleGroup(String value) => MuscleGroup.values
      .firstWhere((e) => e.name == value, orElse: () => MuscleGroup.chest);
  static EquipmentType _mapEquipment(String value) =>
      EquipmentType.values.firstWhere((e) => e.name == value,
          orElse: () => EquipmentType.bodyweight);
  static ExerciseDifficulty _mapDifficulty(String value) =>
      ExerciseDifficulty.values.firstWhere((e) => e.name == value,
          orElse: () => ExerciseDifficulty.beginner);
  static Mechanics _mapMechanics(String value) => Mechanics.values
      .firstWhere((e) => e.name == value, orElse: () => Mechanics.openChain);
  static ForceType _mapForceType(String value) => ForceType.values
      .firstWhere((e) => e.name == value, orElse: () => ForceType.push);
  static Laterality _mapLaterality(String value) => Laterality.values
      .firstWhere((e) => e.name == value, orElse: () => Laterality.bilateral);
  static PlaneOfMotion _mapPlaneOfMotion(String value) => PlaneOfMotion.values
      .firstWhere((e) => e.name == value, orElse: () => PlaneOfMotion.sagittal);
}
