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

const List<ExercisePoolEntry> armsBarbellExercises = [
  ExercisePoolEntry(
    id: 'arms_bb_preacher_curls',
    name: 'Preacher Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
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
        '1. Adjust the preacher bench so your armpits rest comfortably against the top pad and your upper arms are fully supported.\n'
        '2. Grip the barbell with an underhand grip, hands shoulder‑width apart, and let your arms hang straight down.\n'
        '3. Curl the barbell up towards your shoulders by contracting your biceps, keeping your upper arms stationary on the pad.\n'
        '4. Squeeze your biceps at the peak contraction for a second.\n'
        '5. Lower the bar with control until your arms are fully extended, feeling a stretch in your biceps.\n'
        '6. Avoid using momentum or lifting your upper arms off the pad.',
  ),
  ExercisePoolEntry(
    id: 'arms_bb_skull_crushers',
    name: 'Skull Crushers',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Lie on a flat bench holding a barbell with an overhand grip, arms extended above your chest, hands shoulder‑width apart.\n'
        '2. Keeping your upper arms fixed and perpendicular to the floor, bend your elbows to lower the bar towards your forehead.\n'
        '3. Lower the bar until it is just above your forehead (or just behind your head for a deeper stretch).\n'
        '4. Extend your arms back up to the starting position, squeezing your triceps at the top.\n'
        '5. Keep your elbows stationary throughout the movement; only your forearms should move.\n'
        '6. Use a light weight to maintain control and avoid injury.',
  ),
  ExercisePoolEntry(
    id: 'arms_bb_close_grip_bench_press',
    name: 'Close-Grip Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps, Chest**\n\n'
        '1. Lie on a flat bench with your eyes directly under the bar and your feet planted on the floor.\n'
        '2. Grip the bar with your hands shoulder‑width apart or slightly narrower, with your elbows tucked close to your body.\n'
        '3. Unrack the bar and lower it to your lower chest (just below the sternum) with control.\n'
        '4. Keep your elbows pinned to your sides throughout the descent to maximise triceps engagement.\n'
        '5. Press the bar back up powerfully, extending your arms fully at the top.\n'
        '6. Avoid flaring your elbows; this variation targets the triceps more than the standard bench press.',
  ),
  ExercisePoolEntry(
    id: 'arms_bb_standing_curl',
    name: 'Standing Barbell Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps**\n\n'
        '1. Stand upright with feet shoulder‑width apart, holding a barbell with an underhand grip, hands shoulder‑width apart.\n'
        '2. Let the bar hang at arm\'s length in front of your thighs, with your elbows fully extended.\n'
        '3. Keeping your elbows pinned to your sides, curl the bar up towards your chest by contracting your biceps.\n'
        '4. Squeeze your biceps at the top of the movement, then lower the bar with control back to the starting position.\n'
        '5. Avoid swinging your body or using momentum; keep your torso stable.\n'
        '6. For a stricter variation, perform the exercise with your back against a wall.',
  ),
  ExercisePoolEntry(
    id: 'arms_bb_reverse_curl',
    name: 'Reverse Barbell Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.biceps, MuscleGroup.forearms],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps, Forearms**\n\n'
        '1. Stand upright with feet shoulder‑width apart, holding a barbell with an overhand grip (palms facing down), hands shoulder‑width apart.\n'
        '2. Let the bar hang at arm\'s length in front of your thighs, with your elbows fully extended.\n'
        '3. Keeping your elbows pinned to your sides, curl the bar up towards your shoulders by contracting your biceps and forearms.\n'
        '4. Squeeze at the top, then lower the bar with control back to the starting position.\n'
        '5. This grip places more emphasis on the brachioradialis (forearm) and the brachialis.\n'
        '6. Avoid using momentum; keep the movement slow and controlled.',
  ),
];
