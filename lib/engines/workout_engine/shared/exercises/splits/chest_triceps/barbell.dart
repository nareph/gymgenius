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

const List<ExercisePoolEntry> chestTricepsBarbellExercises = [
  ExercisePoolEntry(
    id: 'chest_triceps_bb_decline_bench_press',
    name: 'Decline Barbell Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Chest, Triceps**\n\n'
        '1. Set a decline bench and secure your feet under the pads.\n'
        '2. Lie back and grip the bar slightly wider than shoulder‑width.\n'
        '3. Unrack the bar and lower it to your lower chest, keeping your elbows at a comfortable angle.\n'
        '4. Press the bar back up to full extension, squeezing your lower pectorals.\n'
        '5. Control the descent and avoid bouncing the bar off your chest.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_bb_skull_crushers',
    name: 'Skull Crushers',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
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
        '1. Lie on a flat bench holding a barbell with an overhand grip, arms extended above your chest.\n'
        '2. Keeping your upper arms fixed, bend your elbows to lower the bar towards your forehead (or just behind it).\n'
        '3. Lower until the bar nearly touches your forehead, then extend your arms back to the starting position.\n'
        '4. Keep your elbows stationary throughout the movement to isolate the triceps.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_bb_close_grip_bench_press',
    name: 'Close-Grip Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps, Chest**\n\n'
        '1. Lie on a flat bench with your hands placed shoulder‑width apart or slightly narrower.\n'
        '2. Grip the bar with a shoulder‑width grip, keeping your elbows tucked close to your body.\n'
        '3. Lower the bar to your lower chest, just below the sternum.\n'
        '4. Press back up, focusing on the triceps and inner chest contraction.\n'
        '5. Keep your wrists straight and the bar over your wrists.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_bb_flat_bench_press',
    name: 'Barbell Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.triceps,
      MuscleGroup.shoulders
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders, Triceps**\n\n'
        '1. Lie on a flat bench with your eyes directly under the bar.\n'
        '2. Grip the barbell slightly wider than shoulder‑width, wrap your thumbs around.\n'
        '3. Unrack the bar and hold it above your chest with arms fully extended.\n'
        '4. Lower the bar to your mid‑chest, keeping your elbows at about 75°.\n'
        '5. Drive the bar back up explosively, squeezing your chest at the top.\n'
        '6. Keep your feet planted and your back slightly arched.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_bb_incline_bench_press',
    name: 'Incline Barbell Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Chest, Shoulders**\n\n'
        '1. Set the bench to a 30–45° incline.\n'
        '2. Grip the bar slightly wider than shoulder‑width.\n'
        '3. Unrack and lower the bar to your upper chest, just below the collarbone.\n'
        '4. Press up with control, driving your upper back into the pad.\n'
        '5. Avoid locking your elbows at the top to keep tension on the chest.',
  ),
];
