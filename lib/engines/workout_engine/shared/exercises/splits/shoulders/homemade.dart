import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

const List<ExercisePoolEntry> shouldersHomemadeExercises = [
  ExercisePoolEntry(
    id: 'shoulders_homemade_press',
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
        '1. Stand or sit with a homemade weight (e.g., water jug, sandbag) in each hand at shoulder height, palms forward.\n'
        '2. Press the weights overhead until your arms are fully extended, keeping your core tight.\n'
        '3. Pause briefly, then lower with control back to shoulder height.\n'
        '4. Maintain a stable posture and avoid arching your back.\n'
        '5. Ensure the weights are secure to prevent accidents.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_homemade_lateral_raise',
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
        '1. Stand with feet shoulder‑width apart, holding a homemade weight in each hand at your sides.\n'
        '2. Keeping a slight bend in your elbows, raise your arms out to the sides to shoulder height.\n'
        '3. Pause at the top, then lower slowly with control.\n'
        '4. Avoid swinging your body; use strict form.\n'
        '5. Use light weights to focus on the contraction.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_homemade_front_raise',
    name: 'Homemade Weight Front Raise',
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
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Front Shoulders**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a homemade weight in each hand in front of your thighs.\n'
        '2. Keep your arms straight and raise them forward to shoulder height.\n'
        '3. Pause briefly, then lower with control.\n'
        '4. Maintain a steady tempo and avoid using momentum.\n'
        '5. For more intensity, perform one arm at a time.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_homemade_upright_row',
    name: 'Homemade Weight Upright Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.traps, MuscleGroup.biceps],
    usesWeight: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Traps**\n\n'
        '1. Stand upright, holding a homemade weight in each hand in front of your thighs, palms facing your body.\n'
        '2. Pull the weights straight up towards your chin, leading with your elbows.\n'
        '3. Keep the weights close to your body and pause at the top.\n'
        '4. Lower with control back to the starting position.\n'
        '5. Avoid using excessive weight to prevent shoulder impingement.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_homemade_arnold_press',
    name: 'Homemade Weight Arnold Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders (all heads), Triceps**\n\n'
        '1. Start with homemade weights held in front of your shoulders, palms facing you.\n'
        '2. Press the weights overhead while rotating your palms to face forward at the top.\n'
        '3. Squeeze your shoulders, then reverse the rotation as you lower back down.\n'
        '4. Keep a smooth and controlled tempo.\n'
        '5. This variation works all three deltoid heads.',
  ),
];
