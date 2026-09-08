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

const List<ExercisePoolEntry> pushBodyweightExercises = [
  ExercisePoolEntry(
    id: 'push_bw_push_ups',
    name: 'Standard Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders, Triceps**\n\n'
        '1. Start in a high plank position with your hands slightly wider than shoulder‑width.\n'
        '2. Keep your body in a straight line from head to heels, core engaged.\n'
        '3. Lower your chest towards the floor until your elbows reach at least 90°.\n'
        '4. Push back up to the starting position, exhaling at the top.\n'
        '5. Perform controlled reps without sagging your hips or arching your back.',
  ),
  ExercisePoolEntry(
    id: 'push_bw_diamond_push_ups',
    name: 'Diamond Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps, Inner Chest**\n\n'
        '1. Place your hands close together under your chest, forming a diamond shape with your thumbs and index fingers.\n'
        '2. Keep your elbows close to your body as you lower your chest towards your hands.\n'
        '3. Push back up, focusing on the triceps and the inner chest squeeze.\n'
        '4. Maintain a straight body line throughout.',
  ),
  ExercisePoolEntry(
    id: 'push_bw_pike_push_ups',
    name: 'Pike Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Start in a downward‑dog position with your hips high, hands shoulder‑width apart, and feet on the floor.\n'
        '2. Bend your elbows to lower the top of your head towards the floor, keeping your body in an inverted V shape.\n'
        '3. Press back up to the starting position, focusing on the shoulder muscles.\n'
        '4. Keep your core braced and your weight shifted forward onto your hands.',
  ),
  ExercisePoolEntry(
    id: 'push_bw_decline_push_ups',
    name: 'Decline Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Chest, Shoulders**\n\n'
        '1. Place your feet on an elevated surface (bench, step, or chair) and your hands on the floor, shoulder‑width apart.\n'
        '2. Perform a push‑up, lowering your chest towards the floor until it nearly touches.\n'
        '3. Push back up, keeping your body straight. The elevated feet increase the load on your upper chest and shoulders.',
  ),
  ExercisePoolEntry(
    id: 'push_bw_wide_push_ups',
    name: 'Wide Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders**\n\n'
        '1. Place your hands significantly wider than shoulder‑width apart.\n'
        '2. As you lower your chest, your elbows will flare out – this increases chest activation.\n'
        '3. Lower until your chest is a few inches from the floor, then push back up.\n'
        '4. Keep your core tight to prevent your hips from dropping.',
  ),
  ExercisePoolEntry(
    id: 'push_bw_plyometric_push_ups',
    name: 'Plyometric Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders, Triceps (Power)**\n\n'
        '1. Start in a standard push‑up position.\n'
        '2. Lower your chest towards the floor, then explode upward so your hands leave the ground.\n'
        '3. Clap your hands (if comfortable) and land softly, absorbing the impact.\n'
        '4. Immediately go into the next rep. This builds explosive strength and fast‑twitch fibers.',
  ),
  ExercisePoolEntry(
    id: 'push_bw_archer_push_ups',
    name: 'Archer Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders (Unilateral)**\n\n'
        '1. Start in a wide push‑up position.\n'
        '2. Shift your weight onto one side, extending the other arm out to the side.\n'
        '3. Lower your chest towards the hand of the working side, keeping your body straight.\n'
        '4. Push back up, then alternate sides. This builds unilateral chest strength and stability.',
  ),
];
