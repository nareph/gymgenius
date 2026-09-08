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

const List<ExercisePoolEntry> backBicepsKettlebellExercises = [
  ExercisePoolEntry(
    id: 'back_biceps_kb_kettlebell_rows',
    name: 'Kettlebell Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
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
        '2. With your free hand, grab a kettlebell and let it hang straight down.\n'
        '3. Pull the kettlebell up towards your hip, keeping your elbow close to your body and squeezing your lat.\n'
        '4. Lower with control, feeling the stretch in your lat, then complete all reps on one side before switching.\n'
        '5. Keep your back flat and your core engaged throughout.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_kb_single_arm_swing',
    name: 'Single-Arm Kettlebell Swing',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [
      MuscleGroup.back,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Glutes, Hamstrings**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a kettlebell in one hand between your legs.\n'
        '2. Hinge at your hips, swing the kettlebell back between your legs, keeping your back flat.\n'
        '3. Drive your hips forward explosively to swing the kettlebell up to chest height, squeezing your glutes and lats.\n'
        '4. Allow the kettlebell to swing back down between your legs with control.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_kb_deadlift',
    name: 'Kettlebell Deadlift',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [
      MuscleGroup.back,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Full Posterior Chain**\n\n'
        '1. Stand with feet hip‑width apart, a kettlebell on the floor between your feet.\n'
        '2. Hinge at your hips and bend your knees, grip the kettlebell handle with both hands, and keep your back flat.\n'
        '3. Drive through your heels to stand up, squeezing your glutes and lats at the top.\n'
        '4. Lower the kettlebell back to the floor with control, maintaining a flat back.\n'
        '5. Reset each rep from a dead stop on the floor.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_kb_bicep_curl',
    name: 'Kettlebell Bicep Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.kettlebell,
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
        '1. Stand with feet shoulder‑width apart, holding a kettlebell in each hand with an underhand grip.\n'
        '2. Keeping your elbows pinned to your sides, curl the kettlebells up towards your shoulders.\n'
        '3. Squeeze your biceps at the top, then lower with control.\n'
        '4. Avoid swinging your body; use strict form.\n'
        '5. Perform the movement slowly for maximum biceps activation.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_kb_hammer_curl',
    name: 'Kettlebell Hammer Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.kettlebell,
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
        '1. Stand with feet shoulder‑width apart, holding a kettlebell in each hand with a neutral grip (palms facing each other).\n'
        '2. Keeping your elbows pinned to your sides, curl the kettlebells up towards your shoulders without rotating your wrists.\n'
        '3. Squeeze your biceps and forearms at the top, then lower with control.\n'
        '4. This variation targets the brachialis and brachioradialis muscles.\n'
        '5. Perform the movement slowly for maximum muscle engagement.',
  ),
];
