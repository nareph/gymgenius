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

const List<ExercisePoolEntry> pushResistanceBandsExercises = [
  ExercisePoolEntry(
    id: 'push_band_lateral_raises',
    name: 'Band Lateral Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Side Shoulders**\n\n'
        '1. Stand on the middle of a resistance band, holding a handle in each hand at your sides.\n'
        '2. Keep a slight bend in your elbows and raise your arms laterally to shoulder height.\n'
        '3. Pause at the top, then lower slowly against the band tension.\n'
        '4. Keep your core tight and avoid swinging.',
  ),
  ExercisePoolEntry(
    id: 'push_band_chest_press',
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
    id: 'push_band_overhead_press',
    name: 'Band Shoulder Press',
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
        '1. Stand on the band, holding the handles at shoulder height with palms facing forward.\n'
        '2. Press the handles overhead until your arms are fully extended.\n'
        '3. Lower back to shoulder height with control, maintaining tension in the band.\n'
        '4. Keep your core braced and avoid arching your back.',
  ),
  ExercisePoolEntry(
    id: 'push_band_face_pull',
    name: 'Band Face Pull',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.traps],
    usesWeight: false,
    movementPattern: MovementPattern.push,
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
  ExercisePoolEntry(
    id: 'push_band_tricep_pushdown',
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
