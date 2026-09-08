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

const List<ExercisePoolEntry> lowerBodyHackSquatExercises = [
  ExercisePoolEntry(
    id: 'lower_hack_standard',
    name: 'Hack Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.hackSquatMachine,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Position yourself in the hack squat machine with your shoulders under the pads and feet shoulder‑width apart on the platform.\n'
        '2. Unrack the weight and lower your body by bending your knees, keeping your back against the pad.\n'
        '3. Descend until your thighs are at least parallel to the floor (or below).\n'
        '4. Drive through your heels to push the weight back up, without locking your knees.\n'
        '5. Keep your core braced and maintain a controlled tempo.',
  ),
  ExercisePoolEntry(
    id: 'lower_hack_narrow_stance',
    name: 'Hack Squat - Narrow Stance',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.hackSquatMachine,
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
        '2. Perform the hack squat as described, focusing on knee extension.\n'
        '3. This stance targets the outer quads more.\n'
        '4. Keep your knees tracking over your toes.\n'
        '5. Use a moderate weight to maintain control.',
  ),
  ExercisePoolEntry(
    id: 'lower_hack_wide_stance',
    name: 'Hack Squat - Wide Stance',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.hackSquatMachine,
    targetMuscles: [MuscleGroup.glutes, MuscleGroup.adductors],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes, Adductors**\n\n'
        '1. Place your feet wider than shoulder‑width apart on the platform.\n'
        '2. Perform the hack squat, focusing on pushing through your heels and using your hips.\n'
        '3. This stance emphasises the glutes and inner thighs.\n'
        '4. Keep your back flat against the pad throughout.\n'
        '5. Control the descent and drive up powerfully.',
  ),
  ExercisePoolEntry(
    id: 'lower_hack_single_leg',
    name: 'Single-Leg Hack Squat',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.hackSquatMachine,
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
        '1. Place one foot on the platform, the other resting on the machine frame.\n'
        '2. Unrack the weight and perform a squat using only the working leg.\n'
        '3. Lower until your thigh is parallel or below, then press back up.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. Use a lighter weight to maintain balance and control.',
  ),
  ExercisePoolEntry(
    id: 'lower_hack_reverse',
    name: 'Reverse Hack Squat',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.hackSquatMachine,
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
        '1. Face the hack squat machine, placing your shoulders against the pads and feet on the platform.\n'
        '2. Your hips will be more flexed, shifting emphasis to the posterior chain.\n'
        '3. Lower into a squat, pushing your hips back, then drive up through your heels.\n'
        '4. Keep your back straight and core tight.\n'
        '5. This variation is excellent for glute and hamstring development.',
  ),
];
