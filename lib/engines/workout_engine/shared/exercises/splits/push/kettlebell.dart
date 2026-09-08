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

const List<ExercisePoolEntry> pushKettlebellExercises = [
  ExercisePoolEntry(
    id: 'push_kb_kettlebell_overhead_press',
    name: 'Kettlebell Overhead Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Rack a kettlebell against your forearm at shoulder height, keeping your elbow close to your body.\n'
        '2. Press the kettlebell overhead until your arm is fully extended.\n'
        '3. Pause briefly, then lower it back to the rack position with control.\n'
        '4. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'push_kb_kettlebell_floor_press',
    name: 'Kettlebell Floor Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Triceps**\n\n'
        '1. Lie on the floor with a kettlebell in each hand, resting on your chest.\n'
        '2. Press the kettlebells upward until your arms are extended.\n'
        '3. Lower them with control until your upper arms touch the floor.\n'
        '4. Press back up, focusing on chest and triceps engagement.',
  ),
  ExercisePoolEntry(
    id: 'push_kb_arnold_press',
    name: 'Kettlebell Arnold Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders (all heads), Triceps**\n\n'
        '1. Hold kettlebells in front of your shoulders with palms facing you.\n'
        '2. Press upward while rotating your palms to face forward at the top.\n'
        '3. Reverse the rotation as you lower back down to the starting position.\n'
        '4. Keep the movement smooth and controlled.',
  ),
  ExercisePoolEntry(
    id: 'push_kb_push_press',
    name: 'Kettlebell Push Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps, Quads**\n\n'
        '1. Rack kettlebells at your shoulders, feet hip‑width apart.\n'
        '2. Dip by bending your knees slightly, then drive up explosively and press the kettlebells overhead.\n'
        '3. As you press, use the leg drive to help lift the weight.\n'
        '4. Lower the kettlebells back to the rack position with control.',
  ),
  ExercisePoolEntry(
    id: 'push_kb_bottoms_up_press',
    name: 'Kettlebell Bottoms-Up Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Core (Stability)**\n\n'
        '1. Hold a kettlebell upside down by the handle, with the bell facing upward.\n'
        '2. Press it overhead while keeping it stable – the unstable load forces your core and stabilisers to work hard.\n'
        '3. Lower with control, then switch sides.\n'
        '4. Use a lighter weight than usual to maintain control.',
  ),
];
