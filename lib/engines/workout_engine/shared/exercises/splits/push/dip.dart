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

const List<ExercisePoolEntry> pushDipExercises = [
  ExercisePoolEntry(
    id: 'push_dip_dips',
    name: 'Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.triceps,
      MuscleGroup.shoulders
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Triceps, Shoulders**\n\n'
        '1. Grip the parallel bars, lift yourself up with straight arms.\n'
        '2. Lean your torso slightly forward to emphasise the chest, or keep upright for triceps focus.\n'
        '3. Lower your body until your shoulders are below your elbows (or until a comfortable stretch).\n'
        '4. Push back up to the starting position, locking out at the top.\n'
        '5. Keep your legs bent behind you to maintain balance.',
  ),
  ExercisePoolEntry(
    id: 'push_dip_weighted_dips',
    name: 'Weighted Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.triceps,
      MuscleGroup.shoulders
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Triceps, Shoulders**\n\n'
        '1. Attach a dip belt with a weight plate, or hold a dumbbell between your legs.\n'
        '2. Perform dips with a forward lean (for chest) or upright (for triceps).\n'
        '3. Lower until you feel a deep stretch, then press up powerfully.\n'
        '4. Use a spotter or safety pins if going to failure.',
  ),
  ExercisePoolEntry(
    id: 'push_dip_chest_dips',
    name: 'Chest Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest**\n\n'
        '1. Lean your torso forward (about 20–30°) while gripping the parallel bars.\n'
        '2. Lower your body until you feel a stretch in your chest, keeping your elbows slightly flared.\n'
        '3. Push back up, squeezing your chest at the top.\n'
        '4. Keep your legs bent behind you and your core tight.',
  ),
  ExercisePoolEntry(
    id: 'push_dip_tricep_dips',
    name: 'Tricep Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Triceps**\n\n'
        '1. Keep your torso as upright as possible on the bars.\n'
        '2. Lower your body until your elbows form a 90° angle, keeping them close to your sides.\n'
        '3. Push back up to full extension, squeezing your triceps.\n'
        '4. Avoid leaning forward to keep the focus on the triceps.',
  ),
  ExercisePoolEntry(
    id: 'push_dip_band_assisted_dips',
    name: 'Band-Assisted Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Triceps**\n\n'
        '1. Loop a resistance band around the dip bars and place a knee or foot in the band for support.\n'
        '2. Perform dips with a forward lean or upright, using the band to assist at the bottom of the movement.\n'
        '3. As you gain strength, use a thinner band or perform without assistance.',
  ),
];
