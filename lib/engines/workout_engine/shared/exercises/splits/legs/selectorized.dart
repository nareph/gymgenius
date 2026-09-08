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

const List<ExercisePoolEntry> legsSelectorizedExercises = [
  ExercisePoolEntry(
    id: 'legs_selector_seated_calf_raises',
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
  ExercisePoolEntry(
    id: 'legs_selector_standing_calf_raises',
    name: 'Standing Calf Raises',
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
    description: '**Target: Calves (Gastrocnemius)**\n\n'
        '1. Stand on the standing calf raise machine, with your shoulders under the pads and feet on the step.\n'
        '2. Lower your heels down for a stretch, then raise them as high as possible.\n'
        '3. Squeeze your calves at the top, hold for a second.\n'
        '4. Lower with control.\n'
        '5. Keep your knees straight throughout for maximum gastrocnemius activation.',
  ),
  ExercisePoolEntry(
    id: 'legs_selector_leg_curl_seated',
    name: 'Seated Leg Curl',
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
        '1. Sit on the seated leg curl machine, with the pad resting on the front of your ankles.\n'
        '2. Curl the weight towards your glutes by flexing your hamstrings.\n'
        '3. Squeeze at the peak, then lower with control.\n'
        '4. Keep your hips pressed against the seat.\n'
        '5. This variation targets the hamstrings from a seated position, emphasising the medial head.',
  ),
  ExercisePoolEntry(
    id: 'legs_selector_hip_abduction',
    name: 'Selectorized Hip Adduction',
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
    description: '**Target: Glutes, TFL**\n\n'
        '1. Sit on the hip abduction machine, with your thighs against the pads and your hands on the handles.\n'
        '2. Press your thighs outward against the pads, squeezing your glute medius.\n'
        '3. Hold for a second at the peak, then return with control.\n'
        '4. Keep your torso stable and avoid using momentum.\n'
        '5. This targets the hip abductors and glute medius.',
  ),
  ExercisePoolEntry(
    id: 'legs_selector_hip_adduction',
    name: 'Hip Adduction Machine',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.adductors],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Adductors**\n\n'
        '1. Sit on the hip adduction machine, with your thighs inside the pads and your hands on the handles.\n'
        '2. Squeeze your thighs together against the pads, engaging your adductors.\n'
        '3. Hold for a second at the peak, then return with control.\n'
        '4. Keep your torso stable and avoid using momentum.\n'
        '5. This targets the inner thigh muscles.',
  ),
];
