import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

const List<ExercisePoolEntry> chestTricepsHomemadeExercises = [
  ExercisePoolEntry(
    id: 'chesttri_homemade_chest_press',
    name: 'Homemade Weight Chest Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps],
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
    id: 'chesttri_homemade_tricep_extension',
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
    id: 'chesttri_homemade_fly',
    name: 'Homemade Weight Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Stretch & Isolation)**\n\n'
        '1. Lie on your back, arms extended above your chest with homemade weights.\n'
        '2. Keep a slight bend in your elbows.\n'
        '3. Lower the weights out to the sides in a wide arc, feeling a stretch.\n'
        '4. Bring them back together, squeezing your chest at the top.\n'
        '5. Move slowly to avoid overextension.',
  ),
  ExercisePoolEntry(
    id: 'chesttri_homemade_skull_crusher',
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
        '1. Lie on your back holding a homemade weight with both hands, arms extended above your chest.\n'
        '2. Keeping your upper arms fixed, lower the weight towards your forehead by bending your elbows.\n'
        '3. Extend your arms back up to the starting position.\n'
        '4. Keep your elbows stationary to isolate the triceps.',
  ),
  ExercisePoolEntry(
    id: 'chesttri_homemade_diamond_push_press',
    name: 'Homemade Weight Diamond Press',
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
