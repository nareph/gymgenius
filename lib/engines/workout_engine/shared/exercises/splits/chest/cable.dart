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

const List<ExercisePoolEntry> chestCableExercises = [
  ExercisePoolEntry(
    id: 'chest_cable_fly',
    name: 'Cable Flyes',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Isolation & Stretch)**\n\n'
        '1. Set both pulleys at shoulder height and attach D‑handles.\n'
        '2. Stand in the middle, grab the handles with palms facing down, and step forward into a split stance.\n'
        '3. Keeping a slight bend in your elbows, bring your hands together in front of your chest.\n'
        '4. Squeeze your chest at the peak contraction, then slowly return to the stretch position.\n'
        '5. Control the negative phase for maximum muscle fibre recruitment.',
  ),
  ExercisePoolEntry(
    id: 'chest_cable_crossover',
    name: 'Cable Crossover',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Constant Tension)**\n\n'
        '1. Set pulleys at chest height, stand between them, grab handles.\n'
        '2. Step forward into a staggered stance, arms extended.\n'
        '3. Bring your hands together in front of your chest, crossing them slightly if desired.\n'
        '4. Hold the contraction for a second, then slowly return to the starting position.\n'
        '5. Keep your core braced and your shoulders down.',
  ),
  ExercisePoolEntry(
    id: 'chest_cable_low_fly',
    name: 'Low Cable Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Upper Chest**\n\n'
        '1. Set pulleys to the lowest position, attach handles.\n'
        '2. Stand in the centre, grab handles with palms up (underhand grip).\n'
        '3. Bring your hands up and together in front of your upper chest.\n'
        '4. Squeeze at the top, then lower with control.\n'
        '5. This low‑to‑high path targets the upper pectoral fibres.',
  ),
  ExercisePoolEntry(
    id: 'chest_cable_high_fly',
    name: 'High Cable Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Lower Chest**\n\n'
        '1. Set pulleys to the highest position.\n'
        '2. Grab handles with palms facing down, step forward.\n'
        '3. Bring your hands downward and together in front of your lower chest.\n'
        '4. Squeeze at the bottom, then return slowly.\n'
        '5. This high‑to‑low path emphasises the lower sternal head.',
  ),
  ExercisePoolEntry(
    id: 'chest_cable_single_arm_fly',
    name: 'Single Arm Cable Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Unilateral Correction)**\n\n'
        '1. Set a single pulley at chest height.\n'
        '2. Stand sideways, grab the handle with the arm farthest from the stack.\n'
        '3. Perform a fly motion across your body, bringing your hand to the centre.\n'
        '4. Squeeze and slowly return.\n'
        '5. This helps correct imbalances and improves control.',
  ),
];
