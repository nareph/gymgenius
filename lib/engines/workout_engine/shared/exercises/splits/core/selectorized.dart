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

final List<ExercisePoolEntry> coreSelectorizedExercises = [
  ExercisePoolEntry(
    id: 'core_selector_ab_crunch',
    name: 'Selectorized Ab Crunch',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Abs**\n\n'
        '1. Sit on the machine, feet under the pads.\n'
        '2. Crunch down, bringing elbows towards knees.\n'
        '3. Return with control.',
  ),
  ExercisePoolEntry(
    id: 'core_selector_torso_rotation',
    name: 'Selectorized Torso Rotation',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Sit on the machine, grip handles.\n'
        '2. Rotate side to side against resistance.\n'
        '3. Control the movement.',
  ),
  ExercisePoolEntry(
    id: 'core_selector_oblique_crunch',
    name: 'Selectorized Oblique Crunch',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Sit sideways on the machine, one hip against the pad.\n'
        '2. Crunch torso towards your hip.\n'
        '3. Return and switch sides.',
  ),
  ExercisePoolEntry(
    id: 'core_selector_leg_lift',
    name: 'Selectorized Leg Lift',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Sit on a leg lift machine, arms on pads.\n'
        '2. Lift knees towards chest.\n'
        '3. Lower with control.',
  ),
  ExercisePoolEntry(
    id: 'core_selector_ab_extension',
    name: 'Selectorized Ab Extension (Reverse Crunch)',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Lie back on the machine, holding handles above.\n'
        '2. Curl hips off the pad, bringing knees to chest.\n'
        '3. Lower with control.',
  ),
];
