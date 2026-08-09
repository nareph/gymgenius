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

final List<ExercisePoolEntry> coreResistanceBandsExercises = [
  ExercisePoolEntry(
    id: 'core_band_pallof_press',
    name: 'Band Pallof Press',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Core (anti-rotation)**\n\n'
        '1. Anchor a band at chest height.\n'
        '2. Stand sideways, hold the band with both hands.\n'
        '3. Press straight out, resisting rotation.\n'
        '4. Return and switch sides.',
  ),
  ExercisePoolEntry(
    id: 'core_band_woodchop',
    name: 'Band Woodchop',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Anchor a band at low or high position.\n'
        '2. Chop diagonally across your body.\n'
        '3. Alternate sides.',
  ),
  ExercisePoolEntry(
    id: 'core_band_crunches',
    name: 'Banded Crunches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Abs**\n\n'
        '1. Anchor a band above you.\n'
        '2. Kneel and hold the band behind your neck.\n'
        '3. Crunch forward against resistance.\n'
        '4. Return with control.',
  ),
  ExercisePoolEntry(
    id: 'core_band_russian_twists',
    name: 'Banded Russian Twists',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Sit on the floor, knees bent, feet lifted.\n'
        '2. Anchor a band at waist height.\n'
        '3. Hold the band and rotate side to side.\n'
        '4. Control the movement.',
  ),
  ExercisePoolEntry(
    id: 'core_band_leg_raises',
    name: 'Banded Leg Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Lie on your back, loop a band around your feet.\n'
        '2. Hold the ends of the band for resistance.\n'
        '3. Raise your legs straight up.\n'
        '4. Lower with control.',
  ),
];
