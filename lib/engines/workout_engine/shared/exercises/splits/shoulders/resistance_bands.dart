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

const List<ExercisePoolEntry> shouldersResistanceBandsExercises = [
  ExercisePoolEntry(
    id: 'shoulders_band_shoulder_press',
    name: 'Band Shoulder Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Stand on a band, hold handles at shoulder height.\n'
        '2. Press overhead until arms are straight.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_band_lateral_raise',
    name: 'Band Lateral Raise',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Side Shoulders**\n\n'
        '1. Stand on a band, hold handles at your sides.\n'
        '2. Raise arms out to the sides to shoulder height.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_band_face_pull',
    name: 'Band Face Pull',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.back],
    usesWeight: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Traps**\n\n'
        '1. Anchor a band at face height.\n'
        '2. Pull the band towards your face, elbows high.\n'
        '3. Squeeze shoulder blades, then return.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_band_front_raise',
    name: 'Band Front Raise',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Front Shoulders**\n\n'
        '1. Stand on a band, hold handles in front of your thighs.\n'
        '2. Raise your arms forward to shoulder height.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_band_upright_row',
    name: 'Band Upright Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.biceps],
    usesWeight: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Traps**\n\n'
        '1. Stand on a band, hold handles with overhand grip.\n'
        '2. Pull the band straight up towards your chin, elbows leading.\n'
        '3. Lower with control.',
  ),
];
