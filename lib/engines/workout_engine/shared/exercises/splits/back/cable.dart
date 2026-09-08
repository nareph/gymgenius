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

const List<ExercisePoolEntry> backCableExercises = [
  ExercisePoolEntry(
    id: 'back_cable_seated_row',
    name: 'Cable Seated Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Sit at a cable row station with your feet braced against the footplates, knees slightly bent.\n'
        '2. Grip the handle (V‑grip or wide bar) and keep your back straight, chest up.\n'
        '3. Pull the handle towards your abdomen, driving your elbows back and squeezing your shoulder blades together.\n'
        '4. Pause at the peak contraction, then slowly return to the starting position, feeling the stretch in your lats.\n'
        '5. Avoid leaning back excessively; keep your torso relatively still.',
  ),
  ExercisePoolEntry(
    id: 'back_cable_lat_pulldown',
    name: 'Lat Pulldown',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats, Biceps**\n\n'
        '1. Sit at the lat pulldown machine, secure your thighs under the pads, and grip the bar with an overhand grip slightly wider than shoulder‑width.\n'
        '2. Lean back slightly, keep your chest up, and pull the bar down to your upper chest, driving your elbows down and back.\n'
        '3. Squeeze your lats at the bottom, then let the bar rise slowly back to the starting position.\n'
        '4. Control the movement throughout; do not use momentum.\n'
        '5. Variations: underhand grip (chin‑up style) or neutral grip with a V‑bar.',
  ),
  ExercisePoolEntry(
    id: 'back_cable_face_pull',
    name: 'Cable Face Pull',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.traps],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Traps**\n\n'
        '1. Attach a rope to a high pulley and set the weight to a light to moderate load.\n'
        '2. Step back, grab the rope with an overhand grip, and stand with your arms extended.\n'
        '3. Pull the rope towards your face, keeping your elbows high (parallel to the floor) and your hands near your ears.\n'
        '4. Squeeze your shoulder blades together at the peak, then slowly return to the starting position.\n'
        '5. This exercise is excellent for shoulder health and posture.',
  ),
  ExercisePoolEntry(
    id: 'back_cable_straight_arm_pulldown',
    name: 'Cable Straight-Arm Pulldown',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats**\n\n'
        '1. Attach a straight bar or rope to a high pulley.\n'
        '2. Stand facing the machine, take a step back, and grab the bar with an overhand grip, arms straight.\n'
        '3. Keeping your arms straight, push the bar down towards your thighs by hinging at the shoulders, squeezing your lats.\n'
        '4. Pause at the bottom, then slowly return to the starting position.\n'
        '5. Keep a slight bend in your elbows throughout to maintain tension on the lats.',
  ),
  ExercisePoolEntry(
    id: 'back_cable_pullover',
    name: 'Cable Pullover',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.back, MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats, Chest**\n\n'
        '1. Attach a rope to a low pulley and set the weight to a moderate load.\n'
        '2. Stand facing away from the machine, grab the rope with both hands, and extend your arms overhead.\n'
        '3. Keeping your arms straight, pull the rope down and forward towards your hips, using your lats.\n'
        '4. Squeeze your lats at the bottom, then slowly return to the starting position.\n'
        '5. Maintain a slight bend in your elbows to keep tension on the lats.',
  ),
];
