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

const List<ExercisePoolEntry> armsCableExercises = [
  ExercisePoolEntry(
    id: 'arms_cable_curls',
    name: 'Cable Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps**\n\n'
        '1. Attach a straight bar to a low pulley on a cable machine.\n'
        '2. Stand facing the machine, grip the bar with an underhand grip, hands shoulder‑width apart.\n'
        '3. Step back to create tension, keeping your elbows pinned to your sides.\n'
        '4. Curl the bar up towards your shoulders, squeezing your biceps at the top.\n'
        '5. Lower with control back to the starting position, maintaining tension throughout.',
  ),
  ExercisePoolEntry(
    id: 'arms_cable_tricep_pushdowns',
    name: 'Tricep Pushdowns',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Attach a rope or straight bar to a high pulley.\n'
        '2. Stand close to the machine, grip the handle, and keep your elbows pinned to your sides.\n'
        '3. Push the handle down until your arms are fully extended, squeezing your triceps at the bottom.\n'
        '4. Return slowly to the starting position, resisting the weight.\n'
        '5. For increased isolation, lean forward slightly and keep your upper arms stationary.',
  ),
  ExercisePoolEntry(
    id: 'arms_cable_hammer_curl',
    name: 'Cable Hammer Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.biceps, MuscleGroup.forearms],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps, Forearms**\n\n'
        '1. Attach a rope or straight bar to a low pulley.\n'
        '2. Grip the handle with a neutral grip (palms facing each other), step back to create tension.\n'
        '3. Curl the handle up towards your shoulders without rotating your wrists.\n'
        '4. Squeeze your biceps and forearms at the top, then lower with control.\n'
        '5. This variation targets the brachialis and brachioradialis muscles.',
  ),
  ExercisePoolEntry(
    id: 'arms_cable_overhead_tricep_extension',
    name: 'Cable Overhead Tricep Extension',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Attach a rope to a low pulley and face away from the machine.\n'
        '2. Hold the rope overhead with your arms bent, hands behind your head.\n'
        '3. Extend your arms upward, straightening them fully, squeezing your triceps.\n'
        '4. Lower the rope back behind your head with control, keeping your upper arms stationary.\n'
        '5. Focus on the full extension of the triceps at the top of the movement.',
  ),
  ExercisePoolEntry(
    id: 'arms_cable_single_arm_pushdown',
    name: 'Single-Arm Cable Pushdown',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps (Unilateral)**\n\n'
        '1. Attach a D‑handle to a high pulley.\n'
        '2. Stand close to the machine, grip the handle with one hand, and keep your elbow pinned to your side.\n'
        '3. Push the handle down until your arm is fully extended, squeezing your triceps.\n'
        '4. Return slowly to the starting position, resisting the weight.\n'
        '5. Complete all reps on one side before switching to the other.',
  ),
];
