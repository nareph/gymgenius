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

const List<ExercisePoolEntry> lowerBodyLegPressExercises = [
  ExercisePoolEntry(
    id: 'lower_lp_standard',
    name: 'Leg Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legPressMachine,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Sit on leg press, feet on platform.\n'
        '2. Lower platform to 90°.\n'
        '3. Press back up without locking knees.',
  ),
  ExercisePoolEntry(
    id: 'lower_lp_high_foot',
    name: 'Leg Press - High Foot Placement',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legPressMachine,
    targetMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes, Hamstrings**\n\n'
        '1. Place feet high on platform.\n'
        '2. Emphasises hip extension.',
  ),
  ExercisePoolEntry(
    id: 'lower_lp_low_foot',
    name: 'Leg Press - Low Foot Placement',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legPressMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [MuscleGroup.glutes],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps**\n\n'
        '1. Place feet low on platform.\n'
        '2. Emphasises knee extension.',
  ),
  ExercisePoolEntry(
    id: 'lower_lp_single_leg',
    name: 'Single-Leg Leg Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.legPressMachine,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes (unilateral)**\n\n'
        '1. Use one leg on platform.\n'
        '2. Press and control return.\n'
        '3. Switch sides.',
  ),
  ExercisePoolEntry(
    id: 'lower_lp_narrow_stance',
    name: 'Leg Press - Narrow Stance',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legPressMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [MuscleGroup.glutes],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps (outer)**\n\n'
        '1. Place feet close together.\n'
        '2. Press with quad emphasis.',
  ),
];
