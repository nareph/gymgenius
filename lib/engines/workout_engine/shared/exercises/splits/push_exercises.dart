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

/// List of exercises for the 'Push' split.
///
/// Prefix for all ids: 'push_'
const List<ExercisePoolEntry> pushExercises = [
  ExercisePoolEntry(
    id: 'push_push_ups',
    name: 'Push-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders, Triceps**\n\n'
        '1. Start in a high plank position with hands slightly wider than shoulders.\n'
        '2. Lower your body until your chest nearly touches the floor.\n'
        '3. Press back up to the starting position, fully extending arms.\n'
        '4. Repeat for desired reps.',
  ),
  ExercisePoolEntry(
    id: 'push_diamond_push_ups',
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
    description: '**Target: Triceps, Inner Chest**\n\n'
        '1. Start in a plank with hands together under your chest, forming a diamond shape.\n'
        '2. Lower your chest towards your hands, keeping elbows close to your body.\n'
        '3. Press back up to full extension.',
  ),
  ExercisePoolEntry(
    id: 'push_pike_push_ups',
    name: 'Pike Push-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Start in a downward-dog position, hips high, hands shoulder-width apart.\n'
        '2. Bend your elbows to lower the top of your head towards the floor.\n'
        '3. Press back up to the starting position.',
  ),
  ExercisePoolEntry(
    id: 'push_decline_push_ups',
    name: 'Decline Push-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Chest, Shoulders**\n\n'
        '1. Place your feet on an elevated surface, hands on the floor.\n'
        '2. Lower your chest towards the floor with control.\n'
        '3. Press back up to full extension.',
  ),
  ExercisePoolEntry(
    id: 'push_wide_push_ups',
    name: 'Wide Push-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Chest, Shoulders**\n\n1. Hands wider than shoulders.\n2. Lower chest towards floor.\n3. Press up.',
  ),
  ExercisePoolEntry(
    id: 'push_plyometric_push_ups',
    name: 'Plyometric Push-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Chest, Shoulders, Triceps**\n\n1. Explosive push-up with hands leaving the ground.\n2. Land softly and repeat.',
  ),
  ExercisePoolEntry(
    id: 'push_archer_push_ups',
    name: 'Archer Push-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Chest, Shoulders (unilateral)**\n\n1. Widen stance, shift weight to one side.\n2. Lower chest towards one hand.\n3. Push up and alternate sides.',
  ),
  ExercisePoolEntry(
    id: 'push_dumbbell_bench_press',
    name: 'Dumbbell Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders, Triceps**\n\n'
        '1. Lie on a bench with dumbbells in each hand, palms facing forward.\n'
        '2. Press the dumbbells up until arms are fully extended.\n'
        '3. Lower them slowly to the sides of your chest.\n'
        '4. Press back up explosively.',
  ),
  ExercisePoolEntry(
    id: 'push_barbell_bench_press',
    name: 'Barbell Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders, Triceps**\n\n'
        '1. Lie on a flat bench, grip the barbell slightly wider than shoulder-width.\n'
        '2. Unrack the bar and lower it to your mid-chest.\n'
        '3. Press the bar back up to full extension.',
  ),
  ExercisePoolEntry(
    id: 'push_smith_machine_bench_press',
    name: 'Smith Machine Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders, Triceps**\n\n'
        '1. Lie on a flat bench under the Smith machine bar.\n'
        '2. Unrack and lower the bar to your chest.\n'
        '3. Press back up to full extension along the fixed path.',
  ),
  ExercisePoolEntry(
    id: 'push_close_grip_bench_press',
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
        '1. Lie on a flat bench, grip the bar with hands shoulder-width apart.\n'
        '2. Lower the bar to your lower chest, keeping elbows tucked in.\n'
        '3. Press back up focusing on triceps.',
  ),
  ExercisePoolEntry(
    id: 'push_incline_dumbbell_press',
    name: 'Incline Dumbbell Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Chest, Shoulders**\n\n'
        '1. Set an incline bench to about 30-45 degrees.\n'
        '2. Press dumbbells from shoulder height upward.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'push_decline_barbell_bench_press',
    name: 'Decline Barbell Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Chest, Triceps**\n\n'
        '1. Lie on a decline bench, feet secured.\n'
        '2. Lower the bar to your lower chest.\n'
        '3. Press back up to full extension.',
  ),
  ExercisePoolEntry(
    id: 'push_machine_chest_press',
    name: 'Machine Chest Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders, Triceps**\n\n'
        '1. Sit at the chest press machine, grips at chest height.\n'
        '2. Press forward until arms are extended.\n'
        '3. Return slowly to the starting position.',
  ),
  ExercisePoolEntry(
    id: 'push_cable_crossover',
    name: 'Cable Crossover',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest**\n\n'
        '1. Stand between two high pulleys, grip a handle in each hand.\n'
        '2. Pull the handles down and together in front of your body.\n'
        '3. Squeeze your chest, then return slowly.',
  ),
  ExercisePoolEntry(
    id: 'push_shoulder_press',
    name: 'Shoulder Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Sit on a bench with back support, dumbbells at shoulder height.\n'
        '2. Press the weights overhead until arms are extended.\n'
        '3. Lower them back to shoulder height with control.',
  ),
  ExercisePoolEntry(
    id: 'push_arnold_press',
    name: 'Arnold Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders (all heads), Triceps**\n\n'
        '1. Sit with dumbbells in front of your shoulders, palms facing you.\n'
        '2. Press upward while rotating your palms to face forward.\n'
        '3. Reverse the rotation as you lower back down.',
  ),
  ExercisePoolEntry(
    id: 'push_overhead_barbell_press',
    name: 'Overhead Barbell Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Stand holding a barbell at shoulder height, hands just outside shoulders.\n'
        '2. Press the bar overhead until arms are fully extended.\n'
        '3. Lower back to shoulder height with control.',
  ),
  ExercisePoolEntry(
    id: 'push_machine_shoulder_press',
    name: 'Machine Shoulder Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Sit at the shoulder press machine, grips at shoulder height.\n'
        '2. Press upward until arms are extended.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'push_kettlebell_overhead_press',
    name: 'Kettlebell Overhead Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Rack a kettlebell against your forearm at shoulder height.\n'
        '2. Press it overhead until your arm is fully extended.\n'
        '3. Lower back to the rack position with control.',
  ),
  ExercisePoolEntry(
    id: 'push_lateral_raises',
    name: 'Lateral Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Side Shoulders**\n\n'
        '1. Stand with dumbbells at your sides, palms facing in.\n'
        '2. Raise the dumbbells laterally to shoulder height.\n'
        '3. Lower them slowly back to start.',
  ),
  ExercisePoolEntry(
    id: 'push_band_lateral_raises',
    name: 'Band Lateral Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Side Shoulders**\n\n'
        '1. Stand on the band, holding a handle in each hand at your sides.\n'
        '2. Raise your arms laterally to shoulder height.\n'
        '3. Lower with control against the band tension.',
  ),
  ExercisePoolEntry(
    id: 'push_cable_lateral_raise',
    name: 'Cable Lateral Raise',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
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
        '1. Stand sideways to a low pulley, handle in the outside hand.\n'
        '2. Raise your arm laterally to shoulder height.\n'
        '3. Lower with control, then switch sides.',
  ),
  ExercisePoolEntry(
    id: 'push_tricep_pushdowns',
    name: 'Tricep Pushdowns',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
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
        '1. Attach a rope or bar to a high pulley.\n'
        '2. Grip the handle and pull down until arms are straight.\n'
        '3. Squeeze triceps at the bottom, then return slowly.',
  ),
  ExercisePoolEntry(
    id: 'push_overhead_tricep_extension',
    name: 'Overhead Tricep Extension',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
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
        '1. Hold a dumbbell with both hands overhead.\n'
        '2. Lower it behind your head by bending your elbows.\n'
        '3. Extend back up to full extension.',
  ),
  ExercisePoolEntry(
    id: 'push_skull_crushers',
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
        '1. Lie on a bench holding a barbell above your chest.\n'
        '2. Bend your elbows to lower the bar towards your forehead.\n'
        '3. Extend back up without moving your upper arms.',
  ),
  ExercisePoolEntry(
    id: 'push_bench_dips',
    name: 'Bench Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps, Shoulders**\n\n'
        '1. Sit on the edge of a bench or chair, hands gripping the edge beside your hips.\n'
        '2. Slide your hips off and lower your body by bending your elbows.\n'
        '3. Push back up to full extension.',
  ),
  ExercisePoolEntry(
    id: 'push_dips',
    name: 'Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.triceps,
      MuscleGroup.shoulders,
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Triceps, Shoulders**\n\n'
        '1. Hoist yourself up on parallel bars or a dip station.\n'
        '2. Lower your body by bending your elbows until shoulders are below elbows.\n'
        '3. Push back up to start.',
  ),
];
