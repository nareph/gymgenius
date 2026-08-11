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

const List<ExercisePoolEntry> lowerBodyBodyweightExercises = [
  ExercisePoolEntry(
    id: 'lower_bw_squats',
    name: 'Bodyweight Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Stand feet apart.\n'
        '2. Squat down.\n'
        '3. Stand up.',
  ),
  ExercisePoolEntry(
    id: 'lower_bw_jump_squats',
    name: 'Jump Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.calves],
    usesWeight: false,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Squat down.\n'
        '2. Explosively jump up.\n'
        '3. Land softly and repeat.',
  ),
  ExercisePoolEntry(
    id: 'lower_bw_lunges',
    name: 'Lunges',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Step forward.\n'
        '2. Lower hips.\n'
        '3. Push back.',
  ),
  ExercisePoolEntry(
    id: 'lower_bw_side_lunges',
    name: 'Side Lunges',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.adductors],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Inner Thighs, Glutes**\n\n'
        '1. Step to the side, bending the lead knee.\n'
        '2. Push back to center.\n'
        '3. Alternate sides.',
  ),
  ExercisePoolEntry(
    id: 'lower_bw_glute_bridges',
    name: 'Glute Bridges',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes**\n\n'
        '1. Lie on back, knees bent.\n'
        '2. Lift hips off floor.\n'
        '3. Squeeze glutes at top.',
  ),
  ExercisePoolEntry(
    id: 'lower_bw_single_leg_glute_bridges',
    name: 'Single-Leg Glute Bridges',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.hamstrings],
    usesWeight: false,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes (unilateral)**\n\n'
        '1. Lie on back, one foot on floor, other leg extended.\n'
        '2. Lift hips off floor using the grounded leg.\n'
        '3. Squeeze glute, lower with control.',
  ),
  ExercisePoolEntry(
    id: 'lower_bw_sumo_squats',
    name: 'Sumo Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.adductors
    ],
    secondaryMuscles: [MuscleGroup.hamstrings],
    usesWeight: false,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Quadriceps, Glutes, Adductors**\n\n'
        '1. Stand with feet wide, toes pointed out.\n'
        '2. Squat down, keeping chest up.\n'
        '3. Push through heels to stand.',
  ),
];
