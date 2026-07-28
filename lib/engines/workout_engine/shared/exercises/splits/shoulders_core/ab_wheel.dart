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

const List<ExercisePoolEntry> shouldersCoreAbWheelExercises = [
  ExercisePoolEntry(
    id: 'shoulders_core_abwheel_rollouts',
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
  ExercisePoolEntry(
    id: 'shoulders_core_abwheel_knee_rollouts',
    name: 'Ab Wheel Knee Rollouts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.abWheel,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core**\n\n'
        '1. Start on your knees with the wheel in front.\n'
        '2. Roll out only until your shoulders are extended, keeping back flat.\n'
        '3. Pull back to the start.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_abwheel_standing_rollouts',
    name: 'Ab Wheel Standing Rollouts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
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
        '1. Stand with feet hip-width apart, holding the wheel.\n'
        '2. Roll down towards the floor, keeping back straight.\n'
        '3. Roll back up using your core.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_abwheel_oblique_rollouts',
    name: 'Ab Wheel Oblique Rollouts',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.abWheel,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Obliques**\n\n'
        '1. Kneel on the floor, wheel in front.\n'
        '2. Roll out diagonally to one side.\n'
        '3. Pull back and repeat on the other side.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_abwheel_negative_rollouts',
    name: 'Ab Wheel Negative Rollouts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
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
        '1. Roll out as far as possible.\n'
        '2. Pause at the bottom for 2-3 seconds.\n'
        '3. Pull back with control.',
  ),
];
