import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/exercise_difficulty.dart';
import 'package:gymgenius/domain/enums/force_type.dart';
import 'package:gymgenius/domain/enums/laterality.dart';
import 'package:gymgenius/domain/enums/mechanics.dart';
import 'package:gymgenius/domain/enums/movement_pattern.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/enums/plane_of_motion.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

final List<ExercisePoolEntry> coreCableExercises = [
  ExercisePoolEntry(
    id: 'core_cable_woodchops',
    name: 'Cable Woodchops',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Set cable at high or low position.\n'
        '2. Chop diagonally across body.',
  ),
  ExercisePoolEntry(
    id: 'core_cable_crunches',
    name: 'Cable Crunches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Abs**\n\n'
        '1. Kneel below a high pulley, rope behind your head.\n'
        '2. Crunch down, bringing elbows towards knees.\n'
        '3. Return with control.',
  ),
  ExercisePoolEntry(
    id: 'core_cable_pallof_press',
    name: 'Cable Pallof Press',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Core (anti-rotation)**\n\n'
        '1. Set cable at chest height.\n'
        '2. Stand sideways, hold handle with both hands.\n'
        '3. Press straight out, resisting rotation.\n'
        '4. Return and switch sides.',
  ),
  ExercisePoolEntry(
    id: 'core_cable_oblique_twist',
    name: 'Cable Oblique Twist',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Set cable at waist height with a D-handle.\n'
        '2. Stand perpendicular, rotate torso away.\n'
        '3. Return and switch sides.',
  ),
  ExercisePoolEntry(
    id: 'core_cable_side_bend',
    name: 'Cable Side Bend',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Obliques**\n\n'
        '1. Set cable at low position with a D-handle.\n'
        '2. Stand sideways, hold handle with one hand.\n'
        '3. Bend torso sideways, then return.',
  ),
];
