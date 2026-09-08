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

const List<ExercisePoolEntry> backBicepsBarbellExercises = [
  ExercisePoolEntry(
    id: 'back_biceps_bb_barbell_rows',
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
        '2. Bend at your hips, keeping your back flat and chest up, until your torso is nearly parallel to the floor.\n'
        '3. Pull the barbell towards your lower chest, driving your elbows back and squeezing your shoulder blades together.\n'
        '4. Pause at the top for a second, then lower the bar with control back to the starting position.\n'
        '5. Keep your core braced and avoid rounding your back throughout the movement.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_bb_t_bar_row',
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
    id: 'back_biceps_bb_barbell_shrugs',
    name: 'Barbell Shrugs',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.traps],
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
    id: 'back_biceps_bb_preacher_curls',
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
        '1. Rest your upper arms on the pad of a preacher bench, with your armpits pressed firmly against the top edge.\n'
        '2. Grip the barbell with an underhand grip, hands shoulder‑width apart, arms fully extended.\n'
        '3. Curl the bar up towards your shoulders by contracting your biceps, keeping your upper arms stationary on the pad.\n'
        '4. Squeeze your biceps at the top, then lower the bar with control until your arms are fully extended.\n'
        '5. Avoid using momentum; keep the movement slow and controlled for maximum biceps isolation.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_bb_deadlift',
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
        '3. Keep your back flat, chest up, and drive through your heels to stand up, pulling the bar up along your shins and thighs.\n'
        '4. Lock out at the top by squeezing your glutes and standing tall, then lower the bar back to the floor with control.\n'
        '5. Reset each rep from a dead stop on the floor to maintain form.',
  ),
];
