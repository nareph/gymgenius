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

const List<ExercisePoolEntry> armsDumbbellExercises = [
  ExercisePoolEntry(
    id: 'arms_db_bicep_curls',
    name: 'Bicep Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a dumbbell in each hand, palms facing forward.\n'
        '2. Keeping your elbows pinned to your sides, curl the dumbbells up towards your shoulders.\n'
        '3. Squeeze your biceps at the top, then lower the weights with control back to the starting position.\n'
        '4. Avoid swinging your body; use strict form.\n'
        '5. Perform the movement slowly to maximise muscle tension.',
  ),
  ExercisePoolEntry(
    id: 'arms_db_hammer_curls',
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
    description: '**Target: Biceps (Brachialis), Forearms**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a dumbbell in each hand with a neutral grip (palms facing each other).\n'
        '2. Keeping your elbows pinned to your sides, curl the dumbbells up towards your shoulders without rotating your wrists.\n'
        '3. Squeeze your biceps and forearms at the top, then lower with control.\n'
        '4. This variation places more emphasis on the brachialis and brachioradialis.\n'
        '5. Perform the movement slowly for maximum muscle engagement.',
  ),
  ExercisePoolEntry(
    id: 'arms_db_concentration_curls',
    name: 'Concentration Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps (Peak)**\n\n'
        '1. Sit on a bench, spread your legs, and rest your elbow against your inner thigh on the same side.\n'
        '2. Hold a dumbbell in your hand, arm extended, and let it hang between your legs.\n'
        '3. Curl the dumbbell up towards your shoulder, squeezing your biceps at the top.\n'
        '4. Lower with control, fully extending your arm at the bottom.\n'
        '5. Complete all reps on one side before switching to the other.',
  ),
  ExercisePoolEntry(
    id: 'arms_db_overhead_tricep_extension',
    name: 'Overhead Tricep Extension',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Hold a dumbbell with both hands overhead, arms extended.\n'
        '2. Keeping your upper arms close to your head, bend your elbows to lower the dumbbell behind your head.\n'
        '3. Extend your arms back up to the starting position, squeezing your triceps.\n'
        '4. Keep your elbows stationary throughout the movement.\n'
        '5. Use a light weight to maintain control and focus on the stretch.',
  ),
  ExercisePoolEntry(
    id: 'arms_db_wrist_curls',
    name: 'Wrist Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.forearms],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Forearms**\n\n'
        '1. Sit on a bench with your forearm resting on your thigh, palm facing up, holding a dumbbell.\n'
        '2. Your wrist should hang just past your knee, allowing a full range of motion.\n'
        '3. Curl the weight up using only your wrist, squeezing your forearm muscles at the top.\n'
        '4. Lower with control back to the starting position.\n'
        '5. Complete all reps on one side before switching to the other.',
  ),
];
