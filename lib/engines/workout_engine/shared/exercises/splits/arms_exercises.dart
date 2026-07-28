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

// NOTE: ids are prefixed with 'arms_' to keep them unique within this file.
// Other split files (chest, back, ...) may contain conceptually similar
// exercises (e.g. 'Diamond Push-ups') with their own 'chest_'/'back_'
// prefix — each split's list is defined independently, so the same
// real-world exercise can have a different id depending on which split
// it appears under. If exercise ids ever need to be globally unique
// (e.g. for cross-split progress tracking / workout logs referencing a
// canonical exercise), this will need a shared catalog instead of one
// list per split — flagging this now so it doesn't surprise later.

/// List of exercises for the 'Arms' split (used by 5-day split).
const List<ExercisePoolEntry> armsExercises = [
  ExercisePoolEntry(
    id: 'arms_tricep_dips_chair',
    name: 'Tricep Dips (chair)',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Triceps, Shoulders**\n\n1. Sit on a chair, hands on the edge.\n2. Slide hips off and lower body.\n3. Push back up.',
  ),
  ExercisePoolEntry(
    id: 'arms_close_grip_pushups',
    name: 'Close-Grip Push-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Triceps, Inner Chest**\n\n1. Hands close together under chest.\n2. Lower chest towards hands.\n3. Press up.',
  ),
  ExercisePoolEntry(
    id: 'arms_tricep_isometric_hold',
    name: 'Tricep Isometric Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.triceps],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Triceps**\n\n1. Halfway down in a push-up position.\n2. Hold for time, keeping body straight.',
  ),
  ExercisePoolEntry(
    id: 'arms_diamond_pushups',
    name: 'Diamond Push-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Triceps, Inner Chest**\n\n1. Hands in diamond shape under chest.\n2. Lower chest towards hands.\n3. Press up.',
  ),
  ExercisePoolEntry(
    id: 'arms_plank_shoulder_taps',
    name: 'Plank Shoulder Taps',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
      MuscleGroup.absCore,
    ],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Shoulders, Triceps, Core**\n\n1. Plank position.\n2. Lift one hand to tap opposite shoulder.\n3. Alternate.',
  ),
  ExercisePoolEntry(
    id: 'arms_bicep_isometric_hold',
    name: 'Bicep Isometric Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.biceps],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Biceps**\n\n1. Flex biceps in a curled position.\n2. Hold for time, squeezing hard.',
  ),
  ExercisePoolEntry(
    id: 'arms_bicep_curls_dumbbell',
    name: 'Bicep Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.biceps],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps**\n\n'
        '1. Stand with dumbbells at your sides, palms facing forward.\n'
        '2. Curl the weights up to shoulder height.\n'
        '3. Lower them back down with control.',
  ),
  ExercisePoolEntry(
    id: 'arms_hammer_curls',
    name: 'Hammer Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.biceps, MuscleGroup.forearms],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps, Forearms**\n\n'
        '1. Hold dumbbells with a neutral grip.\n'
        '2. Curl up without rotating your wrists.',
  ),
  ExercisePoolEntry(
    id: 'arms_preacher_curls',
    name: 'Preacher Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.biceps],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps**\n\n'
        '1. Rest your upper arms on a preacher bench.\n'
        '2. Curl the bar up towards your shoulders.\n'
        '3. Lower slowly to full extension.',
  ),
  ExercisePoolEntry(
    id: 'arms_concentration_curls',
    name: 'Concentration Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.biceps],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps (peak)**\n\n'
        '1. Sit on a bench, elbow braced against your inner thigh.\n'
        '2. Curl the weight up towards your shoulder.',
  ),
  ExercisePoolEntry(
    id: 'arms_cable_curls',
    name: 'Cable Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.biceps],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps**\n\n'
        '1. Attach a straight bar to a low pulley.\n'
        '2. Curl the bar up towards your shoulders.',
  ),
  ExercisePoolEntry(
    id: 'arms_tricep_pushdowns',
    name: 'Tricep Pushdowns',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Attach a rope to a high pulley.\n'
        '2. Pull down until arms are straight.\n'
        '3. Squeeze triceps, then return slowly.',
  ),
  ExercisePoolEntry(
    id: 'arms_overhead_tricep_extension',
    name: 'Overhead Tricep Extension',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Hold a dumbbell with both hands overhead.\n'
        '2. Lower it behind your head.\n'
        '3. Extend back up to full extension.',
  ),
  ExercisePoolEntry(
    id: 'arms_skull_crushers',
    name: 'Skull Crushers',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Lie on a bench holding a barbell above your chest.\n'
        '2. Lower the bar towards your forehead.\n'
        '3. Extend back up.',
  ),
  ExercisePoolEntry(
    id: 'arms_close_grip_bench_press',
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
        '1. Grip the bar with hands shoulder-width apart.\n'
        '2. Lower to your lower chest, elbows tucked.\n'
        '3. Press back up.',
  ),
  // NOTE: the original file had a second, identical 'Diamond Push-ups'
  // entry here (same id would have collided with the one above anyway).
  // Removed as a duplicate — it added no selection value since
  // ExerciseSelector already dedupes by name within a single day, it was
  // just dead weight in the pool.
  ExercisePoolEntry(
    id: 'arms_wrist_curls',
    name: 'Wrist Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.forearms],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Forearms**\n\n'
        '1. Sit with your forearm resting on your thigh, palm facing up, dumbbell in hand.\n'
        '2. Curl the weight up using only your wrist.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'arms_bench_dips',
    name: 'Bench Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps, Shoulders**\n\n'
        '1. Sit on the edge of a bench or chair, hands gripping the edge beside your hips.\n'
        '2. Slide your hips off and lower your body by bending your elbows.\n'
        '3. Push back up to full extension.',
  ),
];
