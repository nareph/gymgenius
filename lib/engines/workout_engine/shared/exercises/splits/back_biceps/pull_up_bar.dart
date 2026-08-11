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

const List<ExercisePoolEntry> backBicepsPullUpBarExercises = [
  ExercisePoolEntry(
    id: 'back_biceps_pullup_pull_ups',
    name: 'Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Hang from bar.\n'
        '2. Pull up until chin over bar.\n'
        '3. Lower slowly.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_pullup_chin_ups',
    name: 'Chin-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Underhand grip.\n'
        '2. Pull up to chin over bar.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_pullup_wide_grip',
    name: 'Wide-Grip Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.biceps],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats (width)**\n\n'
        '1. Grip the bar wider than shoulder-width.\n'
        '2. Pull your chest towards the bar.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_pullup_neutral_grip',
    name: 'Neutral-Grip Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Use parallel handles or neutral grip.\n'
        '2. Pull up, keeping elbows close.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_pullup_commando',
    name: 'Commando Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps, Core**\n\n'
        '1. Grip bar with one hand in front of the other.\n'
        '2. Pull up, alternating lead hand each rep.',
  ),
];
