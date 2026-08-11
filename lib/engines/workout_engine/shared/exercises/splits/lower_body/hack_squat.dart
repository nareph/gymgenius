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

const List<ExercisePoolEntry> lowerBodyHackSquatExercises = [
  ExercisePoolEntry(
    id: 'lower_hack_standard',
    name: 'Hack Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.hackSquatMachine,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Position shoulders under pads.\n'
        '2. Lower to 90°.\n'
        '3. Push through heels to return.',
  ),
  ExercisePoolEntry(
    id: 'lower_hack_narrow_stance',
    name: 'Hack Squat - Narrow Stance',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.hackSquatMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [MuscleGroup.glutes],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps**\n\n'
        '1. Place feet narrow on platform.\n'
        '2. Perform hack squat.',
  ),
  ExercisePoolEntry(
    id: 'lower_hack_wide_stance',
    name: 'Hack Squat - Wide Stance',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.hackSquatMachine,
    targetMuscles: [MuscleGroup.glutes, MuscleGroup.adductors],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes, Adductors**\n\n'
        '1. Place feet wide on platform.\n'
        '2. Perform hack squat.',
  ),
  ExercisePoolEntry(
    id: 'lower_hack_single_leg',
    name: 'Single-Leg Hack Squat',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.hackSquatMachine,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes (unilateral)**\n\n'
        '1. Use one leg on platform.\n'
        '2. Control the movement.\n'
        '3. Switch sides.',
  ),
  ExercisePoolEntry(
    id: 'lower_hack_reverse',
    name: 'Reverse Hack Squat',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.hackSquatMachine,
    targetMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes, Hamstrings**\n\n'
        '1. Face the machine, shoulders against pads.\n'
        '2. Perform squat with hip-dominant emphasis.',
  ),
];
