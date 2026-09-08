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

const List<ExercisePoolEntry> chestTricepsSelectorizedExercises = [
  ExercisePoolEntry(
    id: 'chest_triceps_selector_machine_chest_press',
    name: 'Machine Chest Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Chest, Shoulders, Triceps**\n\n'
        '1. Sit on the chest press machine and adjust the seat so the handles are at chest height.\n'
        '2. Grip the handles and press forward until your arms are fully extended.\n'
        '3. Squeeze your chest at the end of the movement, then return slowly to the starting position.\n'
        '4. Keep your back flat against the pad throughout the set.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_selector_pec_deck_fly',
    name: 'Pec Deck Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest**\n\n'
        '1. Sit on the pec deck machine with your forearms against the pads and your elbows at chest height.\n'
        '2. Squeeze your chest to bring the pads together in front of you.\n'
        '3. Hold the contraction for a second, then return slowly, feeling the stretch.\n'
        '4. Keep your back flat and your head against the pad.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_selector_incline_chest_press',
    name: 'Selectorized Incline Chest Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Chest, Shoulders**\n\n'
        '1. Sit at the incline chest press machine and adjust the seat so the handles are at upper chest level.\n'
        '2. Press the handles forward and upward, focusing on the upper pectoral contraction.\n'
        '3. Return slowly with control.\n'
        '4. Keep your back flat against the pad.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_selector_dip_machine',
    name: 'Assisted Dip Machine',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
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
        '1. Kneel on the assisted dip machine platform and grip the handles.\n'
        '2. Lower your body by bending your elbows, allowing the machine to assist you.\n'
        '3. Press back up to the starting position.\n'
        '4. Adjust the assistance weight as needed to progress.',
  ),
  ExercisePoolEntry(
    id: 'chest_triceps_selector_tricep_extension_machine',
    name: 'Tricep Extension Machine',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
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
        '1. Sit at the tricep extension machine, adjust the seat so the handles are at shoulder height.\n'
        '2. Grip the handles and press downward until your arms are fully extended.\n'
        '3. Squeeze your triceps at the bottom, then return slowly.\n'
        '4. Keep your back flat against the pad.',
  ),
];
