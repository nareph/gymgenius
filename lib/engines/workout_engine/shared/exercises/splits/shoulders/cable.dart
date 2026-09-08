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

const List<ExercisePoolEntry> shouldersCableExercises = [
  ExercisePoolEntry(
    id: 'shoulders_cable_face_pull',
    name: 'Cable Face Pull',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.back],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Traps**\n\n'
        '1. Attach a rope to a high pulley and set the weight to a light load.\n'
        '2. Stand facing the pulley, grab the rope with an overhand grip, and step back to create tension.\n'
        '3. Pull the rope towards your face, keeping your elbows high (parallel to the floor) and your hands near your ears.\n'
        '4. Squeeze your shoulder blades together at the peak, then slowly return to the starting position.\n'
        '5. This exercise improves posture and shoulder health.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_cable_lateral_raise',
    name: 'Cable Lateral Raise',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Side Shoulders**\n\n'
        '1. Attach a D‑handle to a low pulley on the side of the machine.\n'
        '2. Stand sideways to the machine, holding the handle with the hand farthest from the pulley.\n'
        '3. Keeping a slight bend in your elbow, raise your arm out to the side to shoulder height.\n'
        '4. Pause briefly, then lower with control.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_cable_reverse_fly',
    name: 'Cable Reverse Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.back],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts**\n\n'
        '1. Set two cables at shoulder height and attach D‑handles.\n'
        '2. Stand in the middle, cross the handles in front of you so your arms form an X.\n'
        '3. With a slight bend in your elbows, pull the handles out to the sides, squeezing your shoulder blades together.\n'
        '4. Pause at the peak, then return slowly to the crossed position.\n'
        '5. Keep your back straight and core braced.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_cable_front_raise',
    name: 'Cable Front Raise',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Front Shoulders**\n\n'
        '1. Attach a D‑handle to a low pulley and stand facing the machine.\n'
        '2. Grab the handle with one hand, keeping your arm straight, and raise it forward to shoulder height.\n'
        '3. Pause briefly, then lower with control.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. Keep your core tight to avoid swaying.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_cable_upright_row',
    name: 'Cable Upright Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.biceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Traps**\n\n'
        '1. Attach a straight bar to a low pulley.\n'
        '2. Stand facing the pulley, grip the bar with an overhand grip, hands shoulder‑width apart.\n'
        '3. Pull the bar straight up towards your chin, leading with your elbows.\n'
        '4. Pause at the top, then lower with control.\n'
        '5. Keep the bar close to your body throughout the movement.',
  ),
];
