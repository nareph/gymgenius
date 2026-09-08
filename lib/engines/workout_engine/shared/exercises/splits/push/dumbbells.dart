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

const List<ExercisePoolEntry> pushDumbbellExercises = [
  ExercisePoolEntry(
    id: 'push_db_dumbbell_bench_press',
    name: 'Dumbbell Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders, Triceps**\n\n'
        '1. Lie on a flat bench with a dumbbell in each hand, resting them on your thighs.\n'
        '2. Kick the weights up to shoulder height, palms facing forward.\n'
        '3. Press the dumbbells upward until your arms are fully extended, bringing them close together at the top.\n'
        '4. Lower them slowly to the sides of your chest, keeping your elbows at about 45°.\n'
        '5. Press back up explosively, squeezing your chest at the top.',
  ),
  ExercisePoolEntry(
    id: 'push_db_incline_dumbbell_press',
    name: 'Incline Dumbbell Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Chest, Shoulders**\n\n'
        '1. Set the bench to a 30–45° incline.\n'
        '2. Lie back with dumbbells, press them above your chest.\n'
        '3. Lower them to the sides of your upper chest, keep elbows moderately flared.\n'
        '4. Press up, focusing on the upper pectoral squeeze at the top.',
  ),
  ExercisePoolEntry(
    id: 'push_db_shoulder_press',
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
        '1. Sit on a bench with back support, holding dumbbells at shoulder height with palms facing forward.\n'
        '2. Press the weights overhead until your arms are fully extended, keeping them close together.\n'
        '3. Pause briefly at the top, then lower them back to shoulder height with control.\n'
        '4. Keep your core braced and avoid arching your back.',
  ),
  ExercisePoolEntry(
    id: 'push_db_arnold_press',
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
        '1. Sit on a bench with dumbbells held in front of your shoulders, palms facing you.\n'
        '2. Press the weights upward while rotating your palms to face forward at the top.\n'
        '3. Squeeze your shoulders at the top, then reverse the motion as you lower back down.\n'
        '4. Maintain a smooth, controlled tempo throughout.',
  ),
  ExercisePoolEntry(
    id: 'push_db_lateral_raises',
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
        '1. Stand with feet shoulder‑width apart, dumbbells at your sides, palms facing inward.\n'
        '2. Keep a slight bend in your elbows and raise the dumbbells laterally to shoulder height.\n'
        '3. Pause briefly at the top, then lower them slowly back to the starting position.\n'
        '4. Avoid swinging your body; use strict form.',
  ),
  ExercisePoolEntry(
    id: 'push_db_overhead_tricep_extension',
    name: 'Overhead Tricep Extension',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
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
        '1. Hold a dumbbell with both hands overhead, arms extended.\n'
        '2. Keeping your upper arms close to your head, bend your elbows to lower the dumbbell behind your head.\n'
        '3. Extend your arms back up to the starting position, squeezing your triceps.\n'
        '4. Keep your elbows stationary throughout the movement.',
  ),
];
