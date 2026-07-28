// lib/engines/workout_engine/shared/exercises/splits/back_exercises.dart

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

/// Exercises for the 'Back' split (5‑day program).
/// Prefix: 'back_'
const List<ExercisePoolEntry> backExercises = [
  // ---- Bodyweight only ----
  ExercisePoolEntry(
    id: 'back_scapular_push_ups',
    name: 'Scapular Push-ups',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Traps, Serratus**\n\n'
        '1. Plank position, arms straight.\n'
        '2. Push your upper back towards the ceiling (without bending elbows).\n'
        '3. Return to neutral.',
  ),
  ExercisePoolEntry(
    id: 'back_prone_iy_t_raises',
    name: 'Prone I-Y-T Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Mid/Lower Traps, Rear Delts**\n\n'
        '1. Lie face down, arms in I, then Y, then T positions.\n'
        '2. Lift arms off the floor in each position.\n'
        '3. Squeeze shoulder blades.',
  ),
  ExercisePoolEntry(
    id: 'back_supermans',
    name: 'Supermans',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Glutes**\n\n'
        '1. Lie face down, arms extended forward.\n'
        '2. Lift chest, arms, and legs off the ground.\n'
        '3. Hold briefly, then lower.',
  ),
  ExercisePoolEntry(
    id: 'back_reverse_snow_angels',
    name: 'Reverse Snow Angels',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Upper Back**\n\n'
        '1. Lie face down, arms out to sides.\n'
        '2. Raise arms and squeeze shoulder blades together.\n'
        '3. Lower slowly.',
  ),
  ExercisePoolEntry(
    id: 'back_prone_y_raises',
    name: 'Prone Y-Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Traps, Rear Delts**\n\n'
        '1. Lie face down, arms in Y position.\n'
        '2. Raise arms off the floor.\n'
        '3. Squeeze shoulder blades and lower.',
  ),
  ExercisePoolEntry(
    id: 'back_prone_t_raises',
    name: 'Prone T-Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Mid Traps, Rear Delts**\n\n'
        '1. Lie face down, arms out to the sides (T position).\n'
        '2. Raise arms off the floor, squeezing shoulder blades.\n'
        '3. Lower with control.',
  ),
  // ---- If user has a pull-up bar (bodyweight but requires equipment) ----
  ExercisePoolEntry(
    id: 'back_pull_ups',
    name: 'Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Hang from a bar, hands slightly wider than shoulders.\n'
        '2. Pull up until chin clears the bar.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'back_chin_ups',
    name: 'Chin-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Use an underhand grip.\n'
        '2. Pull up until chin clears the bar.\n'
        '3. Lower slowly.',
  ),
  ExercisePoolEntry(
    id: 'back_wide_grip_pull_ups',
    name: 'Wide-Grip Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.shoulders],
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
  // ---- Band rows if resistance bands available ----
  ExercisePoolEntry(
    id: 'back_band_rows',
    name: 'Band Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Anchor a band at chest height and step back to create tension.\n'
        '2. Pull the handles towards your torso, squeezing your shoulder blades.\n'
        '3. Return slowly with control.',
  ),
];
