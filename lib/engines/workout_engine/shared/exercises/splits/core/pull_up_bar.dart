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

const List<ExercisePoolEntry> corePullUpBarExercises = [
  ExercisePoolEntry(
    id: 'core_pullup_hanging_leg_raises',
    name: 'Hanging Leg Raises',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Hang from a pull‑up bar with your arms fully extended and shoulders relaxed.\n'
        '2. Keep your legs straight and raise them up to a 90° angle or higher.\n'
        '3. Pause briefly at the top, squeezing your lower abs.\n'
        '4. Lower your legs with control back to the starting position.\n'
        '5. Avoid swinging; use a controlled tempo to maximise core engagement.',
  ),
  ExercisePoolEntry(
    id: 'core_pullup_hanging_knee_raises',
    name: 'Hanging Knee Raises',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Hang from a pull‑up bar with your arms fully extended.\n'
        '2. Bend your knees and raise them toward your chest as high as possible.\n'
        '3. Squeeze your lower abs at the top, then lower your legs with control.\n'
        '4. This is a less demanding alternative to straight leg raises.\n'
        '5. Focus on the contraction and avoid using momentum.',
  ),
  ExercisePoolEntry(
    id: 'core_pullup_windshield_wipers',
    name: 'Windshield Wipers',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.absCore, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques, Core**\n\n'
        '1. Hang from a pull‑up bar with your legs extended straight.\n'
        '2. Rotate your legs to the right, then to the left, like windshield wipers.\n'
        '3. Keep your upper body stable and your core engaged throughout.\n'
        '4. Perform the movement slowly and with control.\n'
        '5. This is an advanced exercise; start with a smaller range of motion.',
  ),
  ExercisePoolEntry(
    id: 'core_pullup_l_sit',
    name: 'L-Sit Hang',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.absCore, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Hang from a pull‑up bar with your arms fully extended.\n'
        '2. Raise your legs to a 90° angle, keeping them straight, forming an L shape.\n'
        '3. Hold this position for the prescribed time, keeping your core tight.\n'
        '4. Avoid swinging; focus on maintaining the L position.\n'
        '5. This exercise builds core strength and shoulder endurance.',
  ),
  ExercisePoolEntry(
    id: 'core_pullup_toes_to_bar',
    name: 'Toes-to-Bar',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.pullUpBarAccessible,
    targetMuscles: [MuscleGroup.absCore, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Hang from a pull‑up bar with your arms fully extended.\n'
        '2. Use your core to bring your toes up to touch the bar.\n'
        '3. Squeeze your abs at the top, then lower your legs with control.\n'
        '4. Keep your arms straight and avoid using momentum.\n'
        '5. This is an advanced movement; start with knee raises and progress gradually.',
  ),
];
