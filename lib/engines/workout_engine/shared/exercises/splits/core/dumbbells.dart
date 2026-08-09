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

final List<ExercisePoolEntry> coreDumbbellExercises = [
  ExercisePoolEntry(
    id: 'core_db_dumbbell_crunches',
    name: 'Dumbbell Crunches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Abs**\n\n'
        '1. Hold a dumbbell on your chest.\n'
        '2. Crunch up and squeeze abs.\n'
        '3. Lower back down with control.',
  ),
  ExercisePoolEntry(
    id: 'core_db_russian_twists_dumbbell',
    name: 'Russian Twists with Dumbbell',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Sit with knees bent, torso leaning back, holding a dumbbell.\n'
        '2. Rotate side to side, tapping the floor.\n'
        '3. Keep core tight throughout.',
  ),
  ExercisePoolEntry(
    id: 'core_db_dumbbell_side_bends',
    name: 'Dumbbell Side Bends',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Obliques**\n\n'
        '1. Hold a dumbbell in one hand.\n'
        '2. Bend sideways at the waist.\n'
        '3. Return to upright and repeat on other side.',
  ),
  ExercisePoolEntry(
    id: 'core_db_dumbbell_oblique_crunch',
    name: 'Dumbbell Oblique Crunch',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Lie on your side, hold a dumbbell near your chest.\n'
        '2. Crunch up, bringing shoulder towards hip.\n'
        '3. Lower and repeat on other side.',
  ),
  ExercisePoolEntry(
    id: 'core_db_dumbbell_v_ups',
    name: 'Dumbbell V-Ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Full Core**\n\n'
        '1. Lie on your back holding a dumbbell overhead.\n'
        '2. Simultaneously raise legs and torso.\n'
        '3. Bring dumbbell towards feet, then lower.',
  ),
];
