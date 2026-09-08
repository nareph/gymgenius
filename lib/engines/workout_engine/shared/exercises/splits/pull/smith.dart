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
        '1. Set the Smith machine bar at hip height and load no weight (or a very light weight).\n'
        '2. Lie under the bar, grip it with an overhand grip, hands shoulder‑width apart, and extend your legs forward with your heels on the floor.\n'
        '3. Keeping your body straight, pull your chest towards the bar by driving your elbows back.\n'
        '4. Squeeze your shoulder blades together at the top, then lower your body with control.\n'
        '5. This is a bodyweight row variation; increase difficulty by elevating your feet or adding weight to the bar.',
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
        '1. Set the Smith machine bar at waist height and load the desired weight.\n'
        '2. Stand over the bar, bend at the hips with a flat back, and grip the bar with an overhand grip, hands slightly wider than shoulders.\n'
        '3. Pull the bar towards your lower chest, driving your elbows back and squeezing your shoulder blades together.\n'
        '4. Pause at the peak contraction, then lower the bar with control back to the starting position.\n'
        '5. Keep your core tight and your back flat throughout the movement.',
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
        '1. Set the Smith machine bar at thigh height and load a heavy weight.\n'
        '2. Stand upright, grip the bar with an overhand grip, hands shoulder‑width apart.\n'
        '3. Shrug your shoulders straight up towards your ears as high as possible, squeezing your traps.\n'
        '4. Hold at the top for a second, then lower the bar back down with control.\n'
        '5. Avoid rolling your shoulders; focus on a pure vertical movement.',
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
        '1. Position the Smith machine bar over the middle of your feet and load the desired weight.\n'
        '2. Hinge at your hips and bend your knees, grip the bar with a shoulder‑width grip, and keep your back flat.\n'
        '3. Drive through your heels to stand up, squeezing your glutes and lats at the top.\n'
        '4. Lower the bar back to the starting position with control, maintaining a flat back.\n'
        '5. The Smith machine\'s fixed bar path helps maintain proper form throughout the movement.',
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
    description: '**Target: Back, Biceps (Unilateral)**\n\n'
        '1. Set the Smith bar at waist height.\n'
        '2. Stand sideways to the bar, grip it with one hand, and keep your feet shoulder‑width apart for balance.\n'
        '3. Pull the bar towards your hip, driving your elbow back and squeezing your lat.\n'
        '4. Lower with control.\n'
        '5. Complete all reps on one side before switching.',
  ),
];
