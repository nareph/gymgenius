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

const List<ExercisePoolEntry> legsLegExtensionExercises = [
  ExercisePoolEntry(
    id: 'legs_ext_standard',
    name: 'Leg Extensions',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legExtensionMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps**\n\n'
        '1. Sit on the leg extension machine, shins behind the pad.\n'
        '2. Extend your legs until straight.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'legs_ext_single_leg',
    name: 'Single-Leg Extensions',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.legExtensionMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps (unilateral)**\n\n'
        '1. Use one leg at a time to isolate each quad.',
  ),
  ExercisePoolEntry(
    id: 'legs_ext_iso_hold',
    name: 'Leg Extension Isometric Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.legExtensionMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps**\n\n'
        '1. Extend legs and hold the top position for 3-5 seconds.\n'
        '2. Lower slowly.',
  ),
  ExercisePoolEntry(
    id: 'legs_ext_drop_set',
    name: 'Leg Extension Drop Set',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.legExtensionMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps**\n\n'
        '1. Perform a set to failure, reduce weight, continue.\n'
        '2. Repeat for 2-3 drops.',
  ),
  ExercisePoolEntry(
    id: 'legs_ext_partial_reps',
    name: 'Leg Extension Partial Reps',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.legExtensionMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps**\n\n'
        '1. Extend only the top half of the movement.\n'
        '2. Focus on constant tension.',
  ),
];
