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

const List<ExercisePoolEntry> lowerBodyStairsExercises = [
  ExercisePoolEntry(
    id: 'lower_stairs_step_ups',
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
        '1. Stand in front of a sturdy step or stairs, feet hip‑width apart.\n'
        '2. Step up with your right foot, driving through the heel, and bring your left foot to meet it.\n'
        '3. Step back down with the right foot first, then the left.\n'
        '4. Alternate the lead leg each set or each rep.\n'
        '5. Keep your chest up and core tight.',
  ),
  ExercisePoolEntry(
    id: 'lower_stairs_calf_raises',
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
        '1. Stand on the edge of a step with your heels hanging off.\n'
        '2. Lower your heels down for a deep stretch, then raise them as high as possible.\n'
        '3. Squeeze your calves at the top, hold for a second.\n'
        '4. Lower with control.\n'
        '5. This is a great way to increase range of motion.',
  ),
  ExercisePoolEntry(
    id: 'lower_stairs_single_leg_calf_raises',
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
    description: '**Target: Calves (Unilateral)**\n\n'
        '1. Stand on the edge of a step on one foot, the other foot off the step.\n'
        '2. Lower your heel down for a stretch, then raise it as high as possible.\n'
        '3. Squeeze your calf at the top, hold for a second.\n'
        '4. Lower with control.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'lower_stairs_box_jumps',
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
    description: '**Target: Quadriceps, Glutes, Calves (Power)**\n\n'
        '1. Stand in front of a sturdy box or step, about 12–24 inches high.\n'
        '2. Squat down and explode upward, jumping onto the box.\n'
        '3. Land softly with bent knees, absorbing the impact.\n'
        '4. Step down carefully and reset.\n'
        '5. This builds explosive lower body power.',
  ),
  ExercisePoolEntry(
    id: 'lower_stairs_lateral_step_ups',
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
        '1. Stand sideways to a step, feet together.\n'
        '2. Step up sideways with your right foot onto the step, then bring your left foot up.\n'
        '3. Step down sideways, then repeat on the other side.\n'
        '4. Keep your chest up and core tight.\n'
        '5. This variation targets the inner and outer thighs.',
  ),
];
