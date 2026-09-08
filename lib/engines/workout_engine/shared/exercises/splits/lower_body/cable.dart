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

const List<ExercisePoolEntry> lowerBodyCableExercises = [
  ExercisePoolEntry(
    id: 'lower_cable_glute_kickbacks',
    name: 'Cable Glute Kickbacks',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes**\n\n'
        '1. Attach an ankle strap to a low pulley on a cable machine and secure it around your right ankle.\n'
        '2. Stand facing the machine, holding the support bar for balance, with your weight on your left leg.\n'
        '3. Keeping your knee slightly bent, kick your right leg straight back, squeezing your glute at the top.\n'
        '4. Return with control to the starting position.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'lower_cable_pull_through',
    name: 'Cable Pull-Through',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes, Hamstrings**\n\n'
        '1. Attach a rope to a low pulley and stand facing away from the machine, feet shoulder‑width apart.\n'
        '2. Hinge at the hips, reaching back between your legs to grip the rope, keeping your back flat.\n'
        '3. Drive your hips forward to stand up, squeezing your glutes at the top.\n'
        '4. Lower the rope back through your legs with control.\n'
        '5. Keep your core braced and your knees slightly bent throughout.',
  ),
  ExercisePoolEntry(
    id: 'lower_cable_hip_adduction',
    name: 'Cable Hip Adduction',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.adductors],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Adductors**\n\n'
        '1. Attach an ankle strap to a low pulley on the side of the machine.\n'
        '2. Stand with your side facing the machine, secure the strap to the ankle of the leg farthest from the pulley.\n'
        '3. Keeping your core tight, pull your leg across your body (adduction), squeezing your inner thigh at the peak.\n'
        '4. Return slowly with control.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'lower_cable_hip_abduction',
    name: 'Cable Hip Abduction',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Glutes**\n\n'
        '1. Attach an ankle strap to a low pulley on the side of the machine.\n'
        '2. Stand with your side facing the machine, secure the strap to the ankle of the leg closest to the pulley.\n'
        '3. Keeping your core tight, pull your leg away from your body (abduction), squeezing your glute medius at the peak.\n'
        '4. Return slowly with control.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'lower_cable_squat_pulldown',
    name: 'Cable Squat Pulldown',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Set a cable at chest height with a rope or bar attachment.\n'
        '2. Take a slight step forward, hold the handle with both hands, and stand with feet shoulder‑width apart.\n'
        '3. Squat down as you would in a bodyweight squat, keeping your chest up and core engaged.\n'
        '4. As you stand up, pull the cable towards your chest to add resistance.\n'
        '5. Perform the movement in a controlled manner, squeezing your glutes at the top.',
  ),
];
