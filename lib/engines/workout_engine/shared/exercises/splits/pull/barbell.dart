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

const List<ExercisePoolEntry> pullBarbellExercises = [
  ExercisePoolEntry(
    id: 'pull_bb_barbell_rows',
    name: 'Barbell Bent-Over Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
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
        '1. Stand with feet shoulder‑width apart, holding a barbell with an overhand grip, hands slightly wider than shoulders.\n'
        '2. Bend at the hips with a flat back, torso nearly parallel to the floor, and let the bar hang straight down.\n'
        '3. Pull the bar towards your lower chest, driving your elbows back and squeezing your shoulder blades together.\n'
        '4. Pause at the peak contraction for a second, then lower the bar with control back to the starting position.\n'
        '5. Keep your core braced and avoid rounding your back.',
  ),
  ExercisePoolEntry(
    id: 'pull_bb_t_bar_row',
    name: 'T-Bar Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back (Thickness), Biceps**\n\n'
        '1. Straddle a landmine attachment or T‑bar row station, with a barbell loaded on one end.\n'
        '2. Bend at the hips with a flat back, grip the handles or the bar end, and keep your chest up.\n'
        '3. Pull the handle towards your chest, driving your elbows back and squeezing your shoulder blades together.\n'
        '4. Pause at the peak contraction, then lower the weight with control, feeling the stretch in your lats.\n'
        '5. Keep your core tight and avoid using momentum to lift the weight.',
  ),
  ExercisePoolEntry(
    id: 'pull_bb_barbell_shrugs',
    name: 'Barbell Shrugs',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.traps, MuscleGroup.back],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Trapezius**\n\n'
        '1. Stand upright with feet shoulder‑width apart, holding a barbell in front of your thighs with an overhand grip.\n'
        '2. Keeping your arms straight, shrug your shoulders straight up towards your ears as high as possible.\n'
        '3. Squeeze your traps at the top, hold for a second, then lower the bar back down with control.\n'
        '4. Avoid rolling your shoulders; focus on a pure vertical movement.\n'
        '5. Use a heavy weight but maintain strict form to avoid injury.',
  ),
  ExercisePoolEntry(
    id: 'pull_bb_preacher_curls',
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
        '5. Lower the bar with control until your arms are fully extended, feeling a stretch in your biceps.',
  ),
  ExercisePoolEntry(
    id: 'pull_bb_deadlift',
    name: 'Barbell Deadlift',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [
      MuscleGroup.back,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Full Posterior Chain**\n\n'
        '1. Stand with feet hip‑width apart, barbell over the middle of your feet, shins touching the bar.\n'
        '2. Hinge at your hips and bend your knees, grip the bar just outside your knees with a shoulder‑width grip.\n'
        '3. Keep your back flat, chest up, and drive through your heels to lift the bar off the floor, keeping it close to your body.\n'
        '4. Stand tall with the bar at hip height, squeezing your glutes at the top.\n'
        '5. Lower the bar back to the floor with control, maintaining a flat back throughout.',
  ),
];
