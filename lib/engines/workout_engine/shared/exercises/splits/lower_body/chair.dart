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

const List<ExercisePoolEntry> lowerBodyChairExercises = [
  ExercisePoolEntry(
    id: 'lower_chair_bulgarian_split_squats',
    name: 'Bulgarian Split Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Stand about two feet in front of a sturdy chair or bench, with your back to it.\n'
        '2. Place the top of your right foot on the bench, laces down.\n'
        '3. Lower your hips by bending your left knee until your right knee nearly touches the floor.\n'
        '4. Push through your left heel to return to the starting position.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'lower_chair_hip_thrusts',
    name: 'Hip Thrusts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes, Hamstrings**\n\n'
        '1. Sit on the floor with your upper back leaning against the edge of a chair or bench, knees bent, feet flat.\n'
        '2. Place your arms on the chair for support, keep your chin tucked.\n'
        '3. Drive through your heels to lift your hips up until your body forms a straight line from shoulders to knees.\n'
        '4. Squeeze your glutes at the top, hold for a second.\n'
        '5. Lower your hips back down with control.',
  ),
  ExercisePoolEntry(
    id: 'lower_chair_step_ups',
    name: 'Step-ups (chair)',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Stand in front of a sturdy chair or step (height about 12–18 inches).\n'
        '2. Place your right foot on the chair, drive through your heel to step up and bring your left foot to meet it.\n'
        '3. Step back down with your right foot first, then the left.\n'
        '4. Alternate the lead leg with each set.\n'
        '5. Keep your chest up and core engaged throughout.',
  ),
  ExercisePoolEntry(
    id: 'lower_chair_single_leg_hip_thrust',
    name: 'Single-Leg Hip Thrust',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.hamstrings],
    usesWeight: false,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes (Unilateral)**\n\n'
        '1. Lie on your back with your upper back against a chair, one foot flat on the floor, the other leg extended straight up.\n'
        '2. Drive through the heel of the grounded foot to lift your hips off the floor.\n'
        '3. Squeeze your glute at the top, then lower with control.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. Keep your core braced to maintain stability.',
  ),
  ExercisePoolEntry(
    id: 'lower_chair_deep_squat_holds',
    name: 'Deep Squat Holds',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.chairOrSimpleBench,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Stand in front of a chair with feet shoulder‑width apart.\n'
        '2. Squat down slowly until your glutes just barely touch the seat, then hold that position for 2–3 seconds.\n'
        '3. Drive through your heels to stand back up.\n'
        '4. This helps build control and depth in the squat.\n'
        '5. Focus on keeping your chest up and knees tracking over your toes.',
  ),
];
