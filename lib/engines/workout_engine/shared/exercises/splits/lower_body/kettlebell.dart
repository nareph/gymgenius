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

const List<ExercisePoolEntry> lowerBodyKettlebellExercises = [
  ExercisePoolEntry(
    id: 'lower_kb_kettlebell_swings',
    name: 'Kettlebell Swings',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
      MuscleGroup.absCore
    ],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes, Hamstrings, Core**\n\n'
        '1. Stand with feet shoulder‑width apart, a kettlebell on the floor in front of you.\n'
        '2. Hinge at your hips, grasp the kettlebell with both hands, and swing it back between your legs.\n'
        '3. Explosively drive your hips forward to swing the kettlebell up to chest height.\n'
        '4. Let the kettlebell swing back down between your legs, keeping your back flat.\n'
        '5. Repeat for the desired number of reps, maintaining a steady rhythm.',
  ),
  ExercisePoolEntry(
    id: 'lower_kb_goblet_squats',
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
        '1. Hold a kettlebell by the horns (or the handle) against your chest, elbows pointing down.\n'
        '2. Stand with feet shoulder‑width apart, keep your chest up.\n'
        '3. Squat down as low as you can while keeping the kettlebell close to your body.\n'
        '4. Drive through your heels to stand back up.\n'
        '5. This movement reinforces proper squat mechanics.',
  ),
  ExercisePoolEntry(
    id: 'lower_kb_deadlifts',
    name: 'Kettlebell Deadlifts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.back],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings, Glutes**\n\n'
        '1. Stand over a kettlebell with feet hip‑width apart, the kettlebell between your legs.\n'
        '2. Hinge at your hips, keeping your back flat, and grip the kettlebell handle with both hands.\n'
        '3. Drive through your heels to stand up, keeping the kettlebell close to your body.\n'
        '4. Squeeze your glutes at the top, then lower the kettlebell back to the floor with control.\n'
        '5. Keep your core braced throughout.',
  ),
  ExercisePoolEntry(
    id: 'lower_kb_lunges',
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
        '1. Hold a kettlebell in each hand or a single kettlebell in the rack position.\n'
        '2. Step forward into a lunge, lowering your hips until both knees are bent at 90°.\n'
        '3. Push through your front heel to return to the starting position.\n'
        '4. Alternate legs with each rep.\n'
        '5. Keep your torso upright and the kettlebell(s) stable.',
  ),
  ExercisePoolEntry(
    id: 'lower_kb_single_leg_deadlift',
    name: 'Kettlebell Single-Leg Deadlift',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings, Glutes (Unilateral)**\n\n'
        '1. Stand on one leg, holding a kettlebell in the opposite hand.\n'
        '2. Hinge at your hips, keeping your back flat, and lower the kettlebell towards the floor.\n'
        '3. Keep your standing leg slightly bent and your core engaged.\n'
        '4. Drive through the heel of the standing leg to return to the starting position, squeezing your glute.\n'
        '5. Complete all reps on one side before switching.',
  ),
];
