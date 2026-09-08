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

const List<ExercisePoolEntry> lowerBodyLegPressExercises = [
  ExercisePoolEntry(
    id: 'lower_lp_standard',
    name: 'Leg Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legPressMachine,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Sit on the leg press machine with your back flat against the pad and feet shoulder‑width apart on the platform.\n'
        '2. Unrack the weight and lower the platform by bending your knees, bringing them toward your chest.\n'
        '3. Lower until your knees are at 90° (or slightly below), keeping your feet flat.\n'
        '4. Press through your heels to push the platform back up, without locking your knees.\n'
        '5. Keep your hips and lower back pressed against the seat throughout.',
  ),
  ExercisePoolEntry(
    id: 'lower_lp_high_foot',
    name: 'Leg Press - High Foot Placement',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legPressMachine,
    targetMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes, Hamstrings**\n\n'
        '1. Place your feet high on the platform (near the top edge), shoulder‑width apart.\n'
        '2. Perform the leg press as usual, but you\'ll feel more hip involvement.\n'
        '3. Lower until your knees are at 90°, press through your heels.\n'
        '4. This variation emphasises glutes and hamstrings.\n'
        '5. Keep your back flat against the pad.',
  ),
  ExercisePoolEntry(
    id: 'lower_lp_low_foot',
    name: 'Leg Press - Low Foot Placement',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legPressMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [MuscleGroup.glutes],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps**\n\n'
        '1. Place your feet low on the platform (near the bottom edge), shoulder‑width apart.\n'
        '2. Perform the leg press, focusing on knee extension.\n'
        '3. This variation targets the quads more directly.\n'
        '4. Lower until your knees are at 90°, press up.\n'
        '5. Keep your heels flat on the platform.',
  ),
  ExercisePoolEntry(
    id: 'lower_lp_single_leg',
    name: 'Single-Leg Leg Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.legPressMachine,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes (Unilateral)**\n\n'
        '1. Place one foot in the centre of the platform, the other foot resting on the floor or the machine frame.\n'
        '2. Perform the leg press using only the working leg.\n'
        '3. Lower until your knee is at 90°, press up.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. Use a lighter weight to maintain balance and control.',
  ),
  ExercisePoolEntry(
    id: 'lower_lp_narrow_stance',
    name: 'Leg Press - Narrow Stance',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.legPressMachine,
    targetMuscles: [MuscleGroup.quadriceps],
    secondaryMuscles: [MuscleGroup.glutes],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps (outer)**\n\n'
        '1. Place your feet close together (6–8 inches apart) on the platform.\n'
        '2. Perform the leg press, focusing on knee extension.\n'
        '3. This stance emphasises the outer quads.\n'
        '4. Lower until your knees are at 90°, press up.\n'
        '5. Keep your back flat against the pad.',
  ),
];
