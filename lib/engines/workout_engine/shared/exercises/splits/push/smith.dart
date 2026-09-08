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

const List<ExercisePoolEntry> pushSmithExercises = [
  ExercisePoolEntry(
    id: 'push_smith_smith_machine_bench_press',
    name: 'Smith Machine Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders, Triceps**\n\n'
        '1. Place a flat bench under the Smith machine bar, align it so the bar lowers to your mid‑chest.\n'
        '2. Lie back, grip the bar slightly wider than shoulder‑width, and unrack it.\n'
        '3. Lower the bar to your chest, keeping your elbows at about 75°.\n'
        '4. Press back up along the fixed path, squeezing your chest at the top.\n'
        '5. The Smith machine provides stability, great for beginners or when going heavy.',
  ),
  ExercisePoolEntry(
    id: 'push_smith_incline_press',
    name: 'Smith Machine Incline Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Chest, Shoulders**\n\n'
        '1. Set an incline bench (30–45°) under the Smith bar.\n'
        '2. Lie back and grip the bar, lower it to your upper chest.\n'
        '3. Press the bar up, focusing on the upper pectoral contraction.\n'
        '4. Return with control along the fixed bar path.',
  ),
  ExercisePoolEntry(
    id: 'push_smith_decline_press',
    name: 'Smith Machine Decline Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Chest, Triceps**\n\n'
        '1. Set a decline bench under the Smith bar, secure your feet.\n'
        '2. Lower the bar to your lower chest, keeping elbows tucked.\n'
        '3. Press back up, squeezing your lower pecs.\n'
        '4. The fixed path reduces shoulder stress.',
  ),
  ExercisePoolEntry(
    id: 'push_smith_shoulder_press',
    name: 'Smith Machine Shoulder Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Place a bench (flat or with back support) under the Smith bar.\n'
        '2. Sit with the bar at shoulder height, grip it shoulder‑width apart.\n'
        '3. Press the bar overhead until your arms are fully extended.\n'
        '4. Lower back to shoulder height with control.',
  ),
  ExercisePoolEntry(
    id: 'push_smith_close_grip_press',
    name: 'Smith Machine Close-Grip Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.triceps, MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps, Chest**\n\n'
        '1. Use a flat bench, grip the Smith bar with hands shoulder‑width apart or slightly narrower.\n'
        '2. Lower the bar to your lower chest, keeping your elbows tucked in.\n'
        '3. Press back up, focusing on triceps and inner chest.\n'
        '4. The fixed path helps maintain proper form.',
  ),
];
