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

const List<ExercisePoolEntry> pullCableExercises = [
  ExercisePoolEntry(
    id: 'pull_cable_lat_pulldowns',
    name: 'Lat Pulldown',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Sit at the lat pulldown machine, secure your thighs under the pads, and grip the bar with an overhand grip slightly wider than shoulder‑width.\n'
        '2. Lean back slightly, keep your chest up, and pull the bar down to your upper chest, driving your elbows down and back.\n'
        '3. Squeeze your lats at the bottom, then let the bar rise slowly back to the starting position.\n'
        '4. Control the movement throughout; do not use momentum.\n'
        '5. Variations: use a wide grip, neutral grip, or underhand grip for different muscle emphasis.',
  ),
  ExercisePoolEntry(
    id: 'pull_cable_single_arm_lat_pulldown',
    name: 'Single-Arm Lat Pulldown',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats, Biceps**\n\n'
        '1. Attach a single D‑handle to a high pulley.\n'
        '2. Sit on the machine, grab the handle with one hand, and lean back slightly.\n'
        '3. Pull the handle down towards your hip, driving your elbow back and squeezing your lat.\n'
        '4. Return slowly with control.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'pull_cable_seated_cable_row',
    name: 'Cable Seated Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
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
    id: 'pull_cable_face_pulls',
    name: 'Cable Face Pull',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.back],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Upper Back**\n\n'
        '1. Attach a rope to a high pulley and set the weight to a light to moderate load.\n'
        '2. Step back, grab the rope with an overhand grip, and stand with your arms extended.\n'
        '3. Pull the rope towards your face, keeping your elbows high (parallel to the floor) and your hands near your ears.\n'
        '4. Squeeze your shoulder blades together at the peak, then slowly return to the starting position.\n'
        '5. This exercise is excellent for shoulder health and posture.',
  ),
  ExercisePoolEntry(
    id: 'pull_cable_curls',
    name: 'Cable Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps**\n\n'
        '1. Attach a straight bar to a low pulley on a cable machine.\n'
        '2. Stand facing the machine, grip the bar with an underhand grip, hands shoulder‑width apart.\n'
        '3. Step back to create tension, keeping your elbows pinned to your sides.\n'
        '4. Curl the bar up towards your shoulders, squeezing your biceps at the top.\n'
        '5. Lower with control back to the starting position, maintaining tension throughout.',
  ),
];
