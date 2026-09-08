import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

const List<ExercisePoolEntry> armsHomemadeExercises = [
  ExercisePoolEntry(
    id: 'arms_homemade_bicep_curl',
    name: 'Homemade Weight Bicep Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps**\n\n'
        '1. Stand upright with feet shoulder‑width apart, holding a homemade weight (e.g., bag of rice, water jug) in each hand, palms facing forward.\n'
        '2. Keeping your elbows pinned to your sides, curl the weights up towards your shoulders.\n'
        '3. Squeeze your biceps at the top, then lower with control.\n'
        '4. Avoid swinging your body; use strict form.\n'
        '5. Perform the movement slowly for maximum biceps activation.',
  ),
  ExercisePoolEntry(
    id: 'arms_homemade_tricep_extension',
    name: 'Homemade Weight Tricep Extension',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Hold a single homemade weight with both hands overhead, arms straight.\n'
        '2. Bend your elbows to lower the weight behind your head.\n'
        '3. Extend your arms back up, squeezing your triceps.\n'
        '4. Keep your elbows stationary and close to your head.\n'
        '5. Ensure the weight is secure to avoid dropping it on your head.',
  ),
  ExercisePoolEntry(
    id: 'arms_homemade_hammer_curl',
    name: 'Homemade Weight Hammer Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.forearms],
    usesWeight: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps, Forearms**\n\n'
        '1. Stand upright with feet shoulder‑width apart, holding a homemade weight in each hand with a neutral grip (palms facing each other).\n'
        '2. Keeping your elbows pinned to your sides, curl the weights up towards your shoulders without rotating your wrists.\n'
        '3. Squeeze your biceps and forearms at the top, then lower with control.\n'
        '4. This variation targets the brachialis and brachioradialis muscles.\n'
        '5. Perform the movement slowly for maximum muscle engagement.',
  ),
  ExercisePoolEntry(
    id: 'arms_homemade_skull_crusher',
    name: 'Homemade Weight Skull Crusher',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Lie on your back on the floor or a bench, holding a homemade weight with both hands above your chest, arms extended.\n'
        '2. Keeping your upper arms fixed, bend your elbows to lower the weight towards your forehead.\n'
        '3. Lower until the weight is just above your forehead, then extend your arms back up to the starting position.\n'
        '4. Keep your elbows stationary throughout the movement to isolate the triceps.\n'
        '5. Use a light weight to maintain control and avoid injury.',
  ),
  ExercisePoolEntry(
    id: 'arms_homemade_concentration_curl',
    name: 'Homemade Weight Concentration Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps (Peak)**\n\n'
        '1. Sit on a chair or bench, spread your legs, and rest your elbow against your inner thigh on the same side.\n'
        '2. Hold a homemade weight in your hand, arm extended, and let it hang between your legs.\n'
        '3. Curl the weight up towards your shoulder, squeezing your biceps at the top.\n'
        '4. Lower with control, fully extending your arm at the bottom.\n'
        '5. Complete all reps on one side before switching to the other.',
  ),
];
