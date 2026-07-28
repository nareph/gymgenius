// lib/engines/workout_engine/shared/exercises/splits/pull_exercises.dart

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

/// List of exercises for the 'Pull' split.
///
/// Prefix for all ids: 'pull_'
///
/// Includes at least 8 bodyweight exercises to ensure that users with only
/// bodyweight equipment can always fill a session (desiredCount 4–8).
const List<ExercisePoolEntry> pullExercises = [
  // ---- Bodyweight exercises (8+ variants) ----
  ExercisePoolEntry(
    id: 'pull_supermans',
    name: 'Supermans',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Back, Glutes**\n\n1. Lie face down, arms extended forward.\n2. Lift chest, arms, and legs off the ground.\n3. Hold briefly, then lower.',
  ),
  ExercisePoolEntry(
    id: 'pull_reverse_snow_angels',
    name: 'Reverse Snow Angels',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description:
        '**Target: Rear Delts, Upper Back**\n\n1. Lie face down, arms out to sides.\n2. Raise arms and squeeze shoulder blades together.\n3. Lower slowly.',
  ),
  ExercisePoolEntry(
    id: 'pull_prone_y_raises',
    name: 'Prone Y-Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Lower Traps, Rear Delts**\n\n1. Lie face down, arms in Y position.\n2. Raise arms off the floor.\n3. Squeeze shoulder blades and lower.',
  ),
  ExercisePoolEntry(
    id: 'pull_prone_t_raises',
    name: 'Prone T-Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description:
        '**Target: Mid Traps, Rear Delts**\n\n1. Lie face down, arms out to the sides (T position).\n2. Raise arms off the floor, squeezing shoulder blades.\n3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_prone_i_raises',
    name: 'Prone I-Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Lower Traps, Rhomboids**\n\n1. Lie face down, arms straight overhead (I position).\n2. Raise arms off the floor, squeezing shoulder blades.\n3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_prone_w_raises',
    name: 'Prone W-Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Mid/Lower Traps, Rhomboids**\n\n1. Lie face down, arms bent at 90° (W position).\n2. Raise arms off the floor, squeezing shoulder blades.\n3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_scapular_push_ups',
    name: 'Scapular Push-ups',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Traps, Serratus**\n\n1. Plank position, arms straight.\n2. Push your upper back towards the ceiling (without bending elbows).\n3. Return to neutral.',
  ),
  ExercisePoolEntry(
    id: 'pull_table_rows',
    name: 'Table Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Back, Biceps**\n\n1. Lie under a sturdy table or bar, grip the edge.\n2. Pull your chest towards the table.\n3. Lower with control.',
  ),

  // ---- Equipment-based exercises (pull-ups, rows, etc.) ----
  ExercisePoolEntry(
    id: 'pull_pull_ups',
    name: 'Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Hang from a pull-up bar with hands slightly wider than shoulders.\n'
        '2. Pull your body up until your chin is above the bar.\n'
        '3. Lower yourself with control to full extension.',
  ),
  ExercisePoolEntry(
    id: 'pull_chin_ups',
    name: 'Chin-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Use an underhand grip (palms facing you).\n'
        '2. Pull up until chin clears the bar.\n'
        '3. Lower slowly.',
  ),
  ExercisePoolEntry(
    id: 'pull_wide_grip_pull_ups',
    name: 'Wide-Grip Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats (width)**\n\n'
        '1. Grip the bar wider than shoulder-width.\n'
        '2. Pull your chest towards the bar.\n'
        '3. Lower with control to full extension.',
  ),
  ExercisePoolEntry(
    id: 'pull_inverted_rows',
    name: 'Inverted Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Set a bar at hip height, lie underneath it and grip it with hands shoulder-width apart.\n'
        '2. Keeping your body straight, pull your chest towards the bar.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_dumbbell_rows',
    name: 'Dumbbell Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Place one knee and hand on a bench, other foot on floor.\n'
        '2. With a dumbbell in the free hand, pull it towards your hip.\n'
        '3. Squeeze your back at the top, then lower slowly.',
  ),
  ExercisePoolEntry(
    id: 'pull_renegade_rows',
    name: 'Renegade Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [
      MuscleGroup.back,
      MuscleGroup.absCore,
      MuscleGroup.biceps,
    ],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Core, Biceps**\n\n'
        '1. Start in a plank holding a dumbbell in each hand.\n'
        '2. Row one dumbbell up towards your hip while stabilizing with the other arm.\n'
        '3. Lower and repeat on the other side.',
  ),
  ExercisePoolEntry(
    id: 'pull_kettlebell_rows',
    name: 'Kettlebell Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Hinge forward holding a kettlebell in one hand, other hand on a bench.\n'
        '2. Pull the kettlebell towards your hip.\n'
        '3. Lower with control, then switch sides.',
  ),
  ExercisePoolEntry(
    id: 'pull_band_rows',
    name: 'Band Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Anchor a band at chest height and step back to create tension.\n'
        '2. Pull the handles towards your torso, squeezing your shoulder blades.\n'
        '3. Return slowly with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_barbell_rows',
    name: 'Barbell Rows',
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
        '1. Bend at hips, keeping back straight, grip barbell with overhand grip.\n'
        '2. Pull the bar towards your lower chest.\n'
        '3. Squeeze shoulder blades together, then lower.',
  ),
  ExercisePoolEntry(
    id: 'pull_t_bar_row',
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
    description: '**Target: Back (thickness), Biceps**\n\n'
        '1. Straddle a landmine barbell, hinge forward at the hips.\n'
        '2. Pull the bar towards your chest, squeezing shoulder blades together.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_barbell_shrugs',
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
        '1. Hold a barbell in front of your thighs.\n'
        '2. Shrug your shoulders straight up towards your ears.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_dumbbell_shrugs',
    name: 'Dumbbell Shrugs',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.traps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Trapezius**\n\n'
        '1. Hold a dumbbell in each hand at your sides.\n'
        '2. Shrug your shoulders straight up towards your ears.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_lat_pulldowns',
    name: 'Lat Pulldowns',
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
        '1. Sit at a lat pulldown machine, grip the bar wide.\n'
        '2. Pull the bar down to your upper chest.\n'
        '3. Control the return.',
  ),
  ExercisePoolEntry(
    id: 'pull_single_arm_lat_pulldown',
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
        '1. Attach a single handle to a high pulley.\n'
        '2. Pull down and towards your hip with one arm.\n'
        '3. Return with control, then switch sides.',
  ),
  ExercisePoolEntry(
    id: 'pull_seated_cable_row',
    name: 'Seated Cable Row',
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
        '1. Sit at a cable row station, feet on the platform, knees slightly bent.\n'
        '2. Pull the handle towards your torso, squeezing your shoulder blades.\n'
        '3. Extend your arms back out with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_machine_row',
    name: 'Machine Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Sit at the row machine, chest against the pad.\n'
        '2. Pull the handles towards your torso.\n'
        '3. Return slowly to the starting position.',
  ),
  ExercisePoolEntry(
    id: 'pull_reverse_flyes',
    name: 'Reverse Flyes',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Upper Back**\n\n'
        '1. Bend forward at the hips holding a dumbbell in each hand.\n'
        '2. Raise your arms out to the sides, squeezing your shoulder blades.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_face_pulls',
    name: 'Face Pulls',
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
        '1. Attach a rope to a high pulley.\n'
        '2. Pull the rope towards your face, elbows high.\n'
        '3. Squeeze rear delts and release slowly.',
  ),
  ExercisePoolEntry(
    id: 'pull_bicep_curls',
    name: 'Bicep Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
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
        '1. Stand with dumbbells at your sides, palms facing forward.\n'
        '2. Curl the weights up to shoulder height, squeezing biceps.\n'
        '3. Lower them back down with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_hammer_curls',
    name: 'Hammer Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.biceps, MuscleGroup.forearms],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps (brachialis), Forearms**\n\n'
        '1. Hold dumbbells with a neutral grip (palms facing each other).\n'
        '2. Curl up without rotating your wrists.',
  ),
  ExercisePoolEntry(
    id: 'pull_concentration_curls',
    name: 'Concentration Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps (peak)**\n\n'
        '1. Sit on a bench, elbow braced against your inner thigh, dumbbell in hand.\n'
        '2. Curl the weight up towards your shoulder.\n'
        '3. Lower slowly with full control.',
  ),
  ExercisePoolEntry(
    id: 'pull_preacher_curls',
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
        '1. Rest your upper arms on a preacher bench, gripping a barbell.\n'
        '2. Curl the bar up towards your shoulders.\n'
        '3. Lower slowly to full extension.',
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
        '1. Attach a straight bar to a low pulley.\n'
        '2. Curl the bar up towards your shoulders, keeping elbows fixed.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_band_bicep_curls',
    name: 'Band Bicep Curls',
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
        '1. Stand on the band, holding a handle in each hand.\n'
        '2. Curl your hands towards your shoulders.\n'
        '3. Lower with control against the band tension.',
  ),
];
