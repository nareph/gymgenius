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

const List<ExercisePoolEntry> upperBodySmithExercises = [
  ExercisePoolEntry(
    id: 'upper_smith_bench_press',
    name: 'Smith Machine Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
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
    description: '**Target: Chest, Triceps**\n\n'
        '1. Place a flat bench under the Smith machine bar, align it so the bar lowers to your mid‑chest.\n'
        '2. Lie back, grip the bar slightly wider than shoulder‑width, and unrack it.\n'
        '3. Lower the bar to your chest, keeping your elbows at about 75°.\n'
        '4. Press back up along the fixed path, squeezing your chest at the top.\n'
        '5. The Smith machine provides stability, great for beginners or when going heavy.',
  ),
  ExercisePoolEntry(
    id: 'upper_smith_shoulder_press',
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
    id: 'upper_smith_row',
    name: 'Smith Machine Bent-Over Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.smithMachine,
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
        '1. Set the bar at waist height, bend at the waist with a flat back, and grip the bar with an overhand grip, hands shoulder‑width apart.\n'
        '2. Pull the bar towards your lower chest, squeezing your shoulder blades together.\n'
        '3. Lower with control back to the starting position.\n'
        '4. Keep your core engaged and avoid rounding your back.',
  ),
  ExercisePoolEntry(
    id: 'upper_smith_shrugs',
    name: 'Smith Machine Shrugs',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.traps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Traps**\n\n'
        '1. Stand with the bar resting in front of your thighs, grip it with an overhand grip, hands shoulder‑width apart.\n'
        '2. Keeping your arms straight, shrug your shoulders straight up towards your ears.\n'
        '3. Hold for a second, then lower with control.\n'
        '4. Avoid rolling your shoulders – move vertically.',
  ),
  ExercisePoolEntry(
    id: 'upper_smith_curl',
    name: 'Smith Machine Bicep Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.smithMachine,
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
        '1. Stand facing the Smith machine, grip the bar with an underhand grip, hands shoulder‑width apart, bar resting on your thighs.\n'
        '2. Keeping your elbows fixed, curl the bar up towards your shoulders.\n'
        '3. Squeeze your biceps at the top, then lower slowly back to the starting position.\n'
        '4. Avoid using your back to swing the weight.',
  ),
];
