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

const List<ExercisePoolEntry> chestDumbbellExercises = [
  ExercisePoolEntry(
    id: 'chest_db_flat_press',
    name: 'Dumbbell Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Overall)**\n\n'
        '1. Lie on a flat bench with dumbbells held at shoulder height, palms forward.\n'
        '2. Press the weights up over your chest, keeping them close together at the top.\n'
        '3. Lower with control to the sides of your chest, elbows at about 45°.\n'
        '4. Press back up, squeezing your chest at the top.\n'
        '5. Dumbbells allow a greater range of motion than a barbell.',
  ),
  ExercisePoolEntry(
    id: 'chest_db_incline_press',
    name: 'Incline Dumbbell Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Upper Chest**\n\n'
        '1. Set the bench to 30–45° incline.\n'
        '2. Lie back with dumbbells, press them above your chest.\n'
        '3. Lower them to the sides of your upper chest, keep elbows moderately flared.\n'
        '4. Press up, focusing on the upper pectoral squeeze at the top.',
  ),
  ExercisePoolEntry(
    id: 'chest_db_decline_press',
    name: 'Decline Dumbbell Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Lower Chest**\n\n'
        '1. Set the bench to a decline.\n'
        '2. Secure your feet, hold dumbbells above your chest.\n'
        '3. Lower them to the sides of your lower chest, elbows tucked.\n'
        '4. Press up, squeezing the lower pecs.',
  ),
  ExercisePoolEntry(
    id: 'chest_db_fly',
    name: 'Dumbbell Chest Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Stretch & Isolation)**\n\n'
        '1. Lie on a flat bench with dumbbells above your chest, palms facing each other.\n'
        '2. Keep a slight bend in your elbows.\n'
        '3. Lower the weights out to the sides until you feel a stretch.\n'
        '4. Bring them back together in a hugging motion, squeezing the chest.\n'
        '5. Use light weight to focus on form and contraction.',
  ),
  ExercisePoolEntry(
    id: 'chest_db_single_press',
    name: 'Single Arm Dumbbell Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.absCore, MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Balance & Core)**\n\n'
        '1. Lie on a flat bench holding one dumbbell in one hand.\n'
        '2. Press it up, keeping your core engaged to stabilise your body.\n'
        '3. Lower and press for the prescribed reps, then switch sides.\n'
        '4. This corrects imbalances and builds core stability.',
  ),
  ExercisePoolEntry(
    id: 'chest_db_neutral_press',
    name: 'Neutral Grip Dumbbell Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Shoulder‑friendly)**\n\n'
        '1. Hold dumbbells with palms facing each other (neutral).\n'
        '2. Lie on a flat bench, press up from chest level.\n'
        '3. Keep elbows close to your body throughout.\n'
        '4. This grip reduces shoulder impingement risk while still training the chest.',
  ),
];
