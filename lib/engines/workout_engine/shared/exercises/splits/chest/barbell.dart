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

const List<ExercisePoolEntry> chestBarbellExercises = [
  ExercisePoolEntry(
    id: 'chest_bb_flat_press',
    name: 'Barbell Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Overall Mass)**\n\n'
        '1. Lie on a flat bench, eyes directly under the bar.\n'
        '2. Grip the bar slightly wider than shoulder‑width, wrap your thumbs around.\n'
        '3. Unrack the bar and hold it above your chest with arms extended.\n'
        '4. Lower the bar to your mid‑chest while keeping your elbows at about 75°.\n'
        '5. Drive the bar back up explosively, squeezing your chest.\n'
        '6. Keep your feet planted and your back slightly arched.',
  ),
  ExercisePoolEntry(
    id: 'chest_bb_incline_press',
    name: 'Incline Barbell Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Upper Chest**\n\n'
        '1. Set the bench to a 30–45° incline.\n'
        '2. Grip the bar slightly wider than shoulder‑width.\n'
        '3. Unrack and lower the bar to your upper chest, just below the collarbone.\n'
        '4. Press up with control, driving your upper back into the pad.\n'
        '5. Avoid locking your elbows at the top to keep tension on the chest.',
  ),
  ExercisePoolEntry(
    id: 'chest_bb_close_press',
    name: 'Close Grip Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest + Triceps**\n\n'
        '1. Lie on a flat bench with hands shoulder‑width apart or slightly narrower.\n'
        '2. Lower the bar to your lower chest while keeping your elbows tucked close to your torso.\n'
        '3. Press back up, focusing on the triceps and inner chest.\n'
        '4. Keep your wrists straight and the bar over your wrists.',
  ),
  ExercisePoolEntry(
    id: 'chest_bb_floor_press',
    name: 'Barbell Floor Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Lockout Strength)**\n\n'
        '1. Lie on the floor with a barbell held above your chest.\n'
        '2. Lower the bar until your upper arms touch the floor.\n'
        '3. Pause briefly, then press back up with maximal force.\n'
        '4. This limits shoulder range, reducing impingement risk while building lockout power.',
  ),
  ExercisePoolEntry(
    id: 'chest_bb_spoto_press',
    name: 'Spoto Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Pause & Control)**\n\n'
        '1. Perform a standard bench press setup.\n'
        '2. Lower the bar until it is 1–2 inches above your chest.\n'
        '3. Hold that position for a full second, maintaining tightness.\n'
        '4. Press the bar back up without bouncing.\n'
        '5. This variation improves technique and strength off the chest.',
  ),
];
