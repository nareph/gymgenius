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

const List<ExercisePoolEntry> chestTricepsChairExercises = [
  ExercisePoolEntry(
    id: 'chest_triceps_chair_bench_dips',
    name: 'Bench Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps, Shoulders**\n\n'
        '1. Sit on the edge of a sturdy chair or bench, hands gripping the edge beside your hips.\n'
        '2. Slide your hips off the seat and lower your body by bending your elbows until your arms form a 90° angle.\n'
        '3. Push back up to the starting position, keeping your body close to the bench.\n'
        '4. To increase difficulty, extend your legs further or place weight on your lap.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_chair_incline_push_ups',
    name: 'Incline Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders**\n\n'
        '1. Place your hands on a stable chair or bench, shoulder‑width apart.\n'
        '2. Extend your legs behind you, forming a plank position.\n'
        '3. Lower your chest towards the chair by bending your elbows.\n'
        '4. Push back up, keeping your body straight. This variation reduces the load compared to a standard push‑up.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_chair_decline_push_ups',
    name: 'Decline Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Chest**\n\n'
        '1. Place your feet on a chair or bench, hands on the floor directly under your shoulders.\n'
        '2. Lower your chest towards the floor, keeping your body straight.\n'
        '3. Push back up. The elevated feet increase the load on the upper chest and shoulders.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_chair_diamond_push_ups',
    name: 'Diamond Push-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps, Inner Chest**\n\n'
        '1. Place your hands together under your chest, forming a diamond shape.\n'
        '2. Keep your elbows close to your body as you lower your chest towards your hands.\n'
        '3. Push back up, focusing on the triceps and inner chest squeeze.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_chair_plyometric_push_ups',
    name: 'Plyometric Push-Up (hands on chair)',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Triceps (Power)**\n\n'
        '1. Place your hands on a sturdy chair or bench, shoulder‑width apart.\n'
        '2. Lower your chest towards the chair, then explode upward so your hands leave the chair.\n'
        '3. Land softly and immediately go into the next rep.\n'
        '4. This builds explosive upper‑body power.',
  ),
];
