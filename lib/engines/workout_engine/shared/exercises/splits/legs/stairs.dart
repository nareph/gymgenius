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

const List<ExercisePoolEntry> legsStairsExercises = [
  ExercisePoolEntry(
    id: 'legs_stairs_step_ups',
    name: 'Step-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.stairsOrStep,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Stand in front of a sturdy elevated platform or step.\n'
        '2. Step up with one foot, driving through the heel to stand on top.\n'
        '3. Step back down with control and repeat.',
  ),
  ExercisePoolEntry(
    id: 'legs_stairs_calf_raises',
    name: 'Calf Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.stairsOrStep,
    targetMuscles: [MuscleGroup.calves],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Calves**\n\n'
        '1. Stand on the edge of a step.\n'
        '2. Raise your heels as high as possible.\n'
        '3. Lower slowly below the step for a full stretch.',
  ),
  ExercisePoolEntry(
    id: 'legs_stairs_single_leg_calf_raises',
    name: 'Single-Leg Calf Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.stairsOrStep,
    targetMuscles: [MuscleGroup.calves],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Calves**\n\n'
        '1. Stand on one foot on the edge of a step.\n'
        '2. Raise your heel as high as possible.\n'
        '3. Lower slowly below the step for a full stretch.',
  ),
  ExercisePoolEntry(
    id: 'legs_stairs_box_jumps',
    name: 'Box Jumps',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.stairsOrStep,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.calves
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes, Calves**\n\n'
        '1. Stand in front of a sturdy box/step.\n'
        '2. Squat down and jump onto the box.\n'
        '3. Land softly and step back down.',
  ),
  ExercisePoolEntry(
    id: 'legs_stairs_lateral_step_ups',
    name: 'Lateral Step-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.stairsOrStep,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.adductors
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Quadriceps, Glutes, Adductors**\n\n'
        '1. Stand sideways to a step.\n'
        '2. Step up sideways with the lead foot, then bring the other foot up.\n'
        '3. Step down sideways and repeat.',
  ),
];
