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
        '1. Sit on the ab crunch machine, with your feet secured under the pads.\n'
        '2. Grip the handles and keep your arms at a 90° angle.\n'
        '3. Crunch down by curling your torso toward your knees, squeezing your abs.\n'
        '4. Return slowly to the starting position, controlling the resistance.\n'
        '5. Avoid pulling with your arms; the movement should come from your core.',
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
        '1. Sit on the torso rotation machine, gripping the handles firmly.\n'
        '2. Rotate your torso to the right, then to the left, against the resistance.\n'
        '3. Keep your hips stationary and your core engaged.\n'
        '4. Perform the movement in a controlled, steady rhythm.\n'
        '5. Adjust the weight to allow for full range of motion.',
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
        '1. Sit sideways on the oblique crunch machine, placing one hip against the pad.\n'
        '2. Grip the handles and crunch your torso sideways toward your hip.\n'
        '3. Squeeze your oblique at the peak, then return slowly.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. Keep the movement controlled and avoid using momentum.',
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
        '1. Sit on the leg lift machine, placing your arms on the pads for support.\n'
        '2. Rest your legs on the lower pads and lift your knees toward your chest.\n'
        '3. Squeeze your lower abs at the top, then lower with control.\n'
        '4. Keep your back against the pad throughout.\n'
        '5. Use a moderate weight to maintain control.',
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
        '1. Lie back on the ab extension machine, holding the handles above you.\n'
        '2. Curl your hips off the pad, bringing your knees toward your chest.\n'
        '3. Squeeze your lower abs at the peak, then lower with control.\n'
        '4. Keep your neck relaxed and your head resting on the pad.\n'
        '5. Use a light weight to focus on the contraction.',
  ),
];
