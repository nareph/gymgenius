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

const List<ExercisePoolEntry> chestDipExercises = [
  ExercisePoolEntry(
    id: 'chest_dip_parallel_bars',
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
    description: '**Target: Chest (Lower Pecs)**\n\n'
        '1. Grip the parallel bars, lift yourself up, arms straight.\n'
        '2. Lean your torso forward (about 20–30°) to shift emphasis onto the chest.\n'
        '3. Lower your body until your shoulders are below your elbows or until you feel a stretch in your chest.\n'
        '4. Push back up powerfully, keeping your legs tucked behind you.\n'
        '5. Avoid flaring your elbows excessively to protect your shoulders.',
  ),
  ExercisePoolEntry(
    id: 'chest_dip_weighted',
    name: 'Weighted Chest Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest (Maximal Load)**\n\n'
        '1. Attach a dip belt with a weight plate, or hold a dumbbell between your legs.\n'
        '2. Perform dips with a forward lean, lowering until a deep stretch in the chest.\n'
        '3. Drive up with controlled power.\n'
        '4. Use a spotter or safety pins if going to failure.',
  ),
  ExercisePoolEntry(
    id: 'chest_dip_bench_assisted',
    name: 'Bench Assisted Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest (Learning Phase)**\n\n'
        '1. Place a bench behind you and place your feet on it.\n'
        '2. Grip the parallel bars and lower yourself, using your feet on the bench to reduce the load.\n'
        '3. Push up with assistance, focusing on the movement pattern.\n'
        '4. Gradually reduce the leg assist as you gain strength.',
  ),
  ExercisePoolEntry(
    id: 'chest_dip_ring',
    name: 'Ring Dips',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.dipStationOrParallelBars,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [
      MuscleGroup.triceps,
      MuscleGroup.shoulders,
      MuscleGroup.absCore
    ],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest (Stability)**\n\n'
        '1. Hang from gymnastic rings, support yourself with arms straight.\n'
        '2. Lean forward to engage the chest, then lower yourself slowly.\n'
        '3. At the bottom, your hands should be near your armpits.\n'
        '4. Press up, keeping the rings stable – this requires significant shoulder and core stability.',
  ),
  ExercisePoolEntry(
    id: 'chest_dip_band_assisted',
    name: 'Band Assisted Dips',
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
    description: '**Target: Chest (Assisted Strength)**\n\n'
        '1. Loop a resistance band around the bars and place a knee or foot in it for support.\n'
        '2. Perform dips with a forward lean, using the band to assist at the bottom.\n'
        '3. As you get stronger, use a thinner band or do full bodyweight dips.',
  ),
];
