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

const List<ExercisePoolEntry> legsSmithExercises = [
  ExercisePoolEntry(
    id: 'legs_smith_squats',
    name: 'Smith Machine Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.smithMachine,
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
        '1. Place a barbell across your upper back (or use the Smith machine bar) and position yourself under the fixed path.\n'
        '2. Unrack the bar and stand with feet shoulder‑width apart, toes slightly pointed out.\n'
        '3. Squat down, keeping your back flat and chest up, following the vertical track.\n'
        '4. Descend until your thighs are parallel to the floor, then drive through your heels to stand up.\n'
        '5. The fixed path helps maintain balance and form.',
  ),
  ExercisePoolEntry(
    id: 'legs_smith_front_squats',
    name: 'Smith Machine Front Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Place the Smith bar across the front of your shoulders, crossing your arms to hold it.\n'
        '2. Stand with feet shoulder‑width apart, elbows high.\n'
        '3. Squat down, keeping your torso as upright as possible, following the track.\n'
        '4. Descend to parallel, then drive up through your heels.\n'
        '5. This variation targets the quads more with less hip hinge.',
  ),
  ExercisePoolEntry(
    id: 'legs_smith_lunges',
    name: 'Smith Machine Lunges',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.smithMachine,
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
        '1. Place the Smith bar across your upper back and position your feet in a staggered stance.\n'
        '2. Lower your back knee toward the floor, keeping your front knee over your ankle.\n'
        '3. Push through your front heel to return to the starting position.\n'
        '4. Alternate legs for each rep or complete a set per leg.\n'
        '5. The fixed path provides stability.',
  ),
  ExercisePoolEntry(
    id: 'legs_smith_hip_thrusts',
    name: 'Smith Machine Hip Thrusts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes, Hamstrings**\n\n'
        '1. Sit on the floor with your upper back against a bench, the Smith bar across your hips (use a pad).\n'
        '2. Place your feet flat on the floor, knees bent.\n'
        '3. Drive through your heels to lift your hips, squeezing your glutes at the top.\n'
        '4. Pause, then lower with control.\n'
        '5. The Smith machine adds stability and allows for heavier loading.',
  ),
  ExercisePoolEntry(
    id: 'legs_smith_calf_raises',
    name: 'Smith Machine Calf Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [MuscleGroup.calves],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Calves**\n\n'
        '1. Place the Smith bar across your shoulders, stand on a step or a raised surface.\n'
        '2. Lower your heels down for a stretch, then raise them as high as possible.\n'
        '3. Squeeze your calves at the top, hold for a second.\n'
        '4. Lower with control.\n'
        '5. The Smith machine provides stability and lets you load heavier than bodyweight.',
  ),
];
