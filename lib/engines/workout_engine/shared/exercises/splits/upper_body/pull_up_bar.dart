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

const List<ExercisePoolEntry> upperBodyPullUpBarExercises = [
  ExercisePoolEntry(
    id: 'upper_pullup_pull_ups',
    name: 'Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.forearms],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Grip the pull‑up bar with an overhand grip (palms facing away), hands slightly wider than shoulder‑width.\n'
        '2. Hang with your arms fully extended, core engaged.\n'
        '3. Pull your chest up towards the bar, squeezing your shoulder blades together.\n'
        '4. Lower yourself slowly back to the starting position with control.\n'
        '5. Avoid swinging or using momentum – strict form is key.',
  ),
  ExercisePoolEntry(
    id: 'upper_pullup_chin_ups',
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
        '2. Hang with arms extended, then pull your chin above the bar.\n'
        '3. Squeeze your lats and biceps at the top.\n'
        '4. Lower yourself with control back to the starting position.',
  ),
  ExercisePoolEntry(
    id: 'upper_pullup_wide_grip',
    name: 'Wide-Grip Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.biceps],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats (width)**\n\n'
        '1. Grip the bar with an overhand grip, hands much wider than shoulder‑width.\n'
        '2. Hang and pull yourself up until your chest reaches the bar.\n'
        '3. Focus on pulling with your lats, keeping your elbows flared slightly.\n'
        '4. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'upper_pullup_neutral_grip',
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
        '1. Use parallel handles or a neutral grip attachment on the bar, palms facing each other.\n'
        '2. Pull your chest up, keeping your elbows close to your body.\n'
        '3. Squeeze your lats at the top, then lower with control.',
  ),
  ExercisePoolEntry(
    id: 'upper_pullup_commando',
    name: 'Commando Pull-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps, Core**\n\n'
        '1. Grip the bar with one hand in front of the other (like a commando climbing a rope), or use a parallel grip with hands close together.\n'
        '2. Pull your head up and to one side of the bar, alternating which side leads on each rep.\n'
        '3. This variation heavily recruits the core and creates an asymmetrical pull.',
  ),
];
