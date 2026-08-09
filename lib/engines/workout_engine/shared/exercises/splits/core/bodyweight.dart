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

const List<ExercisePoolEntry> coreBodyweightExercises = [
  ExercisePoolEntry(
    id: 'core_bw_plank',
    name: 'Plank',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core**\n\n'
        '1. Forearm plank position.\n'
        '2. Hold body straight from head to heels.\n'
        '3. Engage core and hold for time.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_side_plank',
    name: 'Side Plank',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Obliques**\n\n'
        '1. Side support on forearm.\n'
        '2. Hold body straight.\n'
        '3. Repeat on other side.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_bicycle_crunches',
    name: 'Bicycle Crunches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Abs, Obliques**\n\n'
        '1. Lie on your back, hands behind your head.\n'
        '2. Bring one elbow towards the opposite knee while extending the other leg.\n'
        '3. Alternate sides in a pedaling motion.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_russian_twists',
    name: 'Russian Twists',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Sit with knees bent, torso leaning back slightly, feet off the floor.\n'
        '2. Rotate your torso side to side, tapping the floor beside your hips.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_mountain_climbers',
    name: 'Mountain Climbers',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Plank position.\n'
        '2. Drive one knee towards chest.\n'
        '3. Alternate quickly.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_crunches',
    name: 'Crunches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Abs**\n\n'
        '1. Lie on your back, knees bent, feet flat.\n'
        '2. Curl your upper body towards your knees.\n'
        '3. Lower back down with control.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_reverse_crunches',
    name: 'Reverse Crunches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Lie on your back, hands at sides.\n'
        '2. Lift your legs and curl your hips off the floor.\n'
        '3. Lower back down slowly.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_leg_raises',
    name: 'Leg Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Lie on your back, legs straight.\n'
        '2. Raise your legs to 90° without bending knees.\n'
        '3. Lower them slowly without touching the floor.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_flutter_kicks',
    name: 'Flutter Kicks',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs, Hip Flexors**\n\n'
        '1. Lie on your back, hands under glutes.\n'
        '2. Flutter your legs up and down.\n'
        '3. Keep core engaged and back flat.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_scissor_kicks',
    name: 'Scissor Kicks',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Lie on your back, legs extended.\n'
        '2. Cross one leg over the other in a scissor motion.\n'
        '3. Alternate quickly without arching your back.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_heel_touches',
    name: 'Heel Touches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Lie on your back, knees bent, feet flat.\n'
        '2. Reach your right hand towards your right heel.\n'
        '3. Alternate sides in a controlled manner.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_v_ups',
    name: 'V‑Ups',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Full Core**\n\n'
        '1. Lie on your back, arms and legs extended.\n'
        '2. Lift arms and legs simultaneously to form a V shape.\n'
        '3. Lower back down with control.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_dead_bug',
    name: 'Dead Bug',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Deep Core**\n\n'
        '1. Lie on your back, arms extended towards ceiling, legs at 90°.\n'
        '2. Slowly extend opposite arm and leg.\n'
        '3. Return to start and alternate.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_toe_touches',
    name: 'Toe Touches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Abs**\n\n'
        '1. Lie on your back, legs straight up towards ceiling.\n'
        '2. Reach your hands towards your toes.\n'
        '3. Lower back down with control.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_plank_jacks',
    name: 'Plank Jacks',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.adductors],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Core, Adductors**\n\n'
        '1. Plank position.\n'
        '2. Jump your feet apart and together.\n'
        '3. Keep hips stable.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_spiderman_plank',
    name: 'Spiderman Plank',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Hip Flexors**\n\n'
        '1. Plank position.\n'
        '2. Bring one knee towards the same-side elbow.\n'
        '3. Alternate sides.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_bird_dog',
    name: 'Bird Dog',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.back, MuscleGroup.glutes],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.isometric,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Lower Back**\n\n'
        '1. Start on all fours.\n'
        '2. Extend opposite arm and leg simultaneously.\n'
        '3. Hold and switch sides.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_hollow_body_hold',
    name: 'Hollow Body Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core**\n\n'
        '1. Lie on your back, arms and legs extended.\n'
        '2. Lift arms, shoulders, and legs off the floor.\n'
        '3. Hold with lower back pressed into the ground.',
  ),
];
