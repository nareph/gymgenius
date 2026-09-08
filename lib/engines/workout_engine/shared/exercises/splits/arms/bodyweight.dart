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

const List<ExercisePoolEntry> armsBodyweightExercises = [
  ExercisePoolEntry(
    id: 'arms_bw_bench_dips',
    name: 'Bench Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps, Shoulders**\n\n'
        '1. Sit on the edge of a sturdy chair or bench, hands gripping the edge beside your hips, fingers pointing forward.\n'
        '2. Slide your hips off the seat and lower your body by bending your elbows until your arms form a 90° angle.\n'
        '3. Push back up to the starting position, keeping your body close to the bench.\n'
        '4. To increase difficulty, extend your legs further or place weight on your lap.\n'
        '5. Keep your shoulders down and avoid shrugging.',
  ),
  ExercisePoolEntry(
    id: 'arms_bw_close_grip_pushups',
    name: 'Close-Grip Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
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
        '1. Place your hands directly under your chest, with your thumbs and index fingers touching to form a diamond shape.\n'
        '2. Keep your body in a straight line from head to heels, core engaged.\n'
        '3. Lower your chest towards your hands, keeping your elbows close to your body.\n'
        '4. Push back up to the starting position, focusing on the triceps and inner chest squeeze.\n'
        '5. Avoid flaring your elbows out to the sides.',
  ),
  ExercisePoolEntry(
    id: 'arms_bw_tricep_isometric_hold',
    name: 'Tricep Isometric Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Start in a push‑up position, but lower yourself about halfway down, so your elbows are bent at approximately 90°.\n'
        '2. Hold this position, keeping your body straight and core engaged.\n'
        '3. Hold for the prescribed time, maintaining tension in your triceps.\n'
        '4. If this is too difficult, perform the hold with your knees on the floor for support.\n'
        '5. Focus on keeping your elbows tucked close to your body.',
  ),
  ExercisePoolEntry(
    id: 'arms_bw_diamond_pushups',
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
        '1. Place your hands together under your chest, forming a diamond shape with your thumbs and index fingers.\n'
        '2. Keep your elbows close to your body and lower your chest towards your hands.\n'
        '3. Push back up, focusing on the triceps and inner chest squeeze.\n'
        '4. Maintain a straight body line throughout the movement.\n'
        '5. This variation places maximum emphasis on the triceps.',
  ),
  ExercisePoolEntry(
    id: 'arms_bw_plank_shoulder_taps',
    name: 'Plank Shoulder Taps',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
      MuscleGroup.absCore
    ],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps, Core**\n\n'
        '1. Start in a high plank position with your hands directly under your shoulders.\n'
        '2. Lift your right hand off the floor and tap your left shoulder, keeping your hips as still as possible.\n'
        '3. Return your right hand to the floor, then lift your left hand to tap your right shoulder.\n'
        '4. Continue alternating, keeping your core braced to prevent your hips from swaying.\n'
        '5. To reduce difficulty, perform with your knees on the floor.',
  ),
  ExercisePoolEntry(
    id: 'arms_bw_bicep_isometric_hold',
    name: 'Bicep Isometric Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps**\n\n'
        '1. Stand with your arms bent at 90°, flexing your biceps as hard as possible.\n'
        '2. Hold this contracted position, squeezing your biceps with maximum effort.\n'
        '3. Keep your shoulders down and your core engaged.\n'
        '4. Hold for the prescribed time, focusing on the mind‑muscle connection.\n'
        '5. This can also be performed with one arm at a time for more intensity.',
  ),
  ExercisePoolEntry(
    id: 'arms_bw_incline_pushups',
    name: 'Incline Push-Up (Tricep Focus)',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps, Chest**\n\n'
        '1. Place your hands on a sturdy bench, chair, or step, shoulder‑width apart, with your body in a plank position.\n'
        '2. Keep your elbows tucked close to your body as you lower your chest towards the bench.\n'
        '3. Push back up, focusing on the triceps and chest squeeze.\n'
        '4. This incline variation reduces the load, making it suitable for beginners.\n'
        '5. To increase difficulty, lower the height of the surface.',
  ),
  ExercisePoolEntry(
    id: 'arms_bw_forearm_plank',
    name: 'Forearm Plank Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.forearms, MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Forearms, Core**\n\n'
        '1. Lie on your stomach, then prop yourself up on your forearms, with your elbows directly under your shoulders.\n'
        '2. Keep your body in a straight line from head to heels, core engaged.\n'
        '3. Hold this position for the prescribed time, maintaining tension in your forearms and core.\n'
        '4. Avoid letting your hips sag or pike up.\n'
        '5. To increase difficulty, extend your arms further forward or lift one leg.',
  ),
  ExercisePoolEntry(
    id: 'arms_bw_reverse_plank',
    name: 'Reverse Plank Hold',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.glutes],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps, Rear Delts**\n\n'
        '1. Sit on the floor with your legs extended and your hands on the floor behind your hips, fingers pointing towards your body.\n'
        '2. Press through your hands and lift your hips until your body forms a straight line from your shoulders to your heels.\n'
        '3. Keep your chest open, shoulders down, and core engaged.\n'
        '4. Hold for the prescribed time, focusing on triceps and rear delt engagement.\n'
        '5. Avoid letting your hips drop; keep them elevated.',
  ),
  ExercisePoolEntry(
    id: 'arms_bw_wall_handstand_hold',
    name: 'Wall Handstand Hold',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Place your hands on the floor about 6–12 inches from a wall, shoulder‑width apart.\n'
        '2. Kick up into a handstand position, resting your feet against the wall for support.\n'
        '3. Keep your arms straight, shoulders engaged, and core tight.\n'
        '4. Hold for the prescribed time, maintaining a straight body line.\n'
        '5. To reduce difficulty, practice with one foot on the wall and one foot off.',
  ),
];
