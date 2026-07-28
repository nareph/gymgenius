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

const List<ExercisePoolEntry> legsResistanceBandsExercises = [
  ExercisePoolEntry(
    id: 'legs_band_squats',
    name: 'Resistance Band Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Stand on a band, hold the handles at shoulder height.\n'
        '2. Perform a squat, keeping tension on the band.',
  ),
  ExercisePoolEntry(
    id: 'legs_band_glute_bridges',
    name: 'Band Glute Bridges',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.hamstrings],
    usesWeight: true,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes**\n\n'
        '1. Place a band above your knees.\n'
        '2. Perform glute bridges, pushing knees apart against the band.',
  ),
  ExercisePoolEntry(
    id: 'legs_band_clamshells',
    name: 'Band Clamshells',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Glutes**\n\n'
        '1. Lie on your side with a band above your knees.\n'
        '2. Open your knees like a clam shell.',
  ),
  ExercisePoolEntry(
    id: 'legs_band_lateral_walks',
    name: 'Band Lateral Walks',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.glutes, MuscleGroup.adductors],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Glutes, Adductors**\n\n'
        '1. Place a band above your knees.\n'
        '2. Step sideways, keeping tension on the band.',
  ),
  ExercisePoolEntry(
    id: 'legs_band_leg_curls',
    name: 'Band Leg Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.hamstrings],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings**\n\n'
        '1. Anchor a band, lie face down, loop band around ankles.\n'
        '2. Curl your heels towards your glutes.',
  ),
];
