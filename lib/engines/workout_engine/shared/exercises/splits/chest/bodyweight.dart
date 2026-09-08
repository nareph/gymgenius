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

const List<ExercisePoolEntry> chestBodyweightExercises = [
  ExercisePoolEntry(
    id: 'chest_bw_push_up',
    name: 'Standard Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders, Triceps**\n\n'
        '1. Start in a high plank with hands slightly wider than shoulders.\n'
        '2. Keep your body in a straight line from head to heels, core engaged.\n'
        '3. Lower your chest toward the floor until your elbows reach at least 90°.\n'
        '4. Push back up to the starting position, exhaling at the top.\n'
        '5. Perform controlled reps, avoiding any sagging or arching of your back.',
  ),
  ExercisePoolEntry(
    id: 'chest_bw_wide_push_up',
    name: 'Wide Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest (Outer Pecs)**\n\n'
        '1. Place your hands significantly wider than shoulder‑width apart.\n'
        '2. As you lower, your elbows will flare out – this increases chest recruitment.\n'
        '3. Lower until your chest nearly touches the floor, then push up.\n'
        '4. Keep your core tight to prevent your hips from dropping.',
  ),
  ExercisePoolEntry(
    id: 'chest_bw_decline_push_up',
    name: 'Decline Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Chest**\n\n'
        '1. Place your feet on an elevated surface (bench, chair, step).\n'
        '2. Your hands are on the floor, directly under your shoulders.\n'
        '3. Perform a push‑up; the elevated feet shift more weight to your upper chest and shoulders.\n'
        '4. Lower until your chest is a few inches from the floor, then push up.',
  ),
  ExercisePoolEntry(
    id: 'chest_bw_archer_push_up',
    name: 'Archer Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [
      MuscleGroup.triceps,
      MuscleGroup.shoulders,
      MuscleGroup.absCore
    ],
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest (Unilateral Strength)**\n\n'
        '1. Start in a wide push‑up position.\n'
        '2. Shift your weight onto one side, extending the other arm out to the side.\n'
        '3. Lower your chest toward the hand of the working side.\n'
        '4. Push back up, then repeat on the other side.\n'
        '5. This challenges stability and builds unilateral pressing strength.',
  ),
  ExercisePoolEntry(
    id: 'chest_bw_diamond_push_up',
    name: 'Diamond Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps + Inner Chest**\n\n'
        '1. Place your hands close together under your chest, forming a diamond with thumbs and index fingers.\n'
        '2. Keep your elbows close to your body as you lower your chest toward your hands.\n'
        '3. Push back up, focusing on triceps engagement and inner chest squeeze.',
  ),
  ExercisePoolEntry(
    id: 'chest_bw_plyo_push_up',
    name: 'Plyometric Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Power Development**\n\n'
        '1. Start in a standard push‑up position.\n'
        '2. Lower your chest toward the floor, then explode upward so your hands leave the floor.\n'
        '3. Clap your hands (if comfortable) and land softly, absorbing the impact.\n'
        '4. Immediately go into the next rep. This builds explosive strength and fast‑twitch fibers.',
  ),
];
