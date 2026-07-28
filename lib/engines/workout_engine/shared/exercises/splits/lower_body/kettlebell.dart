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
        '1. Stand with feet apart, kettlebell on floor.\n'
        '2. Hinge, swing bell back between legs.\n'
        '3. Drive hips forward, swing to chest.',
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
        '1. Hold kettlebell by horns at chest.\n'
        '2. Squat down, keeping chest up.\n'
        '3. Push through heels to stand.',
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
        '1. Stand over kettlebell, hinge down.\n'
        '2. Grip handle, keep back flat.\n'
        '3. Drive through heels to stand.',
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
        '1. Hold kettlebells at shoulders.\n'
        '2. Lunge forward.\n'
        '3. Push back and alternate.',
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
    description: '**Target: Hamstrings, Glutes (unilateral)**\n\n'
        '1. Balance on one leg, kettlebell in opposite hand.\n'
        '2. Hinge forward, lowering kettlebell.\n'
        '3. Return to standing using glute.\n'
        '4. Switch sides.',
  ),
];
