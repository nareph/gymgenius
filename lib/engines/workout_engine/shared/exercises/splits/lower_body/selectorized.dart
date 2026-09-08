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

const List<ExercisePoolEntry> lowerBodySelectorizedExercises = [
  ExercisePoolEntry(
    id: 'lower_selector_leg_extension',
    name: 'Selectorized Leg Extension',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
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
        '1. Sit on the leg extension machine with your back against the pad and your shins behind the ankle pad.\n'
        '2. Grasp the handles for stability, keep your knees aligned with the machine\'s pivot.\n'
        '3. Extend your legs until they are straight, squeezing your quads at the top.\n'
        '4. Lower the weight with control back to the starting position.\n'
        '5. Avoid swinging; use a controlled tempo.',
  ),
  ExercisePoolEntry(
    id: 'lower_selector_leg_curl',
    name: 'Selectorized Leg Curl',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
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
        '1. Lie face down on the leg curl machine, with the pad resting just above your heels.\n'
        '2. Grasp the handles for stability and keep your hips pressed against the pad.\n'
        '3. Curl your heels towards your glutes by flexing your hamstrings, squeezing at the peak.\n'
        '4. Lower the weight with control back to the starting position, fully extending your legs.\n'
        '5. Avoid using momentum; perform the movement slowly and deliberately.',
  ),
  ExercisePoolEntry(
    id: 'lower_selector_hip_abduction',
    name: 'Selectorized Hip Abduction',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Glutes**\n\n'
        '1. Sit on the hip abduction machine, with your thighs against the pads and your hands on the handles.\n'
        '2. Press your thighs outward against the pads, squeezing your glute medius.\n'
        '3. Hold for a second at the peak, then return with control.\n'
        '4. Keep your torso stable and avoid using momentum.\n'
        '5. This targets the hip abductors and glute medius.',
  ),
  ExercisePoolEntry(
    id: 'lower_selector_seated_calf_raise',
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
    description: '**Target: Calves (Soleus)**\n\n'
        '1. Sit on the seated calf raise machine, with the pads resting on your knees.\n'
        '2. Place your feet on the platform with your heels hanging off the edge.\n'
        '3. Lower your heels down for a full stretch, then raise them as high as possible.\n'
        '4. Squeeze your calves at the top, hold for a second.\n'
        '5. Lower with control, feeling the stretch.',
  ),
];
