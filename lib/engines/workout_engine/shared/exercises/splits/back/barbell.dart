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

const List<ExercisePoolEntry> backBarbellExercises = [
  ExercisePoolEntry(
    id: 'back_bb_bent_over_row',
    name: 'Barbell Bent-Over Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a barbell with an overhand grip, hands slightly wider than shoulders.\n'
        '2. Bend at your hips, keeping your back flat and chest up, until your torso is nearly parallel to the floor.\n'
        '3. Pull the barbell towards your lower chest, driving your elbows back and squeezing your shoulder blades together.\n'
        '4. Pause at the top, then lower the bar with control back to the starting position.\n'
        '5. Keep your core braced and avoid rounding your back.',
  ),
  ExercisePoolEntry(
    id: 'back_bb_pendlay_row',
    name: 'Pendlay Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.biceps],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back (Explosive Strength)**\n\n'
        '1. Set a barbell on the floor and stand over it with feet hip‑width apart, shins near the bar.\n'
        '2. Bend at the hips with a flat back, grip the bar just outside your knees, and keep your head up.\n'
        '3. Pull the bar explosively towards your chest, keeping your elbows high and back flat.\n'
        '4. Lower the bar back to the floor with control; each rep starts from a dead stop.\n'
        '5. Reset your position between reps for maximal back engagement.',
  ),
  ExercisePoolEntry(
    id: 'back_bb_t_bar_row',
    name: 'T-Bar Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Set up a T‑bar row station or landmine attachment with a barbell loaded on one end.\n'
        '2. Straddle the bar, bend at the hips with a flat back, and grip the handles or the bar end.\n'
        '3. Pull the handle towards your chest, driving your elbows back and squeezing your shoulder blades.\n'
        '4. Lower with control, feeling the stretch in your lats.\n'
        '5. Keep your core tight and avoid using momentum.',
  ),
  ExercisePoolEntry(
    id: 'back_bb_deadlift',
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
        '2. Hinge at your hips and bend your knees, grip the bar just outside your knees with a shoulder‑width grip (mixed or overhand).\n'
        '3. Keep your back flat, chest up, and drive through your heels to stand up, pulling the bar up along your shins and thighs.\n'
        '4. Lock out at the top by squeezing your glutes and standing tall, then lower the bar back to the floor with control, maintaining a flat back.\n'
        '5. Reset each rep from a dead stop on the floor.',
  ),
  ExercisePoolEntry(
    id: 'back_bb_rack_pull',
    name: 'Rack Pull',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.back, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.hamstrings],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Back, Glutes**\n\n'
        '1. Set the barbell on safety pins in a power rack at knee height (or just below the knees).\n'
        '2. Stand over the bar, grip it with a shoulder‑width grip, keep your back flat, chest up.\n'
        '3. Drive through your heels to stand up, pulling the bar to full extension, squeezing your glutes and upper back.\n'
        '4. Lower the bar back to the pins with control, maintaining a flat back.\n'
        '5. This movement is excellent for building lockout strength and upper back thickness.',
  ),
];
