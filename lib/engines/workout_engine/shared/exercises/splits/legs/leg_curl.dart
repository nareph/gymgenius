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

const List<ExercisePoolEntry> legsLegCurlExercises = [
  ExercisePoolEntry(
    id: 'legs_curl_standard',
    name: 'Leg Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legCurlMachine,
    targetMuscles: [MuscleGroup.hamstrings],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings**\n\n'
        '1. Lie face down on the leg curl machine, with the pad resting just above your heels.\n'
        '2. Grasp the handles for stability and keep your hips pressed against the pad.\n'
        '3. Curl your heels towards your glutes by flexing your hamstrings, squeezing at the peak.\n'
        '4. Lower the weight with control back to the starting position, fully extending your legs.\n'
        '5. Avoid using momentum; perform the movement slowly and deliberately.',
  ),
  ExercisePoolEntry(
    id: 'legs_curl_single_leg',
    name: 'Single-Leg Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.legCurlMachine,
    targetMuscles: [MuscleGroup.hamstrings],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings (Unilateral)**\n\n'
        '1. Use the leg curl machine, but only place one leg under the pad, the other resting on the machine.\n'
        '2. Perform the curl with the working leg, focusing on the contraction.\n'
        '3. Squeeze at the top and lower with control.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. This helps correct imbalances between legs.',
  ),
  ExercisePoolEntry(
    id: 'legs_curl_seated',
    name: 'Seated Leg Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legCurlMachine,
    targetMuscles: [MuscleGroup.hamstrings],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings**\n\n'
        '1. Sit on the seated leg curl machine, with the pad resting just above your heels (on the front of your ankles).\n'
        '2. Grasp the handles and keep your back against the pad.\n'
        '3. Curl the weight towards your glutes by flexing your hamstrings.\n'
        '4. Squeeze at the peak, then return slowly.\n'
        '5. This variation targets the hamstrings from a seated position, which can emphasise the medial head.',
  ),
  ExercisePoolEntry(
    id: 'legs_curl_iso_hold',
    name: 'Leg Curl Isometric Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.legCurlMachine,
    targetMuscles: [MuscleGroup.hamstrings],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings**\n\n'
        '1. Perform a standard leg curl, but when you reach the peak contraction, hold the position for 3–5 seconds.\n'
        '2. Maintain the hold, squeezing your hamstrings as hard as possible.\n'
        '3. Slowly lower the weight back to the starting position.\n'
        '4. This increases time under tension and improves mind‑muscle connection.\n'
        '5. Use a lighter weight to allow for the hold.',
  ),
  ExercisePoolEntry(
    id: 'legs_curl_band',
    name: 'Band Leg Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.hamstrings],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings**\n\n'
        '1. Anchor a resistance band at floor level behind you.\n'
        '2. Loop the band around your ankles and lie face down on the floor.\n'
        '3. Curl your heels towards your glutes against the band tension.\n'
        '4. Squeeze your hamstrings at the top, then return slowly.\n'
        '5. This is a great home alternative to the machine.',
  ),
];
