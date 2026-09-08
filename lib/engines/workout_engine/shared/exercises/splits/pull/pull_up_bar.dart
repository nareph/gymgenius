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

const List<ExercisePoolEntry> pullPullUpBarExercises = [
  ExercisePoolEntry(
    id: 'pull_pullup_pull_ups',
    name: 'Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Hang from a pull‑up bar with an overhand grip, hands slightly wider than shoulder‑width.\n'
        '2. Engage your lats and pull your chest towards the bar, driving your elbows down and back.\n'
        '3. Pull up until your chin clears the bar, then lower with control to a dead hang.\n'
        '4. Avoid swinging; use a strict, controlled tempo.\n'
        '5. If you cannot complete full reps, use a band or assisted machine.',
  ),
  ExercisePoolEntry(
    id: 'pull_pullup_chin_ups',
    name: 'Chin-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Grip the bar with an underhand grip (palms facing you), hands shoulder‑width apart.\n'
        '2. Hang with arms straight, then pull your chest towards the bar by driving your elbows down.\n'
        '3. Pull up until your chin clears the bar, then lower with control.\n'
        '4. Keep your core tight and avoid swinging.\n'
        '5. Chin‑ups are generally easier than pull‑ups due to greater biceps involvement.',
  ),
  ExercisePoolEntry(
    id: 'pull_pullup_wide_grip',
    name: 'Wide-Grip Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats (Width)**\n\n'
        '1. Grip the bar with a very wide overhand grip, well outside shoulder‑width.\n'
        '2. Hang with arms straight, then pull your chest towards the bar, keeping your elbows flared.\n'
        '3. Pull up until your chin is over the bar, then lower with control.\n'
        '4. This variation emphasises the outer lats and upper back.\n'
        '5. Use a controlled tempo to maximise muscle activation.',
  ),
  ExercisePoolEntry(
    id: 'pull_pullup_neutral_grip',
    name: 'Neutral-Grip Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Use parallel handles or a neutral‑grip attachment on the bar, palms facing each other.\n'
        '2. Hang with arms straight, then pull yourself up, keeping your elbows close to your body.\n'
        '3. Pull up until your chin clears the handles, then lower with control.\n'
        '4. This grip is shoulder‑friendly and often allows more strength output.\n'
        '5. Focus on squeezing your lats at the top.',
  ),
  ExercisePoolEntry(
    id: 'pull_pullup_commando',
    name: 'Commando Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.absCore],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps, Core**\n\n'
        '1. Grip the bar with one hand in front of the other (palms facing you or away), about shoulder‑width apart.\n'
        '2. Hang with arms straight, then pull yourself up, alternating the lead hand at the top of each rep.\n'
        '3. Continue alternating with each repetition, keeping your core engaged to prevent twisting.\n'
        '4. Pull up until your chin is above the bar, then lower with control.\n'
        '5. This variation challenges your core and shoulder stability.',
  ),
];
