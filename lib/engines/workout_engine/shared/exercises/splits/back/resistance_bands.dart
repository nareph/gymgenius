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

const List<ExercisePoolEntry> backResistanceBandsExercises = [
  ExercisePoolEntry(
    id: 'back_band_rows',
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
        '1. Anchor a resistance band at chest height around a sturdy post or door frame.\n'
        '2. Step back to create tension, hold the handles (or the band) with both hands, arms extended.\n'
        '3. Pull the band handles towards your torso, squeezing your shoulder blades together.\n'
        '4. Pause, then return slowly with control, keeping tension on the band throughout.\n'
        '5. Maintain a flat back and core engagement to avoid lower back strain.',
  ),
  ExercisePoolEntry(
    id: 'back_band_pull_aparts',
    name: 'Band Pull-Aparts',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Upper Back**\n\n'
        '1. Hold a resistance band in front of you with both hands, arms extended straight out, shoulder‑width apart.\n'
        '2. Keeping your arms straight, pull the band apart by moving your hands out to the sides, stretching the band.\n'
        '3. Squeeze your shoulder blades together at the peak, then slowly return to the starting position.\n'
        '4. This is a great warm‑up or finishing exercise for shoulder health and posture.\n'
        '5. Perform controlled reps, avoiding rapid jerks.',
  ),
  ExercisePoolEntry(
    id: 'back_band_face_pulls',
    name: 'Band Face Pulls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.traps],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Traps**\n\n'
        '1. Anchor a band at face height (e.g., to a door handle or pole).\n'
        '2. Hold the band with both hands, arms extended, and step back to create tension.\n'
        '3. Pull the band towards your face, keeping your elbows high and your hands near your ears.\n'
        '4. Squeeze your shoulder blades together at the peak, then return slowly.\n'
        '5. This exercise is excellent for correcting rounded shoulders and improving posture.',
  ),
  ExercisePoolEntry(
    id: 'back_band_lat_pulldown',
    name: 'Band Lat Pulldown',
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
    description: '**Target: Lats, Biceps**\n\n'
        '1. Anchor a resistance band overhead (e.g., to a pull‑up bar or door frame).\n'
        '2. Kneel or sit, grab the band with both hands, arms extended overhead, and lean back slightly.\n'
        '3. Pull the band down towards your chest, driving your elbows down and back, squeezing your lats.\n'
        '4. Pause at the bottom, then return slowly, keeping tension on the band.\n'
        '5. Use a moderate band to allow for controlled reps.',
  ),
  ExercisePoolEntry(
    id: 'back_band_straight_arm_pulldown',
    name: 'Band Straight-Arm Pulldown',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats**\n\n'
        '1. Anchor a band overhead (e.g., to a pull‑up bar).\n'
        '2. Stand facing the anchor, grab the band with both hands, arms extended straight out in front.\n'
        '3. Keeping your arms straight, push the band down towards your thighs by hinging at the shoulders, squeezing your lats.\n'
        '4. Pause at the bottom, then return slowly to the starting position.\n'
        '5. Keep a slight bend in your elbows to maintain tension on the lats.',
  ),
];
