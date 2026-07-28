// lib/engines/workout_engine/shared/exercises/splits/legs_exercises.dart

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

/// List of exercises for the 'Legs' split (used by PPL and 5‑day program).
///
/// Prefix for all ids: 'legs_'
///
/// This file is already well‑stocked with bodyweight exercises (14+ variants)
/// so users with only bodyweight equipment always have enough choices to fill
/// any session duration (desiredCount 4–8). No additions are required.
const List<ExercisePoolEntry> legsExercises = [
  // ---- Bodyweight exercises (14+ variants) ----
  ExercisePoolEntry(
    id: 'legs_bodyweight_squats',
    name: 'Bodyweight Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Stand with feet shoulder-width apart.\n'
        '2. Lower your hips back and down as if sitting in a chair.\n'
        '3. Go as low as you can while keeping chest up.\n'
        '4. Push through heels to return to standing.',
  ),
  ExercisePoolEntry(
    id: 'legs_jump_squats',
    name: 'Jump Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
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
    id: 'legs_sumo_squats',
    name: 'Sumo Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
    ],
    secondaryMuscles: [MuscleGroup.adductors],
    usesWeight: false,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Inner Thighs, Glutes, Quadriceps**\n\n'
        '1. Stand with feet wider than shoulder-width, toes pointed out.\n'
        '2. Lower your hips straight down, keeping knees tracking over toes.\n'
        '3. Push through heels to stand back up.',
  ),
  ExercisePoolEntry(
    id: 'legs_pistol_squats_assisted',
    name: 'Pistol Squats (assisted)',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
    ],
    secondaryMuscles: [MuscleGroup.calves],
    usesWeight: false,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes (unilateral)**\n\n'
        '1. Stand on one leg, extend the other forward.\n'
        '2. Squat down on the standing leg.\n'
        '3. Push back up.',
  ),
  ExercisePoolEntry(
    id: 'legs_lunges',
    name: 'Lunges',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Step forward with one leg, lowering your hips until both knees are bent at 90°.\n'
        '2. Push back to start and repeat on the other leg.',
  ),
  ExercisePoolEntry(
    id: 'legs_walking_lunges',
    name: 'Walking Lunges',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Step forward into a lunge, lowering your back knee towards the floor.\n'
        '2. Push off your back foot and step directly into the next lunge.\n'
        '3. Continue alternating legs as you move forward.',
  ),
  ExercisePoolEntry(
    id: 'legs_side_lunges',
    name: 'Side Lunges',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
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
    id: 'legs_bulgarian_split_squats',
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
    id: 'legs_step_ups',
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
    id: 'legs_glute_bridges',
    name: 'Glute Bridges',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.hamstrings],
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
    id: 'legs_single_leg_glute_bridges',
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
    id: 'legs_hip_thrusts',
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
    id: 'legs_calf_raises',
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

  // ---- Equipment-based exercises (for users with additional gear) ----
  // (Kept so that users with dumbbells, barbells, machines also have options.)
  ExercisePoolEntry(
    id: 'legs_dumbbell_bulgarian_split_squats',
    name: 'Dumbbell Bulgarian Split Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Hold a dumbbell in each hand, one foot resting on a bench behind you.\n'
        '2. Lower into a lunge until your back knee nearly touches the floor.\n'
        '3. Push back up through your front heel.',
  ),
  ExercisePoolEntry(
    id: 'legs_goblet_squats',
    name: 'Goblet Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
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
        '1. Hold a dumbbell vertically against your chest, hands under the top plate.\n'
        '2. Perform a squat as described above, keeping the weight close.',
  ),
  ExercisePoolEntry(
    id: 'legs_kettlebell_goblet_squats',
    name: 'Kettlebell Goblet Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
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
    id: 'legs_kettlebell_swings',
    name: 'Kettlebell Swings',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
      MuscleGroup.absCore,
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
    id: 'legs_barbell_squats',
    name: 'Barbell Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
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
    id: 'legs_smith_machine_squats',
    name: 'Smith Machine Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.smithMachine,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
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
        '1. Position the bar across your upper back under the Smith machine.\n'
        '2. Squat down along the fixed vertical path.\n'
        '3. Drive through your heels to stand back up.',
  ),
  ExercisePoolEntry(
    id: 'legs_front_squats',
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
    id: 'legs_barbell_deadlifts',
    name: 'Barbell Deadlifts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [
      MuscleGroup.hamstrings,
      MuscleGroup.glutes,
      MuscleGroup.quadriceps,
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
    id: 'legs_sumo_deadlifts',
    name: 'Sumo Deadlifts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
      MuscleGroup.quadriceps,
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
    id: 'legs_kettlebell_deadlifts',
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
    id: 'legs_romanian_deadlifts',
    name: 'Romanian Deadlifts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings, Glutes**\n\n'
        '1. Stand with feet hip-width apart, dumbbells in front of thighs.\n'
        '2. Hinge at hips, push butt back, lower dumbbells along your shins.\n'
        '3. Feel the stretch in hamstrings, then return to start.',
  ),
  ExercisePoolEntry(
    id: 'legs_barbell_romanian_deadlifts',
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
    id: 'legs_barbell_hip_thrusts',
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
  ExercisePoolEntry(
    id: 'legs_dumbbell_lunges',
    name: 'Dumbbell Lunges',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
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
        '1. Hold dumbbells at your sides.\n'
        '2. Perform a lunge as described above.',
  ),
  ExercisePoolEntry(
    id: 'legs_dumbbell_step_ups',
    name: 'Dumbbell Step-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Hold a dumbbell in each hand.\n'
        '2. Step up onto a platform, driving through your front heel.\n'
        '3. Step back down with control and repeat.',
  ),
  ExercisePoolEntry(
    id: 'legs_leg_press',
    name: 'Leg Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legPressMachine,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
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
        '1. Sit on the leg press machine, feet on the platform shoulder-width apart.\n'
        '2. Lower the platform until your knees are at 90°.\n'
        '3. Press back up without locking your knees.',
  ),
  ExercisePoolEntry(
    id: 'legs_hack_squats',
    name: 'Hack Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.hackSquatMachine,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Position yourself in the hack squat machine, shoulders under the pads.\n'
        '2. Lower down until your knees reach about 90 degrees.\n'
        '3. Push through your heels to return to start.',
  ),
  ExercisePoolEntry(
    id: 'legs_leg_extensions',
    name: 'Leg Extensions',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legExtensionMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps**\n\n'
        '1. Sit on the leg extension machine, shins behind the pad.\n'
        '2. Extend your legs until straight.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'legs_leg_curls',
    name: 'Leg Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legCurlMachine,
    targetMuscles: [MuscleGroup.hamstrings],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings**\n\n'
        '1. Lie face down on the leg curl machine, ankles under the pads.\n'
        '2. Curl your heels towards your glutes.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'legs_cable_glute_kickbacks',
    name: 'Cable Glute Kickbacks',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes**\n\n'
        '1. Attach an ankle strap to a low pulley and secure it around your ankle.\n'
        '2. Kick your leg back and up, squeezing your glute.\n'
        '3. Return with control, then switch sides.',
  ),
  ExercisePoolEntry(
    id: 'legs_seated_calf_raises',
    name: 'Seated Calf Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.calves],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Calves (soleus)**\n\n'
        '1. Sit at the calf raise machine, pads resting on your knees.\n'
        '2. Raise your heels as high as possible.\n'
        '3. Lower slowly for a full stretch.',
  ),
  ExercisePoolEntry(
    id: 'legs_dumbbell_calf_raises',
    name: 'Dumbbell Calf Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
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
        '1. Hold a dumbbell in each hand, stand on the edge of a step.\n'
        '2. Raise your heels as high as possible.\n'
        '3. Lower slowly below the step for a full stretch.',
  ),
];
