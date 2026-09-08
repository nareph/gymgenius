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

const List<ExercisePoolEntry> chestSmithExercises = [
  ExercisePoolEntry(
    id: 'chest_smith_flat_press',
    name: 'Smith Machine Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Smith Machine)**\n\n'
        '1. Set a bench under the Smith machine bar, align it so the bar lowers to your mid‑chest.\n'
        '2. Grip the bar slightly wider than shoulder‑width, unrack it.\n'
        '3. Lower the bar to your chest, keeping elbows at 45°.\n'
        '4. Press back up, squeezing your chest.\n'
        '5. The fixed path provides stability and helps learn the movement pattern.',
  ),
  ExercisePoolEntry(
    id: 'chest_smith_incline_press',
    name: 'Smith Incline Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Upper Chest (Smith)**\n\n'
        '1. Place an incline bench under the Smith bar.\n'
        '2. Lie back, grip the bar, unrack and lower to your upper chest.\n'
        '3. Press up, focusing on the upper pectoral contraction.\n'
        '4. The guided bar helps maintain proper form.',
  ),
  ExercisePoolEntry(
    id: 'chest_smith_decline_press',
    name: 'Smith Decline Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Lower Chest (Smith)**\n\n'
        '1. Set a decline bench under the Smith bar.\n'
        '2. Lower the bar to your lower chest, keeping elbows tucked.\n'
        '3. Press up, squeezing the lower pecs.\n'
        '4. The fixed bar path reduces shoulder stress.',
  ),
  ExercisePoolEntry(
    id: 'chest_smith_close_press',
    name: 'Smith Close Grip Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest + Triceps (Smith)**\n\n'
        '1. Use a flat bench, grip the bar shoulder‑width apart.\n'
        '2. Lower the bar to your lower chest, elbows tucked.\n'
        '3. Press up, focusing on triceps and inner chest.\n'
        '4. The Smith machine allows you to load heavy safely.',
  ),
  ExercisePoolEntry(
    id: 'chest_smith_reverse_press',
    name: 'Smith Reverse Grip Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: true,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Upper Chest (Reverse Grip)**\n\n'
        '1. Grip the bar with palms facing you (reverse/underhand grip), hands shoulder‑width.\n'
        '2. Lie on a flat bench, lower the bar to your upper chest.\n'
        '3. Press up, squeezing the upper chest.\n'
        '4. This grip increases upper pectoral activation.',
  ),
];
