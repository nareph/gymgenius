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

const List<ExercisePoolEntry> legsChairExercises = [
  ExercisePoolEntry(
    id: 'legs_chair_bulgarian_split_squats',
    name: 'Bulgarian Split Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Stand a couple of feet in front of a bench, resting one foot behind you on it.\n'
        '2. Lower your back knee towards the floor by bending your front leg.\n'
        '3. Push through your front heel to return to standing.',
  ),
  ExercisePoolEntry(
    id: 'legs_chair_hip_thrusts',
    name: 'Hip Thrusts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes, Hamstrings**\n\n'
        '1. Sit with your upper back against a bench, knees bent, feet flat.\n'
        '2. Drive your hips up towards the ceiling, squeezing your glutes.\n'
        '3. Lower back down with control.',
  ),
  ExercisePoolEntry(
    id: 'legs_chair_step_ups',
    name: 'Step-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Stand in front of a sturdy elevated platform (chair/bench).\n'
        '2. Step up with one foot, driving through the heel to stand on top.\n'
        '3. Step back down with control and repeat.',
  ),
  ExercisePoolEntry(
    id: 'legs_chair_single_leg_step_ups',
    name: 'Single-Leg Step-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Stand on one leg on the bench, the other foot hovering.\n'
        '2. Lower yourself by bending the standing leg until the heel of the hovering foot touches the floor.\n'
        '3. Drive back up to standing on the bench.',
  ),
  ExercisePoolEntry(
    id: 'legs_chair_deep_squat_holds',
    name: 'Deep Squat Holds (with bench)',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Stand in front of a chair and squat down until you lightly touch the seat.\n'
        '2. Hold for 2 seconds, then stand back up.\n'
        '3. Focus on control and depth.',
  ),
];
