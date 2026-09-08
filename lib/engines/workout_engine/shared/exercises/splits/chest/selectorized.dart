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

const List<ExercisePoolEntry> chestSelectorizedExercises = [
  ExercisePoolEntry(
    id: 'chest_selector_chest_press',
    name: 'Selectorized Chest Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Machine)**\n\n'
        '1. Adjust the seat so the handles are at chest height.\n'
        '2. Grip the handles, keep your back flat against the pad.\n'
        '3. Press forward until your arms are extended, squeezing your chest.\n'
        '4. Return slowly, controlling the weight throughout.\n'
        '5. This machine provides a fixed path, great for beginners.',
  ),
  ExercisePoolEntry(
    id: 'chest_selector_pec_deck_fly',
    name: 'Pec Deck Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Isolation Machine)**\n\n'
        '1. Sit on the pec deck, position your forearms against the pads.\n'
        '2. Keep a slight bend in your elbows, chest out.\n'
        '3. Bring the pads together in front of your chest, squeezing hard.\n'
        '4. Return with control, feel the stretch.\n'
        '5. This isolates the pecs with constant tension.',
  ),
  ExercisePoolEntry(
    id: 'chest_selector_incline_press',
    name: 'Selectorized Incline Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Upper Chest (Machine)**\n\n'
        '1. Adjust the incline machine seat so handles are at upper chest level.\n'
        '2. Press upward and forward, squeezing your upper chest.\n'
        '3. Lower with control.\n'
        '4. Great for targeting the clavicular head.',
  ),
  ExercisePoolEntry(
    id: 'chest_selector_decline_press',
    name: 'Selectorized Decline Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Lower Chest (Machine)**\n\n'
        '1. Sit in the decline press machine, handles at lower chest height.\n'
        '2. Press downward and forward, focusing on the lower sternal region.\n'
        '3. Return slowly and with control.',
  ),
  ExercisePoolEntry(
    id: 'chest_selector_plate_loaded_press',
    name: 'Plate-Loaded Chest Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Chest (Plate‑Loaded Machine)**\n\n'
        '1. Load plates on the machine, sit and adjust the seat.\n'
        '2. Grip the handles and press forward, maintaining a natural arc.\n'
        '3. Lower with control.\n'
        '4. This machine often feels more natural than selectorized and allows heavy loading.',
  ),
];
