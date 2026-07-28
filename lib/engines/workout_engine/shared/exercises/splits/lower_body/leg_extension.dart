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

const List<ExercisePoolEntry> lowerBodyLegExtensionExercises = [
  ExercisePoolEntry(
    id: 'lower_ext_leg_extensions',
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
        '1. Sit at the machine, shins behind the pad.\n'
        '2. Extend legs until straight.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'lower_ext_single_leg_extension',
    name: 'Single-Leg Extension',
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
        '1. Use one leg at a time.\n'
        '2. Extend fully, squeeze quad.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'lower_ext_iso_hold',
    name: 'Leg Extension Isometric Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.legExtensionMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [],
    usesWeight: true,
    isTimed: true,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.openChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps**\n\n'
        '1. Extend legs fully.\n'
        '2. Hold for 3-5 seconds.\n'
        '3. Lower slowly.',
  ),
  ExercisePoolEntry(
    id: 'lower_ext_partial_reps',
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
        '1. Extend only the top half of movement.\n'
        '2. Keep constant tension.\n'
        '3. Lower to halfway.',
  ),
  ExercisePoolEntry(
    id: 'lower_ext_drop_set',
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
        '1. Perform set to failure.\n'
        '2. Reduce weight immediately.\n'
        '3. Continue for 2-3 drops.',
  ),
];
