// lib/engines/workout_engine/shared/exercises/splits/shoulders_core_exercises.dart

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

/// List of exercises for the 'Shoulders & Core' split.
///
/// Prefix for all ids: 'shoulders_core_'
///
/// Includes at least 8 bodyweight exercises so users with only bodyweight
/// can still complete a full session (desiredCount 4–8).
const List<ExercisePoolEntry> shouldersCoreExercises = [
  // ---- Bodyweight exercises (8+ variants) ----
  ExercisePoolEntry(
    id: 'shoulders_core_pike_push_ups',
    name: 'Pike Push-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Downward-dog position, hips high.\n'
        '2. Lower head towards floor.\n'
        '3. Press back up.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_handstand_push_ups',
    name: 'Handstand Push-ups (against wall)',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Kick up into a handstand against a wall.\n'
        '2. Lower your head towards the floor.\n'
        '3. Press back up to full extension.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_side_plank',
    name: 'Side Plank',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Obliques**\n\n'
        '1. Side support on forearm.\n'
        '2. Hold body straight.\n'
        '3. Repeat on other side.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_plank',
    name: 'Plank',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core**\n\n'
        '1. Forearm plank position.\n'
        '2. Hold body straight from head to heels.\n'
        '3. Engage core and hold for time.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_mountain_climbers',
    name: 'Mountain Climbers',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Plank position.\n'
        '2. Drive one knee towards chest.\n'
        '3. Alternate quickly.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_bicycle_crunches',
    name: 'Bicycle Crunches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Abs, Obliques**\n\n'
        '1. Lie on your back, hands behind your head.\n'
        '2. Bring one elbow towards the opposite knee while extending the other leg.\n'
        '3. Alternate sides in a pedaling motion.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_russian_twists',
    name: 'Russian Twists',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Sit with knees bent, torso leaning back slightly, feet off the floor.\n'
        '2. Rotate your torso side to side, tapping the floor beside your hips.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_hanging_leg_raises',
    name: 'Hanging Leg Raises',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Hang from a pull-up bar with arms fully extended.\n'
        '2. Raise your legs straight up towards your chest.\n'
        '3. Lower with control.',
  ),

  // ---- Equipment-based exercises (for users with additional gear) ----
  ExercisePoolEntry(
    id: 'shoulders_core_shoulder_press',
    name: 'Shoulder Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Sit with dumbbells at shoulders.\n'
        '2. Press overhead.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_arnold_press',
    name: 'Arnold Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders (all heads), Triceps**\n\n'
        '1. Start with dumbbells in front of shoulders, palms facing you.\n'
        '2. Press up while rotating palms to face forward.\n'
        '3. Reverse on the way down.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_lateral_raises',
    name: 'Lateral Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Side Shoulders**\n\n'
        '1. Raise dumbbells to sides to shoulder height.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_front_raises',
    name: 'Front Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Front Shoulders**\n\n'
        '1. Raise dumbbells in front to shoulder height.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_upright_rows',
    name: 'Upright Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.biceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Traps**\n\n'
        '1. Hold dumbbells in front of your thighs.\n'
        '2. Pull them straight up towards your chin, elbows leading.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_cable_woodchops',
    name: 'Cable Woodchops',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.absCore, MuscleGroup.shoulders],
    secondaryMuscles: [],
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
    id: 'shoulders_core_cable_crunches',
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
        '2. Crunch down, bringing elbows towards your knees.\n'
        '3. Return with control.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_ab_wheel_rollouts',
    name: 'Ab Wheel Rollouts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.abWheel,
    targetMuscles: [MuscleGroup.absCore, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Kneel on the floor, gripping the ab wheel handles.\n'
        '2. Roll forward slowly, keeping your core braced and back flat.\n'
        '3. Roll back to the starting position.',
  ),
];
