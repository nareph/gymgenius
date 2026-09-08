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

const List<ExercisePoolEntry> chestTricepsDumbbellExercises = [
  ExercisePoolEntry(
    id: 'chest_triceps_db_dumbbell_bench_press',
    name: 'Dumbbell Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.triceps,
      MuscleGroup.shoulders
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
    id: 'chest_triceps_db_incline_dumbbell_press',
    name: 'Incline Dumbbell Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
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
    id: 'chest_triceps_db_overhead_tricep_extension',
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
  ExercisePoolEntry(
    id: 'chest_triceps_db_floor_press',
    name: 'Dumbbell Floor Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Triceps**\n\n'
        '1. Lie on the floor with a dumbbell in each hand, resting on your chest.\n'
        '2. Press the dumbbells upward until your arms are extended.\n'
        '3. Lower them with control until your upper arms touch the floor.\n'
        '4. Press back up, focusing on chest and triceps engagement.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_db_kickbacks',
    name: 'Dumbbell Kickbacks',
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
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Bend forward at the waist, keeping your back flat, holding a dumbbell in one hand.\n'
        '2. Keep your upper arm parallel to the floor and fixed, extend your forearm backward until your arm is straight.\n'
        '3. Squeeze your triceps at the top, then lower with control.\n'
        '4. Complete all reps on one side before switching.',
  ),
];
