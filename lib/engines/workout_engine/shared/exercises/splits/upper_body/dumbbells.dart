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

const List<ExercisePoolEntry> upperBodyDumbbellExercises = [
  ExercisePoolEntry(
    id: 'upper_db_dumbbell_bench_press',
    name: 'Dumbbell Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders, Triceps**\n\n'
        '1. Lie on a flat bench with a dumbbell in each hand, resting them on your thighs.\n'
        '2. Kick the weights up to shoulder height, palms facing forward.\n'
        '3. Press the dumbbells upward until your arms are fully extended, bringing them close together at the top.\n'
        '4. Lower them slowly to the sides of your chest, keeping your elbows at about 45°.\n'
        '5. Press back up explosively, squeezing your chest at the top.',
  ),
  ExercisePoolEntry(
    id: 'upper_db_dumbbell_rows',
    name: 'Dumbbell Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Place your left knee and hand on a flat bench, keeping your back flat and parallel to the floor.\n'
        '2. Hold a dumbbell in your right hand, letting it hang straight down.\n'
        '3. Pull the dumbbell up towards your hip, squeezing your lats and biceps.\n'
        '4. Lower with control, then complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'upper_db_shoulder_press',
    name: 'Dumbbell Shoulder Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Sit on a bench with back support, holding dumbbells at shoulder height with palms facing forward.\n'
        '2. Press the weights overhead until your arms are fully extended, keeping them close together.\n'
        '3. Pause briefly at the top, then lower them back to shoulder height with control.\n'
        '4. Keep your core braced and avoid arching your back.',
  ),
  ExercisePoolEntry(
    id: 'upper_db_bicep_curls',
    name: 'Bicep Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.forearms],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a dumbbell in each hand, palms facing forward, arms fully extended.\n'
        '2. Keeping your elbows fixed at your sides, curl the dumbbells up towards your shoulders.\n'
        '3. Squeeze your biceps at the top, then lower the weights slowly back to the starting position.\n'
        '4. Avoid swinging your body; use strict form.',
  ),
  ExercisePoolEntry(
    id: 'upper_db_hammer_curls',
    name: 'Hammer Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.biceps, MuscleGroup.forearms],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps, Forearms**\n\n'
        '1. Stand with feet shoulder‑width apart, holding dumbbells at your sides with a neutral grip (palms facing each other).\n'
        '2. Curl the dumbbells up towards your shoulders, keeping your elbows pinned to your sides.\n'
        '3. Do not rotate your wrists; maintain the neutral grip throughout.\n'
        '4. Squeeze at the top, then lower slowly.',
  ),
];
