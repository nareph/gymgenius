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

const List<ExercisePoolEntry> armsResistanceBandsExercises = [
  ExercisePoolEntry(
    id: 'arms_band_bicep_curl',
    name: 'Band Bicep Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps**\n\n'
        '1. Stand on the middle of a resistance band, holding a handle in each hand, arms straight down.\n'
        '2. Keeping your elbows pinned to your sides, curl the handles up towards your shoulders.\n'
        '3. Squeeze your biceps at the top, then lower with control against the band tension.\n'
        '4. Avoid using momentum; keep the movement slow and controlled.\n'
        '5. For added tension, step further onto the band or use a thicker band.',
  ),
  ExercisePoolEntry(
    id: 'arms_band_tricep_pushdown',
    name: 'Band Tricep Pushdown',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Anchor a band overhead (e.g., to a pull‑up bar or door frame hook).\n'
        '2. Grip the band or handles with both hands, elbows pinned to your sides.\n'
        '3. Push the handles down until your arms are straight, squeezing your triceps.\n'
        '4. Return slowly, resisting the band tension.\n'
        '5. Keep your upper arms stationary throughout the movement.',
  ),
  ExercisePoolEntry(
    id: 'arms_band_hammer_curl',
    name: 'Band Hammer Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.biceps, MuscleGroup.forearms],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps, Forearms**\n\n'
        '1. Stand on the middle of a resistance band, holding the handles with a neutral grip (palms facing each other).\n'
        '2. Keeping your elbows pinned to your sides, curl the handles up towards your shoulders without rotating your wrists.\n'
        '3. Squeeze your biceps and forearms at the top, then lower with control.\n'
        '4. This variation targets the brachialis and brachioradialis muscles.\n'
        '5. Maintain constant tension on the band throughout the movement.',
  ),
  ExercisePoolEntry(
    id: 'arms_band_overhead_tricep_extension',
    name: 'Band Overhead Tricep Extension',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Anchor a band low, stand facing away from the anchor.\n'
        '2. Hold the band overhead with your hands, arms bent, hands behind your head.\n'
        '3. Extend your arms upward until they are straight, squeezing your triceps.\n'
        '4. Lower the band back behind your head with control, keeping your upper arms stationary.\n'
        '5. Focus on the full extension of the triceps at the top of the movement.',
  ),
  ExercisePoolEntry(
    id: 'arms_band_reverse_curl',
    name: 'Band Reverse Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.biceps, MuscleGroup.forearms],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps, Forearms**\n\n'
        '1. Stand on the middle of a resistance band, holding the handles with an overhand grip (palms facing down).\n'
        '2. Keeping your elbows pinned to your sides, curl the handles up towards your shoulders.\n'
        '3. Squeeze your biceps and forearms at the top, then lower with control.\n'
        '4. This variation targets the brachioradialis and forearm extensors.\n'
        '5. Perform the movement slowly for maximum muscle engagement.',
  ),
  ExercisePoolEntry(
    id: 'arms_band_concentration_curl',
    name: 'Band Concentration Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps (Peak)**\n\n'
        '1. Sit on a chair, place the band under your foot, and hold the handle with one hand.\n'
        '2. Rest your elbow against your inner thigh, arm extended, and let the handle hang down.\n'
        '3. Curl the handle up towards your shoulder, squeezing your biceps at the top.\n'
        '4. Lower with control, fully extending your arm at the bottom.\n'
        '5. Complete all reps on one side before switching to the other.',
  ),
  ExercisePoolEntry(
    id: 'arms_band_kickbacks',
    name: 'Band Tricep Kickbacks',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Hinge forward at the hips with a flat back, placing a band under your foot on the opposite side.\n'
        '2. Hold the band handle with one hand, keeping your upper arm parallel to the floor.\n'
        '3. Extend your arm backward until it is straight, squeezing your triceps.\n'
        '4. Lower with control, keeping your upper arm stationary throughout.\n'
        '5. Complete all reps on one side before switching to the other.',
  ),
  ExercisePoolEntry(
    id: 'arms_band_wrist_curls',
    name: 'Band Wrist Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.forearms],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Forearms**\n\n'
        '1. Sit on a bench with your forearms resting on your thighs, holding the ends of a band that is anchored under your feet.\n'
        '2. Your hands should hang off your knees, palms facing up, with the band under tension.\n'
        '3. Curl your wrists upward, squeezing your forearm muscles at the top.\n'
        '4. Lower with control, feeling the stretch in your forearms.\n'
        '5. To target the other side, perform with palms facing down (wrist extensions).',
  ),
];
