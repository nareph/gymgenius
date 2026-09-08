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

const List<ExercisePoolEntry> legsDumbbellExercises = [
  ExercisePoolEntry(
    id: 'legs_db_bulgarian_split_squats',
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
        '1. Hold a dumbbell in each hand, or a single dumbbell in goblet position, and stand about two feet in front of a bench.\n'
        '2. Place the top of one foot on the bench behind you.\n'
        '3. Lower into a lunge until your back knee nearly touches the floor, keeping your torso upright.\n'
        '4. Push through the front heel to return to the starting position.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'legs_db_goblet_squats',
    name: 'Goblet Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
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
        '1. Hold a single dumbbell vertically against your chest, cupping the top plate with both hands.\n'
        '2. Stand with feet shoulder‑width apart, keep your elbows pointing down.\n'
        '3. Squat down as low as you can while keeping your chest up and the weight close.\n'
        '4. Drive through your heels to stand back up.\n'
        '5. This movement is great for learning proper squat form.',
  ),
  ExercisePoolEntry(
    id: 'legs_db_lunges',
    name: 'Dumbbell Lunges',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
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
        '1. Hold a dumbbell in each hand, arms at your sides.\n'
        '2. Step forward with one leg and lower your hips until both knees are bent at 90°.\n'
        '3. Push through the front heel to return to the starting position.\n'
        '4. Repeat with the other leg, alternating each rep.\n'
        '5. Keep your torso upright and core engaged.',
  ),
  ExercisePoolEntry(
    id: 'legs_db_step_ups',
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
        '1. Hold a dumbbell in each hand, stand in front of a sturdy platform (chair, step).\n'
        '2. Place one foot on the platform, drive through the heel to step up, bringing the other foot to meet it.\n'
        '3. Step back down with control.\n'
        '4. Alternate the lead leg with each set.\n'
        '5. Keep your chest up and core tight.',
  ),
  ExercisePoolEntry(
    id: 'legs_db_romanian_deadlifts',
    name: 'Dumbbell Romanian Deadlifts',
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
        '1. Stand with feet hip‑width apart, holding a dumbbell in each hand in front of your thighs.\n'
        '2. Keeping your knees slightly bent, push your hips back and lower the dumbbells along your shins.\n'
        '3. Lower until you feel a stretch in your hamstrings (bar around mid‑shin).\n'
        '4. Drive your hips forward to return to the starting position, squeezing your glutes.\n'
        '5. Keep your back flat and core braced throughout.',
  ),
  ExercisePoolEntry(
    id: 'legs_db_calf_raises',
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
        '1. Stand on the edge of a step or a raised surface, holding a dumbbell in each hand for added weight.\n'
        '2. Lower your heels down until you feel a stretch in your calves.\n'
        '3. Raise your heels as high as possible, squeezing your calves.\n'
        '4. Hold at the top for a second, then lower with control.\n'
        '5. Perform the movement slowly and with full range of motion.',
  ),
];
