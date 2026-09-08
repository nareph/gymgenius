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
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Core (anti-rotation)**\n\n'
        '1. Anchor a resistance band at chest height (e.g., to a door handle or pole).\n'
        '2. Stand sideways to the anchor, hold the band with both hands, and step forward to create tension.\n'
        '3. Press the band straight out in front of you, resisting the rotational pull.\n'
        '4. Hold for a second, then return slowly with control.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'core_band_woodchop',
    name: 'Band Woodchop',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Anchor a resistance band at low or high position.\n'
        '2. Stand with feet shoulder‑width apart, grip the band with both hands.\n'
        '3. Chop diagonally across your body, using your core to rotate.\n'
        '4. Return slowly with control.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'core_band_crunches',
    name: 'Banded Crunches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Abs**\n\n'
        '1. Anchor a resistance band at a high position (e.g., a pull‑up bar or door frame hook).\n'
        '2. Kneel on the floor, holding the band behind your head with both hands.\n'
        '3. Crunch forward, curling your torso toward your knees, squeezing your abs.\n'
        '4. Return slowly against the band tension.\n'
        '5. Keep your elbows pointing forward and your core engaged.',
  ),
  ExercisePoolEntry(
    id: 'core_band_russian_twists',
    name: 'Banded Russian Twists',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Sit on the floor with your knees bent and feet lifted, holding a resistance band with both hands.\n'
        '2. Anchor the band at waist height behind you or under your feet.\n'
        '3. Rotate your torso to the right, then to the left, keeping the band under tension.\n'
        '4. Perform the movement slowly and with control.\n'
        '5. This adds resistance to the standard Russian twist.',
  ),
  ExercisePoolEntry(
    id: 'core_band_leg_raises',
    name: 'Banded Leg Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Lie on your back with a resistance band looped around your feet and holding the ends with your hands.\n'
        '2. Keep your legs straight and raise them to a 90° angle against the band tension.\n'
        '3. Lower them slowly, resisting the band.\n'
        '4. Keep your lower back pressed into the floor throughout.\n'
        '5. This adds resistance to standard leg raises.',
  ),
];
