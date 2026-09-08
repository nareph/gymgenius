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

const List<ExercisePoolEntry> backBicepsBodyweightExercises = [
  ExercisePoolEntry(
    id: 'back_biceps_bw_supermans',
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
    id: 'back_biceps_bw_prone_y_raises',
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
    id: 'back_biceps_bw_prone_t_raises',
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
    id: 'back_biceps_bw_reverse_snow_angels',
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
    id: 'back_biceps_bw_scapular_push_ups',
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
    id: 'back_biceps_bw_prone_i_raises',
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
    id: 'back_biceps_bw_prone_w_raises',
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
    id: 'back_biceps_bw_table_rows',
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
];
