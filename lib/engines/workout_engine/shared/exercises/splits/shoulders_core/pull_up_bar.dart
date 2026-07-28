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

const List<ExercisePoolEntry> shouldersCorePullUpBarExercises = [
  ExercisePoolEntry(
    id: 'shoulders_core_pullup_hanging_leg_raises',
    name: 'Hanging Leg Raises',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Hang from a pull-up bar with arms fully extended.\n'
        '2. Raise your legs straight up towards your chest.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_pullup_hanging_knee_raises',
    name: 'Hanging Knee Raises',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Hang from a bar.\n'
        '2. Raise knees towards your chest.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_pullup_windshield_wipers',
    name: 'Windshield Wipers',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.absCore, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques, Core**\n\n'
        '1. Hang from a bar with legs extended.\n'
        '2. Rotate your legs side to side like windshield wipers.\n'
        '3. Keep your upper body stable.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_pullup_l_sit',
    name: 'L-Sit Hang',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.absCore, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Hang from a bar.\n'
        '2. Raise legs to a 90° angle, forming an L-shape.\n'
        '3. Hold the position.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_pullup_toes_to_bar',
    name: 'Toes-to-Bar',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.absCore, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Hang from a bar.\n'
        '2. Raise straight legs up to touch the bar with your toes.\n'
        '3. Lower with control.',
  ),
];
