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

const List<ExercisePoolEntry> backSelectorizedExercises = [
  ExercisePoolEntry(
    id: 'back_selector_seated_row',
    name: 'Selectorized Seated Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Sit on the machine, chest against the pad.\n'
        '2. Pull the handles towards your torso.\n'
        '3. Squeeze shoulder blades, then return.',
  ),
  ExercisePoolEntry(
    id: 'back_selector_lat_pulldown',
    name: 'Selectorized Lat Pulldown',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats, Biceps**\n\n'
        '1. Sit at the machine, grip the bar.\n'
        '2. Pull the bar down to your upper chest.\n'
        '3. Squeeze lats, then return.',
  ),
  ExercisePoolEntry(
    id: 'back_selector_chest_supported_row',
    name: 'Chest-Supported Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.biceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back**\n\n'
        '1. Lie chest-down on the machine, grip handles.\n'
        '2. Pull handles towards your chest.\n'
        '3. Squeeze shoulder blades, then return.',
  ),
  ExercisePoolEntry(
    id: 'back_selector_rear_delt_fly',
    name: 'Selectorized Rear Delt Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts**\n\n'
        '1. Sit on the machine, arms against the pads.\n'
        '2. Push the pads back and out, squeezing shoulder blades.\n'
        '3. Return with control.',
  ),
  ExercisePoolEntry(
    id: 'back_selector_pulldown_wide_grip',
    name: 'Wide-Grip Lat Pulldown',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.biceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats (width)**\n\n'
        '1. Use a wide grip on the lat pulldown bar.\n'
        '2. Pull down to your upper chest.\n'
        '3. Squeeze lats, then return.',
  ),
];
