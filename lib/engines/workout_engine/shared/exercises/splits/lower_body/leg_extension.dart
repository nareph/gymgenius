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

const List<ExercisePoolEntry> lowerBodyLegExtensionExercises = [
  ExercisePoolEntry(
    id: 'lower_ext_leg_extensions',
    name: 'Leg Extensions',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legExtensionMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps**\n\n'
        '1. Sit on the leg extension machine with your back against the pad and your shins behind the ankle pad.\n'
        '2. Grasp the handles for stability, keep your knees aligned with the machine\'s pivot.\n'
        '3. Extend your legs until they are straight, squeezing your quads at the top.\n'
        '4. Lower the weight with control back to the starting position.\n'
        '5. Avoid swinging; use a controlled tempo.',
  ),
  ExercisePoolEntry(
    id: 'lower_ext_single_leg_extension',
    name: 'Single-Leg Extension',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.legExtensionMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps (Unilateral)**\n\n'
        '1. Use the leg extension machine, but only with one leg, the other resting.\n'
        '2. Extend the working leg fully, squeezing the quad.\n'
        '3. Lower with control.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. This helps address strength imbalances.',
  ),
  ExercisePoolEntry(
    id: 'lower_ext_iso_hold',
    name: 'Leg Extension Isometric Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.legExtensionMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [],
    usesWeight: true,
    isTimed: true,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.openChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps**\n\n'
        '1. Perform a standard leg extension, but hold the fully extended position for 3–5 seconds.\n'
        '2. Squeeze your quads hard during the hold.\n'
        '3. Lower with control.\n'
        '4. This increases time under tension and improves neuromuscular connection.\n'
        '5. Use a moderate weight that allows you to maintain the hold.',
  ),
  ExercisePoolEntry(
    id: 'lower_ext_partial_reps',
    name: 'Leg Extension Partial Reps',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.legExtensionMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps**\n\n'
        '1. Perform leg extensions but only in the top half of the range of motion (from about 90° to full extension).\n'
        '2. Keep constant tension on the quads by not fully lowering the weight.\n'
        '3. Squeeze at the top.\n'
        '4. Perform reps without locking out completely to maintain continuous tension.\n'
        '5. This is effective for adding volume and stimulating growth.',
  ),
  ExercisePoolEntry(
    id: 'lower_ext_drop_set',
    name: 'Leg Extension Drop Set',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.legExtensionMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps**\n\n'
        '1. Perform a set of leg extensions to failure with a heavy weight.\n'
        '2. Immediately reduce the weight by about 20–30% and perform another set to failure.\n'
        '3. Reduce again and perform a third set to failure.\n'
        '4. This technique maximises muscle fatigue and hypertrophy.\n'
        '5. Rest appropriately between drop sets.',
  ),
];
