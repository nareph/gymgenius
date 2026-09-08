import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

const List<ExercisePoolEntry> lowerBodyHomemadeExercises = [
  ExercisePoolEntry(
    id: 'lower_homemade_goblet_squat',
    name: 'Homemade Weight Goblet Squat',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.hamstrings],
    usesWeight: true,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Quadriceps, Glutes**\n\n'
        '1. Hold a homemade weight (e.g., a heavy bag, water jug) close to your chest, using both hands to support it.\n'
        '2. Stand with feet shoulder‑width apart, keep your elbows pointing down.\n'
        '3. Squat down as if sitting in a chair, keeping your chest up and the weight stable.\n'
        '4. Go as deep as you can comfortably, then push through your heels to stand back up.\n'
        '5. Maintain a slow and controlled tempo.',
  ),
  ExercisePoolEntry(
    id: 'lower_homemade_lunge',
    name: 'Homemade Weight Lunge',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.hamstrings],
    usesWeight: true,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Quadriceps, Glutes**\n\n'
        '1. Hold a homemade weight in each hand (or a single weight in goblet position).\n'
        '2. Step forward into a lunge, lowering your back knee toward the floor.\n'
        '3. Keep your torso upright and the weight stable.\n'
        '4. Push through the front heel to return to the starting position.\n'
        '5. Alternate legs with each rep.',
  ),
  ExercisePoolEntry(
    id: 'lower_homemade_rdl',
    name: 'Homemade Weight Romanian Deadlift',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.back],
    usesWeight: true,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Hamstrings, Glutes**\n\n'
        '1. Stand with feet hip‑width apart, holding homemade weights in front of your thighs.\n'
        '2. Hinge at your hips, lowering the weights along your shins while keeping a slight bend in your knees.\n'
        '3. Lower until you feel a stretch in your hamstrings, then drive your hips forward to stand up.\n'
        '4. Keep your back flat and core engaged.\n'
        '5. Control the descent and the ascent.',
  ),
  ExercisePoolEntry(
    id: 'lower_homemade_hip_thrust',
    name: 'Homemade Weight Hip Thrust',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.hamstrings],
    usesWeight: true,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Glutes**\n\n'
        '1. Sit on the floor with your upper back resting against a bench or chair, knees bent, feet flat.\n'
        '2. Place a homemade weight (e.g., a sandbag) across your hips.\n'
        '3. Drive through your heels to lift your hips up, squeezing your glutes at the top.\n'
        '4. Hold for a second, then lower with control.\n'
        '5. Keep your chin tucked and core tight.',
  ),
  ExercisePoolEntry(
    id: 'lower_homemade_step_up',
    name: 'Homemade Weight Step-Up',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Quadriceps, Glutes**\n\n'
        '1. Hold a homemade weight in each hand, stand in front of a sturdy step or box.\n'
        '2. Step up onto the box with one foot, driving through the heel to bring the other foot up.\n'
        '3. Step back down with the same foot, then repeat with the other leg.\n'
        '4. Keep your chest up and core tight.\n'
        '5. Perform the movement in a controlled manner.',
  ),
];