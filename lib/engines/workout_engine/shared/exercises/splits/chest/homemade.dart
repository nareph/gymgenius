import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

const List<ExercisePoolEntry> chestHomemadeExercises = [
  ExercisePoolEntry(
    id: 'chest_homemade_chest_press',
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
    description: '**Target: Chest (DIY)**\n\n'
        '1. Hold two homemade weights (e.g., sandbags, water jugs, backpacks) at shoulder level.\n'
        '2. Lie on a flat surface (floor, bench, or bed).\n'
        '3. Press the weights upward over your chest, keeping them stable.\n'
        '4. Lower with control to the sides of your chest, then press back up.\n'
        '5. Ensure the weights are secure to avoid dropping them.',
  ),
  ExercisePoolEntry(
    id: 'chest_homemade_fly',
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
    description: '**Target: Chest (DIY Stretch)**\n\n'
        '1. Lie on your back, arms extended above your chest with homemade weights.\n'
        '2. Keep a slight bend in your elbows.\n'
        '3. Lower the weights out to the sides in a wide arc, feeling a stretch.\n'
        '4. Bring them back together, squeezing your chest at the top.\n'
        '5. Move slowly to avoid overextension.',
  ),
  ExercisePoolEntry(
    id: 'chest_homemade_pullover',
    name: 'Homemade Weight Pullover',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.back],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest + Lats (DIY)**\n\n'
        '1. Lie across a bench (or on the floor) with only your upper back supported.\n'
        '2. Hold a homemade weight with both hands overhead, arms extended.\n'
        '3. Lower the weight behind your head in a controlled arc.\n'
        '4. Pull it back up to the starting position, feeling the stretch in your chest and lats.',
  ),
  ExercisePoolEntry(
    id: 'chest_homemade_floor_press',
    name: 'Homemade Weight Floor Press',
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
    description: '**Target: Chest (Floor Press DIY)**\n\n'
        '1. Lie on the floor with homemade weights held above your chest.\n'
        '2. Lower them until your upper arms touch the floor, keeping elbows at 45°.\n'
        '3. Press back up, focusing on the chest contraction.\n'
        '4. This limits range of motion, protecting shoulders.',
  ),
  ExercisePoolEntry(
    id: 'chest_homemade_incline_press',
    name: 'Homemade Weight Incline Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Chest (DIY)**\n\n'
        '1. Lean back on an incline surface (e.g., a pile of pillows or a slanted board).\n'
        '2. Hold homemade weights at shoulder level.\n'
        '3. Press them upward at an angle, squeezing your upper chest.\n'
        '4. Lower with control and repeat.',
  ),
];
