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

const List<ExercisePoolEntry> pushDipExercises = [
  ExercisePoolEntry(
    id: 'push_dip_dips',
    name: 'Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.triceps,
      MuscleGroup.shoulders
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
  ExercisePoolEntry(
    id: 'push_dip_weighted_dips',
    name: 'Weighted Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.triceps,
      MuscleGroup.shoulders
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Triceps, Shoulders**\n\n'
        '1. Attach weight to a dip belt.\n'
        '2. Perform dips with extra load.',
  ),
  ExercisePoolEntry(
    id: 'push_dip_chest_dips',
    name: 'Chest Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest**\n\n'
        '1. Lean forward slightly on the dip bars.\n'
        '2. Lower until your chest is stretched.\n'
        '3. Press up.',
  ),
  ExercisePoolEntry(
    id: 'push_dip_tricep_dips',
    name: 'Tricep Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Keep torso upright on the dip bars.\n'
        '2. Lower until elbows are at 90°.\n'
        '3. Press up.',
  ),
  ExercisePoolEntry(
    id: 'push_dip_band_assisted_dips',
    name: 'Band-Assisted Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Triceps**\n\n'
        '1. Loop a band around the dip bars.\n'
        '2. Place knees or feet in the band for assistance.\n'
        '3. Perform dips with reduced load.',
  ),
];
