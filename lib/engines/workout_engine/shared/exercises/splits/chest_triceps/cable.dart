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

const List<ExercisePoolEntry> chestTricepsCableExercises = [
  ExercisePoolEntry(
    id: 'chest_triceps_cable_flyes',
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
    description: '**Target: Chest**\n\n'
        '1. Set the pulleys at chest height, grab a handle in each hand, and step forward.\n'
        '2. Keep a slight bend in your elbows and bring the handles together in front of your chest.\n'
        '3. Squeeze your chest, then slowly return to the starting position, feeling the stretch.\n'
        '4. Control the movement and avoid using momentum.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_cable_tricep_pushdowns',
    name: 'Tricep Pushdowns',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Attach a rope or straight bar to a high pulley.\n'
        '2. Grip the handle, stand close to the machine, and keep your elbows pinned to your sides.\n'
        '3. Push the handle down until your arms are fully extended, squeezing your triceps at the bottom.\n'
        '4. Return slowly to the starting position, resisting the weight.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_cable_crossover',
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
    description: '**Target: Chest**\n\n'
        '1. Set both pulleys at chest height and attach D‑handles.\n'
        '2. Stand in the middle, grab the handles with palms facing down, and step forward into a split stance.\n'
        '3. Keeping a slight bend in your elbows, bring your hands together in front of your chest.\n'
        '4. Squeeze your chest at the peak contraction, then slowly return to the stretch position.\n'
        '5. Control the negative phase for maximum muscle fibre recruitment.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_cable_overhead_tricep_extension',
    name: 'Cable Overhead Tricep Extension',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Attach a rope to a low pulley and face away from the machine.\n'
        '2. Hold the rope overhead with your arms bent, hands behind your head.\n'
        '3. Extend your arms upward, straightening them fully, squeezing your triceps.\n'
        '4. Lower the rope back behind your head with control, keeping your upper arms stationary.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_cable_chest_press',
    name: 'Cable Chest Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Triceps**\n\n'
        '1. Set the pulleys at chest height, grab a handle in each hand, and stand in the centre.\n'
        '2. Press the handles forward until your arms are fully extended, squeezing your chest.\n'
        '3. Return slowly to the starting position, controlling the weight throughout.\n'
        '4. Keep your core engaged and maintain a slight forward lean.',
  ),
];
