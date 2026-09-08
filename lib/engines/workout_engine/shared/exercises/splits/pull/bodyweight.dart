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

const List<ExercisePoolEntry> pullBodyweightExercises = [
  ExercisePoolEntry(
    id: 'pull_bw_supermans',
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
        '1. Lie face down on the floor with your arms extended forward and legs straight.\n'
        '2. Simultaneously lift your arms, chest, and legs off the floor as high as possible.\n'
        '3. Squeeze your glutes and lower back muscles at the top, hold for 2 seconds.\n'
        '4. Lower back to the starting position with control.\n'
        '5. Keep your neck neutral by looking down at the floor.',
  ),
  ExercisePoolEntry(
    id: 'pull_bw_reverse_snow_angels',
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
        '1. Lie face down on the floor with your arms extended out to the sides at shoulder height, forming a "T" shape.\n'
        '2. Keeping your arms straight, raise them off the floor as high as possible, squeezing your shoulder blades together.\n'
        '3. Slowly rotate your arms backward and upward, as if making a snow angel in reverse, until your hands are near your hips.\n'
        '4. Reverse the movement to return to the starting position.\n'
        '5. Perform the movement slowly and with control for maximum muscle engagement.',
  ),
  ExercisePoolEntry(
    id: 'pull_bw_prone_y_raises',
    name: 'Prone Y-Raises',
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
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Traps, Rear Delts**\n\n'
        '1. Lie face down on the floor with your arms extended in a "Y" position, thumbs pointing up.\n'
        '2. Lift your arms off the floor, squeezing your shoulder blades together and down.\n'
        '3. Hold at the top for 1‑2 seconds, then lower slowly.\n'
        '4. Keep your neck relaxed and your chest on the floor.\n'
        '5. This exercise specifically targets the lower trapezius and improves shoulder posture.',
  ),
  ExercisePoolEntry(
    id: 'pull_bw_prone_t_raises',
    name: 'Prone T-Raises',
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
    description: '**Target: Mid Traps, Rear Delts**\n\n'
        '1. Lie face down on the floor with your arms extended straight out to the sides, thumbs pointing up (T position).\n'
        '2. Lift your arms off the floor, squeezing your shoulder blades together.\n'
        '3. Hold at the top for 1‑2 seconds, then lower slowly.\n'
        '4. Keep your chest and core engaged to maintain stability.\n'
        '5. This strengthens the mid‑traps and rear deltoids, essential for good posture.',
  ),
  ExercisePoolEntry(
    id: 'pull_bw_prone_i_raises',
    name: 'Prone I-Raises',
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
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Traps, Rhomboids**\n\n'
        '1. Lie face down on the floor with your arms extended straight overhead, thumbs pointing up (I position).\n'
        '2. Lift your arms off the floor, squeezing your shoulder blades together and down.\n'
        '3. Hold at the top for 1‑2 seconds, then lower slowly.\n'
        '4. Keep your neck relaxed and your chest on the floor.\n'
        '5. This exercise strengthens the lower traps and improves shoulder stability.',
  ),
  ExercisePoolEntry(
    id: 'pull_bw_prone_w_raises',
    name: 'Prone W-Raises',
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
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Mid/Lower Traps, Rhomboids**\n\n'
        '1. Lie face down on the floor with your arms bent at 90°, elbows in line with your shoulders (W position).\n'
        '2. Lift your arms off the floor, squeezing your shoulder blades together and down.\n'
        '3. Hold at the top for 1‑2 seconds, then lower slowly.\n'
        '4. Keep your neck relaxed and your chest on the floor.\n'
        '5. This variation targets the mid‑lower traps and rhomboids for better posture.',
  ),
  ExercisePoolEntry(
    id: 'pull_bw_scapular_push_ups',
    name: 'Scapular Push-ups',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Traps, Serratus Anterior**\n\n'
        '1. Start in a high plank position with your arms straight, hands directly under your shoulders.\n'
        '2. Without bending your elbows, push your upper back towards the ceiling by protracting your shoulder blades (rounding your upper back).\n'
        '3. Then, retract your shoulder blades by pulling your chest towards the floor, squeezing your traps.\n'
        '4. Move only your shoulder blades, keeping your arms and body straight.\n'
        '5. This small movement improves scapular control and strengthens the traps.',
  ),
  ExercisePoolEntry(
    id: 'pull_bw_table_rows',
    name: 'Table Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Lie under a sturdy table or bar, grip the edge with an overhand grip, hands shoulder‑width apart.\n'
        '2. With your body straight and heels on the floor, pull your chest towards the table by driving your elbows back.\n'
        '3. Squeeze your shoulder blades together at the top, then lower your body with control back to the starting position.\n'
        '4. Keep your core tight to maintain a straight body line.\n'
        '5. To increase difficulty, elevate your feet or use a lower bar.',
  ),
  ExercisePoolEntry(
    id: 'pull_bw_door_frame_rows',
    name: 'Door Frame Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Stand facing a sturdy door frame, grip both sides at chest height with an overhand grip.\n'
        '2. Lean back with your body straight and heels on the floor, arms fully extended.\n'
        '3. Pull your chest toward the door frame by driving your elbows back, squeezing your shoulder blades.\n'
        '4. Lower with control to the starting position.\n'
        '5. Keep your core tight to maintain a straight body line.',
  ),
  ExercisePoolEntry(
    id: 'pull_bw_towel_rows',
    name: 'Towel Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.forearms],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps, Forearms**\n\n'
        '1. Loop a towel around a sturdy post or door handle, grab both ends with an overhand grip.\n'
        '2. Lean back, keeping your body straight, arms extended.\n'
        '3. Pull your torso toward the anchor point by driving your elbows back, squeezing your shoulder blades.\n'
        '4. Return slowly with control, keeping tension in the towel.\n'
        '5. This also strengthens grip and forearms.',
  ),
  ExercisePoolEntry(
    id: 'pull_bw_inverted_row_feet_elevated',
    name: 'Feet-Elevated Inverted Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Set up an inverted row station (bar or table edge) with your feet elevated on a bench or chair.\n'
        '2. Grip the bar with an overhand grip, hands shoulder‑width apart, body straight.\n'
        '3. Pull your chest to the bar, squeezing your shoulder blades.\n'
        '4. Lower with control to full extension.\n'
        '5. The elevated feet increase the load, making the exercise more challenging.',
  ),
  ExercisePoolEntry(
    id: 'pull_bw_superman_hold',
    name: 'Superman Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Glutes**\n\n'
        '1. Lie face down on the floor with your arms extended forward and legs straight.\n'
        '2. Lift your arms, chest, and legs off the floor simultaneously, squeezing your glutes and lower back.\n'
        '3. Hold this position for the prescribed time, maintaining tension.\n'
        '4. Keep your neck neutral by looking down.\n'
        '5. Breathe steadily and avoid holding your breath.',
  ),
  ExercisePoolEntry(
    id: 'pull_bw_bird_dog_row',
    name: 'Bird Dog Row Hold',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.absCore, MuscleGroup.shoulders],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Glutes, Core**\n\n'
        '1. Start on all fours with hands under shoulders and knees under hips.\n'
        '2. Extend your right arm forward and left leg back, keeping your hips square and spine neutral.\n'
        '3. Hold this position for the prescribed time, maintaining stability.\n'
        '4. Lower with control, then switch sides.\n'
        '5. This improves balance, core strength, and posterior chain activation.',
  ),
  ExercisePoolEntry(
    id: 'pull_bw_wall_angels',
    name: 'Wall Angels',
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
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Back, Rear Delts**\n\n'
        '1. Stand with your back flat against a wall, feet about 6 inches from the wall.\n'
        '2. Place your arms against the wall in a "W" shape (elbows bent at 90°, hands at shoulder height).\n'
        '3. Slowly slide your arms overhead, keeping your wrists and elbows in contact with the wall.\n'
        '4. Return to the "W" position with control.\n'
        '5. This improves shoulder mobility and strengthens the upper back.',
  ),
];
