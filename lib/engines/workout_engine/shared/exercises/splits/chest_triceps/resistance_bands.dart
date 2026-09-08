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

const List<ExercisePoolEntry> chestTricepsResistanceBandsExercises = [
  ExercisePoolEntry(
    id: 'chest_triceps_band_chest_press',
    name: 'Band Chest Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Triceps**\n\n'
        '1. Anchor a band behind you at chest height (e.g., a door frame or post).\n'
        '2. Step forward, grab the handles, and position your hands at chest level.\n'
        '3. Press the handles forward until your arms are fully extended, squeezing your chest.\n'
        '4. Return slowly, controlling the resistance.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_band_tricep_pushdown',
    name: 'Band Tricep Pushdown',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Anchor a band overhead (e.g., a doorframe hook or pull‑up bar).\n'
        '2. Grip the band or handles with both hands, elbows pinned to your sides.\n'
        '3. Push the handles down until your arms are straight, squeezing your triceps.\n'
        '4. Return slowly, resisting the band tension.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_band_chest_fly',
    name: 'Resistance Band Chest Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest**\n\n'
        '1. Anchor the band behind you at shoulder height.\n'
        '2. Hold the band ends with arms extended out to the sides, slightly bent elbows.\n'
        '3. Bring your hands together in front of your chest, squeezing hard.\n'
        '4. Return slowly, resisting the pull of the band.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_band_overhead_tricep_extension',
    name: 'Band Overhead Tricep Extension',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Anchor a band low, stand facing away from the anchor.\n'
        '2. Hold the band overhead with your hands, arms bent, hands behind your head.\n'
        '3. Extend your arms upward until they are straight, squeezing your triceps.\n'
        '4. Lower the band back behind your head with control, keeping your upper arms stationary.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_band_face_pull',
    name: 'Band Face Pull',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.traps],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Traps**\n\n'
        '1. Anchor a band at face height, hold the ends with both hands.\n'
        '2. Step back to create tension, and pull the band towards your face, keeping your elbows high and hands beside your ears.\n'
        '3. Squeeze your shoulder blades together at the peak, then return slowly.\n'
        '4. This exercise improves posture and shoulder health.',
  ),
];
