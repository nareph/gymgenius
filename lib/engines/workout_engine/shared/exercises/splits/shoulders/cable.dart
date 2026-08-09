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

const List<ExercisePoolEntry> shouldersCableExercises = [
  ExercisePoolEntry(
    id: 'shoulders_cable_face_pull',
    name: 'Cable Face Pull',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.back],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Traps**\n\n'
        '1. Attach a rope to a high pulley.\n'
        '2. Pull the rope towards your face, elbows high.\n'
        '3. Squeeze shoulder blades, then return.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_cable_lateral_raise',
    name: 'Cable Lateral Raise',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Side Shoulders**\n\n'
        '1. Attach a D-handle to a low pulley.\n'
        '2. Standing sideways, raise your arm out to the side.\n'
        '3. Lower with control and switch sides.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_cable_reverse_fly',
    name: 'Cable Reverse Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.back],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts**\n\n'
        '1. Set two cables at shoulder height.\n'
        '2. Cross the handles, pull them out to the sides.\n'
        '3. Squeeze shoulder blades and return.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_cable_front_raise',
    name: 'Cable Front Raise',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Front Shoulders**\n\n'
        '1. Attach a D-handle to a low pulley.\n'
        '2. Facing the pulley, raise your arm straight forward to shoulder height.\n'
        '3. Lower with control and switch sides.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_cable_upright_row',
    name: 'Cable Upright Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
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
        '1. Attach a straight bar to a low pulley.\n'
        '2. Stand facing the pulley, grip the bar with overhand grip.\n'
        '3. Pull the bar up towards your chin, elbows leading.\n'
        '4. Lower with control.',
  ),
];
