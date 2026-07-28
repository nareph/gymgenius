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

const List<ExercisePoolEntry> legsBarbellExercises = [
  ExercisePoolEntry(
    id: 'legs_bb_squats',
    name: 'Barbell Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
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
        '1. Place a barbell on your upper back, feet shoulder-width apart.\n'
        '2. Squat down to parallel or below.\n'
        '3. Drive through heels to stand up.',
  ),
  ExercisePoolEntry(
    id: 'legs_bb_front_squats',
    name: 'Front Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Rest a barbell across the front of your shoulders, elbows high.\n'
        '2. Squat down keeping your torso upright.\n'
        '3. Drive through heels to stand up.',
  ),
  ExercisePoolEntry(
    id: 'legs_bb_deadlifts',
    name: 'Barbell Deadlifts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [
      MuscleGroup.hamstrings,
      MuscleGroup.glutes,
      MuscleGroup.quadriceps
    ],
    secondaryMuscles: [MuscleGroup.back],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings, Glutes, Lower Back**\n\n'
        '1. Stand with feet hip-width apart, barbell over midfoot.\n'
        '2. Hinge down and grip the bar, keeping your back flat.\n'
        '3. Drive through your heels and stand up straight, bar close to your body.',
  ),
  ExercisePoolEntry(
    id: 'legs_bb_sumo_deadlifts',
    name: 'Sumo Deadlifts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
      MuscleGroup.quadriceps
    ],
    secondaryMuscles: [MuscleGroup.adductors, MuscleGroup.back],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Glutes, Inner Thighs, Hamstrings**\n\n'
        '1. Stand with feet wide, toes pointed out, gripping the bar inside your knees.\n'
        '2. Drive through your heels, keeping your chest up as you stand.\n'
        '3. Lower back down with control.',
  ),
  ExercisePoolEntry(
    id: 'legs_bb_romanian_deadlifts',
    name: 'Barbell Romanian Deadlifts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings, Glutes**\n\n'
        '1. Hold a barbell in front of your thighs, feet hip-width apart.\n'
        '2. Hinge at the hips, lowering the bar along your legs.\n'
        '3. Return to standing by driving your hips forward.',
  ),
  ExercisePoolEntry(
    id: 'legs_bb_hip_thrusts',
    name: 'Barbell Hip Thrusts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes, Hamstrings**\n\n'
        '1. Sit with your upper back against a bench, a barbell over your hips.\n'
        '2. Drive your hips up, squeezing your glutes at the top.\n'
        '3. Lower back down with control.',
  ),
];
