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

const List<ExercisePoolEntry> armsBodyweightExercises = [
  ExercisePoolEntry(
    id: 'arms_bw_tricep_dips_chair',
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
    id: 'arms_bw_close_grip_pushups',
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
    id: 'arms_bw_tricep_isometric_hold',
    name: 'Tricep Isometric Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
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
    id: 'arms_bw_diamond_pushups',
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
    id: 'arms_bw_plank_shoulder_taps',
    name: 'Plank Shoulder Taps',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
      MuscleGroup.absCore
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
    id: 'arms_bw_bicep_isometric_hold',
    name: 'Bicep Isometric Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [],
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
    id: 'arms_bw_bench_dips',
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
