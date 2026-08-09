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

const List<ExercisePoolEntry> pullKettlebellExercises = [
  ExercisePoolEntry(
    id: 'pull_kb_kettlebell_rows',
    name: 'Kettlebell Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Hinge forward holding a kettlebell in one hand, other hand on a bench.\n'
        '2. Pull the kettlebell towards your hip.\n'
        '3. Lower with control, then switch sides.',
  ),
  ExercisePoolEntry(
    id: 'pull_kb_single_arm_swing',
    name: 'Single-Arm Kettlebell Swing',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [
      MuscleGroup.back,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Glutes, Hamstrings**\n\n'
        '1. Stand with feet shoulder-width apart, hold kettlebell with one hand.\n'
        '2. Hinge at hips, swing the kettlebell back between legs.\n'
        '3. Drive hips forward to swing it up to chest height.\n'
        '4. Repeat and switch sides.',
  ),
  ExercisePoolEntry(
    id: 'pull_kb_deadlift',
    name: 'Kettlebell Deadlift',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [
      MuscleGroup.back,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Full Posterior Chain**\n\n'
        '1. Stand over the kettlebell, hinge down and grip the handle.\n'
        '2. Drive through heels to stand up straight.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_kb_shrugs',
    name: 'Kettlebell Shrugs',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.traps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Traps**\n\n'
        '1. Hold a kettlebell in each hand at your sides.\n'
        '2. Shrug your shoulders straight up towards your ears.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'pull_kb_renagade_row',
    name: 'Kettlebell Renegade Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.back, MuscleGroup.absCore, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Core, Biceps**\n\n'
        '1. Start in a plank holding a kettlebell in each hand.\n'
        '2. Row one kettlebell up towards your hip while stabilizing with the other.\n'
        '3. Lower and repeat on the other side.',
  ),
];
