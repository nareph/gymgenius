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

const List<ExercisePoolEntry> chestAdjustableBenchExercises = [
  ExercisePoolEntry(
    id: 'chest_bench_incline_db_press',
    name: 'Incline Bench Dumbbell Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.adjustableBench,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Upper Chest**\n\n'
        '1. Set an adjustable bench to a 30–45° incline.\n'
        '2. Lie back with a dumbbell in each hand, resting them on your thighs.\n'
        '3. Kick the weights up to shoulder height, palms facing forward.\n'
        '4. Lower the dumbbells slowly to the sides of your chest, elbows at about 45°.\n'
        '5. Press them back up powerfully, squeezing your upper chest at the top.\n'
        '6. Keep your feet flat on the floor and your back slightly arched.',
  ),
  ExercisePoolEntry(
    id: 'chest_bench_decline_db_press',
    name: 'Decline Bench Dumbbell Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.adjustableBench,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Lower Chest**\n\n'
        '1. Set the bench to a decline position (head lower than hips).\n'
        '2. Secure your feet under the pads, hold dumbbells above your chest.\n'
        '3. Lower the weights to the sides of your lower chest with a controlled tempo.\n'
        '4. Press up forcefully, squeezing your lower pectorals.\n'
        '5. Keep your elbows tucked to protect your shoulders.',
  ),
  ExercisePoolEntry(
    id: 'chest_bench_db_fly',
    name: 'Incline Dumbbell Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.adjustableBench,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Stretch & Contraction)**\n\n'
        '1. Lie on an incline bench with dumbbells held above your chest, palms facing each other.\n'
        '2. Keep a slight bend in your elbows throughout the movement.\n'
        '3. Lower the weights out to the sides in a wide arc until you feel a deep stretch in your chest.\n'
        '4. Bring them back together in a hugging motion, squeezing your pectorals at the top.\n'
        '5. Control the descent and avoid overextending your shoulders.',
  ),
  ExercisePoolEntry(
    id: 'chest_bench_neutral_press',
    name: 'Neutral Grip Dumbbell Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.adjustableBench,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Shoulder‑friendly)**\n\n'
        '1. Lie on a flat bench holding dumbbells with palms facing each other (neutral grip).\n'
        '2. Press the weights upward from chest level, keeping elbows close to your body.\n'
        '3. Lower with control until the dumbbells touch the sides of your chest.\n'
        '4. Press back up, focusing on chest contraction without flaring your elbows.',
  ),
  ExercisePoolEntry(
    id: 'chest_bench_squeeze_press',
    name: 'Dumbbell Squeeze Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.adjustableBench,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Mind‑Muscle Connection)**\n\n'
        '1. Hold a single dumbbell vertically between your palms, squeezing it firmly.\n'
        '2. Lie on a bench and press the dumbbell upward, maintaining constant inward pressure.\n'
        '3. Lower the dumbbell to your chest, keeping the squeeze throughout.\n'
        '4. Press back up, focusing on the isometric contraction of your chest.',
  ),
];
