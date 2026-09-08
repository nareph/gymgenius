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

const List<ExercisePoolEntry> upperBodyResistanceBandsExercises = [
  ExercisePoolEntry(
    id: 'upper_band_chest_press',
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
    id: 'upper_band_rows',
    name: 'Band Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Anchor a band at chest height, hold the handles and step back.\n'
        '2. With your arms extended, pull the handles towards your torso, squeezing your shoulder blades.\n'
        '3. Squeeze at the peak, then return slowly with control.',
  ),
  ExercisePoolEntry(
    id: 'upper_band_overhead_press',
    name: 'Band Overhead Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Stand on the middle of a resistance band, holding a handle in each hand at shoulder height.\n'
        '2. Press the handles overhead until your arms are fully extended.\n'
        '3. Lower back to shoulder height with control, maintaining tension.\n'
        '4. Keep your core tight and avoid arching your back.',
  ),
  ExercisePoolEntry(
    id: 'upper_band_bicep_curl',
    name: 'Band Bicep Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.forearms],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps**\n\n'
        '1. Stand on the middle of the band, holding the handles at your sides, palms facing forward.\n'
        '2. Curl the handles up towards your shoulders, keeping your elbows fixed.\n'
        '3. Squeeze your biceps at the top, then lower slowly with control.',
  ),
  ExercisePoolEntry(
    id: 'upper_band_tricep_pushdown',
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
];
