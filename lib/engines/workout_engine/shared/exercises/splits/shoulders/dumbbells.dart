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

const List<ExercisePoolEntry> shouldersDumbbellExercises = [
  ExercisePoolEntry(
    id: 'shoulders_core_db_shoulder_press',
    name: 'Dumbbell Shoulder Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Sit on a bench with back support, holding a dumbbell in each hand at shoulder height, palms facing forward.\n'
        '2. Keep your core tight and press the dumbbells overhead until your arms are fully extended.\n'
        '3. Pause briefly at the top, then lower the weights back to shoulder height with control.\n'
        '4. Avoid arching your back; keep your shoulder blades retracted.\n'
        '5. Use a controlled tempo for maximum muscle engagement.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_db_arnold_press',
    name: 'Arnold Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders (all heads), Triceps**\n\n'
        '1. Sit on a bench with back support, holding dumbbells in front of your shoulders with palms facing you.\n'
        '2. Press the dumbbells upward while rotating your palms to face forward at the top.\n'
        '3. Squeeze your shoulders at the top, then reverse the motion as you lower back down.\n'
        '4. Maintain a smooth, controlled tempo throughout.\n'
        '5. This variation targets all three deltoid heads.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_db_lateral_raises',
    name: 'Lateral Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Side Shoulders**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a dumbbell in each hand at your sides, palms facing inward.\n'
        '2. Keep a slight bend in your elbows and raise the dumbbells laterally to shoulder height.\n'
        '3. Pause briefly at the top, then lower them slowly back to the starting position.\n'
        '4. Avoid swinging your body; use strict form.\n'
        '5. Use light weight to focus on the contraction.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_db_front_raises',
    name: 'Front Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Front Shoulders**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a dumbbell in each hand in front of your thighs, palms facing your body.\n'
        '2. Keep your arms straight and raise them forward to shoulder height.\n'
        '3. Pause briefly, then lower with control.\n'
        '4. Avoid using momentum; keep the movement controlled.\n'
        '5. To increase intensity, perform one arm at a time.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_db_upright_rows',
    name: 'Upright Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
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
        '1. Stand upright, holding a dumbbell in each hand in front of your thighs, palms facing your body.\n'
        '2. Pull the dumbbells straight up towards your chin, leading with your elbows.\n'
        '3. Keep the weights close to your body and pause at the top.\n'
        '4. Lower with control back to the starting position.\n'
        '5. Avoid excessive weight to prevent shoulder impingement.',
  ),
];
