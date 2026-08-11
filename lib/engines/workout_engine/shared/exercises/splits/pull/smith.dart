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

const List<ExercisePoolEntry> pullSmithExercises = [
  ExercisePoolEntry(
    id: 'pull_smith_inverted_rows',
    name: 'Smith Machine Inverted Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Set the Smith machine bar at hip height, lie underneath and grip it with hands shoulder-width apart.\n'
        '2. Keeping your body straight, pull your chest towards the bar.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_smith_bent_over_row',
    name: 'Smith Machine Bent-Over Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Set the bar on the Smith machine, bend at the hips with a flat back.\n'
        '2. Pull the bar towards your lower chest.\n'
        '3. Squeeze shoulder blades, then lower.',
  ),
  ExercisePoolEntry(
    id: 'pull_smith_shrugs',
    name: 'Smith Machine Shrugs',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.traps, MuscleGroup.back],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Traps**\n\n'
        '1. Stand with the Smith bar at thigh height, grip with overhand grip.\n'
        '2. Shrug your shoulders straight up towards your ears.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_smith_deadlift',
    name: 'Smith Machine Deadlift',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.smithMachine,
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
        '1. Position the Smith bar over midfoot, grip the bar with a flat back.\n'
        '2. Drive through your heels to stand up.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_smith_single_arm_row',
    name: 'Smith Single-Arm Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps (unilateral)**\n\n'
        '1. Set the bar at waist height, stand sideways, grip the bar with one hand.\n'
        '2. Pull the bar towards your hip, squeezing your lat.\n'
        '3. Lower with control, then switch sides.',
  ),
];
