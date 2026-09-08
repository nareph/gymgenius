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

const List<ExercisePoolEntry> chestResistanceBandsExercises = [
  ExercisePoolEntry(
    id: 'chest_band_press',
    name: 'Resistance Band Chest Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Band)**\n\n'
        '1. Anchor a resistance band behind you at chest height (e.g., a door frame).\n'
        '2. Hold the handles or band ends at chest level, palms forward.\n'
        '3. Press forward and inward, extending your arms fully.\n'
        '4. Squeeze your chest at the peak, then return slowly, controlling the negative.',
  ),
  ExercisePoolEntry(
    id: 'chest_band_fly',
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
    description: '**Target: Chest (Band Fly)**\n\n'
        '1. Anchor the band behind you at shoulder height.\n'
        '2. Hold the band ends with arms extended out to the sides, slightly bent elbows.\n'
        '3. Bring your hands together in front of your chest, squeezing hard.\n'
        '4. Return slowly, resisting the pull of the band.',
  ),
  ExercisePoolEntry(
    id: 'chest_band_decline_press',
    name: 'Resistance Band Decline Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Lower Chest (Band)**\n\n'
        '1. Anchor the band at waist height behind you.\n'
        '2. Hold the band and press forward and slightly downward (decline angle).\n'
        '3. Squeeze your lower chest at the end of the movement.\n'
        '4. Return with control.',
  ),
  ExercisePoolEntry(
    id: 'chest_band_incline_press',
    name: 'Resistance Band Incline Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Upper Chest (Band)**\n\n'
        '1. Anchor the band low (around your feet) and press upward at an incline.\n'
        '2. Or anchor behind you at floor level, and press forward and upward.\n'
        '3. Focus on the upper chest contraction at the top.',
  ),
  ExercisePoolEntry(
    id: 'chest_band_single_press',
    name: 'Single Arm Band Chest Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.absCore, MuscleGroup.triceps],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Unilateral Band)**\n\n'
        '1. Anchor the band at chest height on one side.\n'
        '2. Step sideways to create tension, grab the handle with one hand.\n'
        '3. Press forward and inward, stabilising your core.\n'
        '4. Return slowly and switch sides.',
  ),
];
