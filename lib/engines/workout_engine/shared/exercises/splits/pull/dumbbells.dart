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

const List<ExercisePoolEntry> pullDumbbellExercises = [
  ExercisePoolEntry(
    id: 'pull_db_dumbbell_rows',
    name: 'Single-Arm Dumbbell Row',
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
        '1. Place one knee and one hand on a flat bench, with your other foot on the floor for stability.\n'
        '2. With your free hand, grab a dumbbell and let it hang straight down, palm facing your body.\n'
        '3. Pull the dumbbell up towards your hip, keeping your elbow close to your body and squeezing your lat.\n'
        '4. Lower with control, feeling the stretch in your lat, then complete all reps on one side before switching.\n'
        '5. Keep your back flat and your core engaged throughout.',
  ),
  ExercisePoolEntry(
    id: 'pull_db_renegade_rows',
    name: 'Renegade Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.back, MuscleGroup.absCore, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Core, Biceps**\n\n'
        '1. Start in a high plank position with a dumbbell in each hand, hands directly under your shoulders.\n'
        '2. Keep your core braced and hips stable, then row the right dumbbell up towards your hip, squeezing your lat.\n'
        '3. Lower the dumbbell back to the floor with control.\n'
        '4. Repeat on the left side, alternating each rep.\n'
        '5. This movement requires significant core stability; use a light weight to maintain form.',
  ),
  ExercisePoolEntry(
    id: 'pull_db_dumbbell_shrugs',
    name: 'Dumbbell Shrugs',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.traps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Trapezius**\n\n'
        '1. Stand upright with feet shoulder‑width apart, holding a dumbbell in each hand at your sides, palms facing your body.\n'
        '2. Keeping your arms straight, shrug your shoulders straight up towards your ears as high as possible.\n'
        '3. Squeeze your traps at the top, hold for a second, then lower with control.\n'
        '4. Avoid rolling your shoulders; focus on a pure vertical movement.\n'
        '5. Use moderate weight to maintain strict form.',
  ),
  ExercisePoolEntry(
    id: 'pull_db_reverse_flyes',
    name: 'Dumbbell Rear Delt Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Upper Back**\n\n'
        '1. Bend forward at the hips with a flat back, holding a light dumbbell in each hand, palms facing each other.\n'
        '2. Let your arms hang straight down, then raise them out to the sides in a wide arc, squeezing your shoulder blades together.\n'
        '3. Pause when your arms are parallel to the floor, then lower with control.\n'
        '4. Keep a slight bend in your elbows throughout the movement.\n'
        '5. Use light weight to focus on form and the contraction of the rear delts.',
  ),
  ExercisePoolEntry(
    id: 'pull_db_bicep_curls',
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
    id: 'pull_db_hammer_curls',
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
    id: 'pull_db_concentration_curls',
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
];
