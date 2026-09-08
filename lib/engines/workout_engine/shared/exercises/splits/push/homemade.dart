import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

const List<ExercisePoolEntry> pushHomemadeExercises = [
  ExercisePoolEntry(
    id: 'push_homemade_chest_press',
    name: 'Homemade Weight Chest Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest**\n\n'
        '1. Hold two homemade weights (e.g., sandbags, water jugs, backpacks) at shoulder level.\n'
        '2. Lie on a flat surface (floor, bench, or bed).\n'
        '3. Press the weights upward over your chest, keeping them stable.\n'
        '4. Lower with control to the sides of your chest, then press back up.\n'
        '5. Ensure the weights are secure to avoid dropping them.',
  ),
  ExercisePoolEntry(
    id: 'push_homemade_shoulder_press',
    name: 'Homemade Weight Shoulder Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders**\n\n'
        '1. Hold homemade weights at shoulder height with palms facing forward.\n'
        '2. Press them overhead until your arms are fully extended.\n'
        '3. Lower back to shoulder height with control.\n'
        '4. Keep your core tight and avoid arching your back.',
  ),
  ExercisePoolEntry(
    id: 'push_homemade_tricep_extension',
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
        '4. Keep your elbows stationary and close to your head.',
  ),
  ExercisePoolEntry(
    id: 'push_homemade_lateral_raise',
    name: 'Homemade Weight Lateral Raise',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Side Shoulders**\n\n'
        '1. Stand holding homemade weights at your sides, palms facing inward.\n'
        '2. Raise your arms laterally to shoulder height, keeping a slight bend in your elbows.\n'
        '3. Pause at the top, then lower slowly.\n'
        '4. Avoid swinging your body; use strict form.',
  ),
  ExercisePoolEntry(
    id: 'push_homemade_diamond_push_press',
    name: 'Homemade Weight Diamond Push Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Triceps**\n\n'
        '1. Hold two homemade weights close together, with palms facing each other (diamond grip).\n'
        '2. Lie on a flat surface and press the weights upward from chest level.\n'
        '3. Keep the weights pressed together throughout the movement to increase chest activation.\n'
        '4. Lower with control and press back up.',
  ),
];
