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

const List<ExercisePoolEntry> upperBodyCableExercises = [
  ExercisePoolEntry(
    id: 'upper_cable_tricep_pushdowns',
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
    id: 'upper_cable_lat_pulldowns',
    name: 'Lat Pulldowns',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Sit at the lat pulldown machine, adjusting the thigh pad so it holds your legs firmly.\n'
        '2. Grip the bar with a wide overhand grip (palms facing forward).\n'
        '3. Pull the bar down towards your upper chest, keeping your back straight and squeezing your lats.\n'
        '4. Pause briefly at the bottom, then slowly release the bar back to the starting position with control.',
  ),
  ExercisePoolEntry(
    id: 'upper_cable_crossover',
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
    id: 'upper_cable_seated_row',
    name: 'Seated Cable Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Sit at the cable row station with your knees slightly bent and feet braced.\n'
        '2. Grip the handle (V‑bar or close‑grip) and extend your arms forward.\n'
        '3. Pull the handle towards your torso, squeezing your shoulder blades together.\n'
        '4. Pause, then slowly return to the starting position, keeping your back straight.',
  ),
  ExercisePoolEntry(
    id: 'upper_cable_face_pulls',
    name: 'Face Pulls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.cableMachinePulley,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.traps],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Traps**\n\n'
        '1. Attach a rope to a high pulley, set at about face height.\n'
        '2. Grasp the rope with both hands and step back to create tension.\n'
        '3. Pull the rope towards your face, keeping your elbows high and hands beside your ears.\n'
        '4. Squeeze your shoulder blades together at the peak, then slowly return.',
  ),
];
