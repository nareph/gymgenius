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

final List<ExercisePoolEntry> coreDumbbellExercises = [
  ExercisePoolEntry(
    id: 'core_db_dumbbell_crunches',
    name: 'Dumbbell Crunches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Abs**\n\n'
        '1. Lie on your back with your knees bent and feet flat, holding a dumbbell at your chest.\n'
        '2. Curl your upper body toward your knees, keeping the dumbbell stable.\n'
        '3. Squeeze your abs at the top, then lower back down with control.\n'
        '4. Keep your lower back pressed into the floor throughout.\n'
        '5. Use a light weight to maintain proper form.',
  ),
  ExercisePoolEntry(
    id: 'core_db_russian_twists_dumbbell',
    name: 'Russian Twists with Dumbbell',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Sit on the floor with your knees bent and feet lifted, holding a dumbbell with both hands.\n'
        '2. Lean your torso back slightly, keeping your back straight and core tight.\n'
        '3. Rotate your torso to the right, tapping the dumbbell beside your hip, then rotate to the left.\n'
        '4. Keep the movement controlled and avoid using momentum.\n'
        '5. For added difficulty, extend your legs further or use a heavier dumbbell.',
  ),
  ExercisePoolEntry(
    id: 'core_db_dumbbell_side_bends',
    name: 'Dumbbell Side Bends',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Obliques**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a dumbbell in one hand at your side.\n'
        '2. Bend your torso sideways toward the weighted side, then return to upright using your obliques.\n'
        '3. Perform the movement slowly and with control.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. Avoid leaning forward or backward; keep the movement strictly lateral.',
  ),
  ExercisePoolEntry(
    id: 'core_db_dumbbell_oblique_crunch',
    name: 'Dumbbell Oblique Crunch',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Lie on your side with your legs bent at a slight angle, holding a dumbbell near your chest.\n'
        '2. Crunch your torso upward, bringing your shoulder toward your hip.\n'
        '3. Squeeze your oblique at the top, then lower back down with control.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. Keep your movement slow and controlled.',
  ),
  ExercisePoolEntry(
    id: 'core_db_dumbbell_v_ups',
    name: 'Dumbbell V-Ups',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Full Core**\n\n'
        '1. Lie on your back holding a dumbbell overhead with both hands, legs extended.\n'
        '2. Simultaneously raise your arms, torso, and legs off the floor, reaching the dumbbell toward your feet.\n'
        '3. Your body should form a V shape at the top.\n'
        '4. Lower back down with control.\n'
        '5. Use a light weight to maintain control and form.',
  ),
];
