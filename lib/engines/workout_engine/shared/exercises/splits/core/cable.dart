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

final List<ExercisePoolEntry> coreCableExercises = [
  ExercisePoolEntry(
    id: 'core_cable_woodchops',
    name: 'Cable Woodchops',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Set the cable at the highest position and attach a rope or D‑handle.\n'
        '2. Stand with your side to the machine, feet shoulder‑width apart, and grip the handle with both hands.\n'
        '3. Pull the handle diagonally downward across your body, rotating your torso and squeezing your core.\n'
        '4. Control the movement back to the starting position.\n'
        '5. Complete all reps on one side before switching to the other.',
  ),
  ExercisePoolEntry(
    id: 'core_cable_crunches',
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
        '1. Attach a rope to a high pulley and kneel facing the machine, holding the rope behind your head.\n'
        '2. Keep your elbows pointing toward the floor and your core engaged.\n'
        '3. Crunch down by curling your upper body toward your knees, squeezing your abs.\n'
        '4. Return slowly to the starting position, controlling the resistance.\n'
        '5. Avoid pulling with your arms; the movement should come from your core.',
  ),
  ExercisePoolEntry(
    id: 'core_cable_pallof_press',
    name: 'Cable Pallof Press',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Core (anti-rotation)**\n\n'
        '1. Set the cable at chest height and attach a D‑handle.\n'
        '2. Stand sideways to the machine, feet shoulder‑width apart, and grip the handle with both hands.\n'
        '3. Press the handle straight out in front of you, resisting the rotational pull of the cable.\n'
        '4. Hold for a second, then return slowly with control.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'core_cable_oblique_twist',
    name: 'Cable Oblique Twist',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Set the cable at waist height and attach a D‑handle.\n'
        '2. Stand perpendicular to the machine, feet shoulder‑width apart, and grip the handle with both hands.\n'
        '3. Rotate your torso away from the machine, keeping your arms straight and core tight.\n'
        '4. Control the movement back to the starting position.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'core_cable_side_bend',
    name: 'Cable Side Bend',
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
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Obliques**\n\n'
        '1. Set the cable at the lowest position and attach a D‑handle.\n'
        '2. Stand sideways to the machine, holding the handle with one hand at your side.\n'
        '3. Bend your torso sideways toward the machine, then return to upright using your obliques.\n'
        '4. Perform the movement slowly and with control.\n'
        '5. Complete all reps on one side before switching.',
  ),
];
