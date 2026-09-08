import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

const List<ExercisePoolEntry> upperBodyHomemadeExercises = [
  ExercisePoolEntry(
    id: 'upper_homemade_chest_press',
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
    id: 'upper_homemade_bent_over_row',
    name: 'Homemade Weight Bent Over Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.biceps],
    usesWeight: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back**\n\n'
        '1. Bend at the waist with your back flat, knees slightly bent, holding homemade weights in each hand, arms hanging down.\n'
        '2. Pull the weights towards your lower chest, squeezing your shoulder blades together.\n'
        '3. Lower with control back to the starting position.\n'
        '4. Keep your core engaged and avoid rounding your back.',
  ),
  ExercisePoolEntry(
    id: 'upper_homemade_shoulder_press',
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
    id: 'upper_homemade_bicep_curl',
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
        '1. Stand with feet shoulder‑width apart, holding homemade weights at your sides, palms facing forward.\n'
        '2. Keeping your elbows fixed, curl the weights up towards your shoulders.\n'
        '3. Squeeze your biceps at the top, then lower slowly.\n'
        '4. Avoid swinging your body – use strict form.',
  ),
  ExercisePoolEntry(
    id: 'upper_homemade_tricep_extension',
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
];
