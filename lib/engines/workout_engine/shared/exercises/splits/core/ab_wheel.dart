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

const List<ExercisePoolEntry> coreAbWheelExercises = [
  ExercisePoolEntry(
    id: 'core_abwheel_rollouts',
    name: 'Ab Wheel Rollouts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.abWheel,
    targetMuscles: [MuscleGroup.absCore, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Kneel on the floor with the ab wheel directly in front of you, gripping the handles.\n'
        '2. Brace your core, keep your back flat, and slowly roll the wheel forward as far as you can without letting your hips drop.\n'
        '3. Pause briefly at the furthest point, feeling the stretch in your core.\n'
        '4. Engage your abs to pull the wheel back to the starting position, keeping your back straight throughout.\n'
        '5. Avoid arching your lower back; maintain a neutral spine.',
  ),
  ExercisePoolEntry(
    id: 'core_abwheel_knee_rollouts',
    name: 'Ab Wheel Knee Rollouts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.abWheel,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core**\n\n'
        '1. Kneel on the floor with the ab wheel in front of you, gripping the handles.\n'
        '2. Roll forward only until your shoulders are extended and your torso is nearly parallel to the floor, keeping your back flat.\n'
        '3. Pause briefly, then pull back to the starting position using your core.\n'
        '4. This is a less intense version of the full rollout, ideal for beginners.\n'
        '5. Focus on maintaining a straight line from your knees to your shoulders.',
  ),
  ExercisePoolEntry(
    id: 'core_abwheel_standing_rollouts',
    name: 'Ab Wheel Standing Rollouts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.abWheel,
    targetMuscles: [MuscleGroup.absCore, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Stand with feet hip‑width apart, gripping the ab wheel handles.\n'
        '2. Roll the wheel forward, bending at the hips, until your torso is nearly horizontal and your arms are extended overhead.\n'
        '3. Pause at the bottom, feeling the deep stretch in your core.\n'
        '4. Use your core and glutes to pull the wheel back to the starting position, maintaining a straight back.\n'
        '5. This is an advanced variation; start with short range of motion.',
  ),
  ExercisePoolEntry(
    id: 'core_abwheel_oblique_rollouts',
    name: 'Ab Wheel Oblique Rollouts',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.abWheel,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Obliques**\n\n'
        '1. Kneel on the floor with the ab wheel in front of you, gripping the handles.\n'
        '2. Roll the wheel forward and diagonally to the right, keeping your core engaged and back flat.\n'
        '3. Pause, then pull back to the centre and repeat on the left side.\n'
        '4. This variation targets the obliques and improves rotational stability.\n'
        '5. Alternate sides for a balanced workout.',
  ),
  ExercisePoolEntry(
    id: 'core_abwheel_negative_rollouts',
    name: 'Ab Wheel Negative Rollouts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.abWheel,
    targetMuscles: [MuscleGroup.absCore, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Kneel on the floor with the ab wheel in front of you, gripping the handles.\n'
        '2. Roll forward as far as you can, focusing on the eccentric (negative) portion of the movement.\n'
        '3. Pause at the bottom for 2–3 seconds, feeling the deep isometric contraction.\n'
        '4. Pull back to the starting position with control.\n'
        '5. This variation increases time under tension and builds core endurance.',
  ),
];
