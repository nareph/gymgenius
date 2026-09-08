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

const List<ExercisePoolEntry> backSelectorizedExercises = [
  ExercisePoolEntry(
    id: 'back_selector_seated_row',
    name: 'Selectorized Seated Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Sit on the seated row machine, brace your feet against the footplates, and keep your knees slightly bent.\n'
        '2. Grasp the V‑handle or bar, lean forward slightly at the hips, and then pull the handle towards your abdomen.\n'
        '3. Squeeze your shoulder blades together at the peak contraction, then return slowly with control.\n'
        '4. Keep your back straight and avoid using excessive momentum.\n'
        '5. Adjust the seat height so the handles are at chest level for optimal range of motion.',
  ),
  ExercisePoolEntry(
    id: 'back_selector_lat_pulldown',
    name: 'Selectorized Lat Pulldown',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats, Biceps**\n\n'
        '1. Sit at the lat pulldown machine, secure your thighs under the pads, and grip the bar with an overhand grip slightly wider than shoulder‑width.\n'
        '2. Lean back slightly, keep your chest up, and pull the bar down to your upper chest, driving your elbows down and back.\n'
        '3. Squeeze your lats at the bottom, then let the bar rise slowly back to the starting position.\n'
        '4. Control the movement; do not use momentum.\n'
        '5. Variations: use a wide grip, neutral grip, or underhand grip for different muscle emphasis.',
  ),
  ExercisePoolEntry(
    id: 'back_selector_chest_supported_row',
    name: 'Selectorized Chest-Supported Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.biceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back**\n\n'
        '1. Lie chest‑down on the chest‑supported row machine, gripping the handles at chest height.\n'
        '2. Pull the handles towards your chest, driving your elbows back and squeezing your shoulder blades together.\n'
        '3. Pause at the peak contraction, then slowly release the weight back to the starting position.\n'
        '4. Keep your chest against the pad and avoid lifting your torso.\n'
        '5. This machine removes lower back strain, allowing you to focus entirely on the back muscles.',
  ),
  ExercisePoolEntry(
    id: 'back_selector_rear_delt_fly',
    name: 'Selectorized Rear Delt Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts**\n\n'
        '1. Sit on the rear delt machine, adjust the seat so your arms are parallel to the floor when you grip the handles.\n'
        '2. Position your elbows against the pads and grasp the handles.\n'
        '3. Push the handles back and outward, squeezing your shoulder blades together.\n'
        '4. Pause at the peak contraction, then return with control.\n'
        '5. Use a light weight to focus on strict form and the mind‑muscle connection.',
  ),
  ExercisePoolEntry(
    id: 'back_selector_pulldown_wide_grip',
    name: 'Wide-Grip Lat Pulldown',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.biceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats (Width)**\n\n'
        '1. Use a wide‑grip bar on the lat pulldown machine, with your hands placed much wider than shoulder‑width.\n'
        '2. Sit with your thighs secured, lean back slightly, and pull the bar down to your upper chest.\n'
        '3. Focus on squeezing your lats and driving your elbows down and outward.\n'
        '4. Return slowly, feeling the stretch in your lats.\n'
        '5. This variation is excellent for developing lat width and the V‑taper.',
  ),
];
