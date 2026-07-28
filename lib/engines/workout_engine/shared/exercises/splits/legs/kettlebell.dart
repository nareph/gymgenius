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

const List<ExercisePoolEntry> legsKettlebellExercises = [
  ExercisePoolEntry(
    id: 'legs_kb_goblet_squats',
    name: 'Kettlebell Goblet Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Hold a kettlebell by the horns against your chest.\n'
        '2. Squat down keeping your chest up and the kettlebell close.\n'
        '3. Drive through your heels to stand back up.',
  ),
  ExercisePoolEntry(
    id: 'legs_kb_swings',
    name: 'Kettlebell Swings',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
      MuscleGroup.absCore
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes, Hamstrings, Core**\n\n'
        '1. Stand with feet shoulder-width apart, kettlebell on the floor in front of you.\n'
        '2. Hinge at the hips and swing the kettlebell back between your legs.\n'
        '3. Drive your hips forward explosively to swing it up to chest height.',
  ),
  ExercisePoolEntry(
    id: 'legs_kb_deadlifts',
    name: 'Kettlebell Deadlifts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings, Glutes**\n\n'
        '1. Stand over a kettlebell, feet hip-width apart.\n'
        '2. Hinge at the hips and grip the handle, keeping your back flat.\n'
        '3. Drive through your heels to stand up.',
  ),
  ExercisePoolEntry(
    id: 'legs_kb_single_arm_deadlifts',
    name: 'Single-Arm Kettlebell Deadlifts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [
      MuscleGroup.hamstrings,
      MuscleGroup.glutes,
      MuscleGroup.absCore
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings, Glutes, Core**\n\n'
        '1. Stand over a kettlebell with feet shoulder-width apart.\n'
        '2. Hinge and grab the handle with one hand.\n'
        '3. Drive up, keeping your back flat and core engaged.',
  ),
  ExercisePoolEntry(
    id: 'legs_kb_lunges',
    name: 'Kettlebell Lunges',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Hold a kettlebell by the horns or in the rack position.\n'
        '2. Perform a forward lunge, keeping the weight stable.\n'
        '3. Push back to start and alternate.',
  ),
];
