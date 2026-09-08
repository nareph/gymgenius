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

const List<ExercisePoolEntry> upperBodyBodyweightExercises = [
  ExercisePoolEntry(
    id: 'upper_bw_push_ups',
    name: 'Standard Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps
    ],
    secondaryMuscles: [MuscleGroup.absCore],
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
    id: 'upper_bw_wide_push_ups',
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
    id: 'upper_bw_diamond_push_ups',
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
    id: 'upper_bw_pike_push_ups',
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
    id: 'upper_bw_bench_dips',
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
        '1. Sit on the edge of a sturdy chair or bench, hands gripping the edge beside your hips.\n'
        '2. Slide your hips off the seat and lower your body by bending your elbows until your arms form a 90° angle.\n'
        '3. Push back up to the starting position, keeping your body close to the bench.\n'
        '4. To increase difficulty, extend your legs further or place weight on your lap.',
  ),
  ExercisePoolEntry(
    id: 'upper_bw_plank_shoulder_taps',
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
        '1. Start in a high plank position, hands directly under your shoulders, body in a straight line.\n'
        '2. Lift your right hand off the floor and tap your left shoulder, while keeping your hips as still as possible.\n'
        '3. Return your right hand to the floor, then repeat with your left hand tapping your right shoulder.\n'
        '4. Continue alternating, maintaining a stable core and avoiding any swaying.',
  ),
  ExercisePoolEntry(
    id: 'upper_bw_supermans',
    name: 'Supermans',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Glutes**\n\n'
        '1. Lie face down on the floor with your arms extended forward, legs straight.\n'
        '2. Simultaneously lift your chest, arms, and legs off the floor, squeezing your glutes and lower back.\n'
        '3. Hold the contraction for 1–2 seconds, then slowly lower back to the starting position.\n'
        '4. Keep your neck in a neutral position by looking slightly down.',
  ),
  ExercisePoolEntry(
    id: 'upper_bw_reverse_snow_angels',
    name: 'Reverse Snow Angels',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Upper Back**\n\n'
        '1. Lie face down on the floor with your arms extended out to the sides, palms facing down.\n'
        '2. Keep your arms straight and raise them up as high as you can while squeezing your shoulder blades together.\n'
        '3. Lower them back down with control, making a slow "snow angel" motion.\n'
        '4. Keep your chest and head slightly off the floor.',
  ),
];
