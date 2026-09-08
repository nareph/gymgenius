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

const List<ExercisePoolEntry> shouldersBodyweightExercises = [
  ExercisePoolEntry(
    id: 'shoulders_bw_pike_push_ups',
    name: 'Pike Push-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Start in a downward‑dog position with your hips high, hands shoulder‑width apart, feet on the floor.\n'
        '2. Bend your elbows to lower the top of your head toward the floor, keeping your body in an inverted V shape.\n'
        '3. Push back up to the starting position, focusing on the shoulder muscles.\n'
        '4. Keep your core braced and your weight shifted forward onto your hands.\n'
        '5. To increase difficulty, place your feet on an elevated surface.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_bw_handstand_push_ups',
    name: 'Handstand Push-ups (against wall)',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Place your hands on the floor about 6–12 inches from a wall, shoulder‑width apart.\n'
        '2. Kick up into a handstand position, resting your feet against the wall for support.\n'
        '3. Keeping your body straight, bend your elbows to lower your head toward the floor.\n'
        '4. Press back up to full extension, squeezing your shoulders at the top.\n'
        '5. Keep your core tight and avoid arching your back.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_bw_pseudo_planche_push_ups',
    name: 'Pseudo Planche Push-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Chest**\n\n'
        '1. Start in a push‑up position, but place your hands lower than usual (toward your hips) and lean your shoulders forward.\n'
        '2. Keep your body straight and perform a push‑up, lowering your chest toward the floor.\n'
        '3. Push back up, maintaining the forward lean throughout.\n'
        '4. This variation places greater demand on the anterior deltoids.\n'
        '5. Use a controlled tempo to maximise muscle engagement.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_bw_wall_walks',
    name: 'Wall Walks',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Chest**\n\n'
        '1. Start in a push‑up position facing a wall, with your feet on the floor and hands on the floor.\n'
        '2. Walk your feet up the wall while simultaneously walking your hands back toward the wall.\n'
        '3. Continue until your body is nearly vertical (or as high as you can comfortably go).\n'
        '4. Reverse the movement, walking your feet back down and hands forward.\n'
        '5. This builds shoulder strength and control.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_bw_pike_push_ups_feet_elevated',
    name: 'Elevated Pike Push-ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Place your feet on a bench or chair, hands on the floor, and assume a pike position (hips high).\n'
        '2. Lower the top of your head toward the floor, increasing the range of motion.\n'
        '3. Push back up to the starting position, focusing on the shoulders.\n'
        '4. This variation adds more load to the anterior deltoids.\n'
        '5. Keep your core tight and your body stable.',
  ),
];
