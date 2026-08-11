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

const List<ExercisePoolEntry> backBicepsBarbellExercises = [
  ExercisePoolEntry(
    id: 'back_biceps_bb_barbell_rows',
    name: 'Barbell Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Bent-over position, overhand grip.\n'
        '2. Pull bar to lower chest.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_bb_t_bar_row',
    name: 'T-Bar Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back (thickness), Biceps**\n\n'
        '1. Straddle a landmine barbell, hinge forward.\n'
        '2. Pull the bar to your chest.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_bb_barbell_shrugs',
    name: 'Barbell Shrugs',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.traps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Trapezius**\n\n'
        '1. Hold a barbell in front of your thighs.\n'
        '2. Shrug your shoulders up towards your ears.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_bb_preacher_curls',
    name: 'Preacher Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
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
        '1. Rest upper arms on a preacher bench.\n'
        '2. Curl the bar up towards your shoulders.',
  ),
  ExercisePoolEntry(
    id: 'back_biceps_bb_deadlift',
    name: 'Barbell Deadlift',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [
      MuscleGroup.back,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Full Posterior Chain**\n\n'
        '1. Stand with feet hip-width apart, barbell over midfoot.\n'
        '2. Hinge down, grip the bar, keep back flat.\n'
        '3. Drive through heels to stand up, then lower with control.',
  ),
];
