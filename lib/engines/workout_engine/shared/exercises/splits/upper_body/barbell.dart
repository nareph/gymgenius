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

const List<ExercisePoolEntry> upperBodyBarbellExercises = [
  ExercisePoolEntry(
    id: 'upper_bb_bench_press',
    name: 'Barbell Bench Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Triceps**\n\n'
        '1. Lie on a flat bench with your eyes directly under the bar.\n'
        '2. Grip the barbell slightly wider than shoulder‑width, wrap your thumbs around.\n'
        '3. Unrack the bar and hold it above your chest with arms fully extended.\n'
        '4. Lower the bar to your mid‑chest, keeping your elbows at about 75°.\n'
        '5. Drive the bar back up explosively, squeezing your chest at the top.\n'
        '6. Keep your feet planted and your back slightly arched.',
  ),
  ExercisePoolEntry(
    id: 'upper_bb_overhead_press',
    name: 'Overhead Barbell Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Stand with feet shoulder‑width apart, holding the bar at shoulder height with an overhand grip, hands just outside your shoulders.\n'
        '2. Keep your core tight and press the bar overhead until your arms are fully extended.\n'
        '3. Pause briefly at the top, then lower the bar back to shoulder height with control.\n'
        '4. Avoid arching your back excessively; keep the bar path vertical.',
  ),
  ExercisePoolEntry(
    id: 'upper_bb_bent_over_row',
    name: 'Barbell Bent-Over Row',
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
        '1. Bend at the waist with your back flat, knees slightly bent, holding the bar with an overhand grip, hands shoulder‑width apart.\n'
        '2. Let the bar hang at arm’s length, then pull it towards your lower chest, squeezing your shoulder blades together.\n'
        '3. Lower the bar with control back to the starting position.\n'
        '4. Keep your core engaged and avoid rounding your back.',
  ),
  ExercisePoolEntry(
    id: 'upper_bb_shrugs',
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
    description: '**Target: Traps**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a barbell in front of your thighs with an overhand grip, hands shoulder‑width apart.\n'
        '2. Keeping your arms straight, shrug your shoulders straight up towards your ears as high as possible.\n'
        '3. Hold the contraction for a second, then lower back down with control.\n'
        '4. Avoid rolling your shoulders – move vertically for maximum trap activation.',
  ),
  ExercisePoolEntry(
    id: 'upper_bb_curl',
    name: 'Standing Barbell Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.forearms],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a barbell with an underhand grip, hands shoulder‑width apart, bar resting on your thighs.\n'
        '2. Keeping your elbows fixed at your sides, curl the bar up towards your shoulders, squeezing your biceps.\n'
        '3. Pause at the top, then lower the bar slowly back to the starting position.\n'
        '4. Avoid swinging your body – use strict form.',
  ),
];
