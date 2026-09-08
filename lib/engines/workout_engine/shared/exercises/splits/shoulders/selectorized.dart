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

const List<ExercisePoolEntry> shouldersSelectorizedExercises = [
  ExercisePoolEntry(
    id: 'shoulders_selector_shoulder_press',
    name: 'Selectorized Shoulder Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Sit at the shoulder press machine, adjust the seat so the handles are at shoulder height.\n'
        '2. Grip the handles, keep your back against the pad, and press upward until your arms are fully extended.\n'
        '3. Pause briefly, then lower with control.\n'
        '4. Keep your head and back against the pad for support.\n'
        '5. Use a moderate weight to maintain proper form.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_selector_lateral_raise',
    name: 'Selectorized Lateral Raise',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Side Shoulders**\n\n'
        '1. Sit on the lateral raise machine, place your forearms against the pads, and grip the handles.\n'
        '2. Raise your arms out to the sides to shoulder height, keeping a slight bend in your elbows.\n'
        '3. Pause at the top, then lower with control.\n'
        '4. Keep your back flat against the pad.\n'
        '5. Use light weight to focus on the contraction of the medial delts.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_selector_rear_delt_fly',
    name: 'Selectorized Rear Delt Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.back],
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
        '5. Use light weight to focus on strict form.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_selector_front_raise',
    name: 'Selectorized Front Raise',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Front Shoulders**\n\n'
        '1. Sit at the front raise machine, grip the handles, and rest your forearms on the pads.\n'
        '2. Raise your arms forward to shoulder height, keeping them straight.\n'
        '3. Pause at the top, then lower with control.\n'
        '4. Keep your back against the pad and avoid using momentum.\n'
        '5. This machine provides constant tension throughout the range of motion.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_selector_shrugs',
    name: 'Selectorized Shrugs',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.gymMachinesSelectorized,
    targetMuscles: [MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Traps**\n\n'
        '1. Stand or sit at the shrug machine, grip the handles, and keep your arms straight.\n'
        '2. Shrug your shoulders straight up towards your ears as high as possible.\n'
        '3. Squeeze your traps at the top, hold for a second.\n'
        '4. Lower with control back to the starting position.\n'
        '5. Avoid rolling your shoulders; focus on a pure vertical movement.',
  ),
];
