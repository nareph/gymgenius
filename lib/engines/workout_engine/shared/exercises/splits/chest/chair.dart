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

const List<ExercisePoolEntry> chestChairExercises = [
  ExercisePoolEntry(
    id: 'chest_chair_incline_pushup',
    name: 'Incline Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest (Reduced Difficulty)**\n\n'
        '1. Place your hands on a chair, bench, or step, shoulder‑width apart.\n'
        '2. Extend your legs behind you, forming a plank.\n'
        '3. Lower your chest toward the chair, keeping your body straight.\n'
        '4. Push back up. This variation is easier than a standard push‑up, great for beginners.',
  ),
  ExercisePoolEntry(
    id: 'chest_chair_decline_pushup',
    name: 'Decline Bench Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Chest**\n\n'
        '1. Place your feet on a chair or bench, hands on the floor.\n'
        '2. Perform a push‑up; the elevated feet increase the load on the upper chest.\n'
        '3. Lower until your chest is near the floor, then press up.',
  ),
  ExercisePoolEntry(
    id: 'chest_chair_staggered_pushup',
    name: 'Staggered Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.absCore],
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest (Asymmetrical Loading)**\n\n'
        '1. Place one hand on a chair (elevated) and the other on the floor, both in line with your shoulders.\n'
        '2. Lower your chest toward the floor, keeping your body straight.\n'
        '3. Push up, then switch sides. This creates a one‑sided emphasis and challenges stability.',
  ),
  ExercisePoolEntry(
    id: 'chest_chair_explosive_pushup',
    name: 'Explosive Bench Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest (Power)**\n\n'
        '1. Place your hands on a sturdy chair, feet on the floor, body in a plank.\n'
        '2. Lower into a push‑up, then explode up so your hands leave the chair.\n'
        '3. Land softly and immediately go into the next rep.\n'
        '4. This builds upper‑body power and rate of force development.',
  ),
  ExercisePoolEntry(
    id: 'chest_chair_offset_pushup',
    name: 'Offset Bench Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.absCore],
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest (Stability)**\n\n'
        '1. Place one hand on a chair and the other on the floor, but not in line – offset them for instability.\n'
        '2. Lower your chest toward the lower hand, then push up.\n'
        '3. This variation challenges your core and shoulder stabilisers.',
  ),
];
