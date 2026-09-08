import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

const List<ExercisePoolEntry> backHomemadeExercises = [
  ExercisePoolEntry(
    id: 'back_homemade_bent_over_row',
    name: 'Homemade Weight Bent Over Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.shoulders],
    usesWeight: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back**\n\n'
        '1. Hold two homemade weights (e.g., bags of rice, water jugs, sandbags) at your sides.\n'
        '2. Bend at the hips with a flat back, torso nearly parallel to the floor.\n'
        '3. Pull the weights towards your lower chest, squeezing your shoulder blades together.\n'
        '4. Lower with control, keeping your back flat throughout the movement.\n'
        '5. Ensure the weights are secure to avoid injury.',
  ),
  ExercisePoolEntry(
    id: 'back_homemade_one_arm_row',
    name: 'Homemade Weight One Arm Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.shoulders],
    usesWeight: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back (Unilateral)**\n\n'
        '1. Place one hand on a stable surface (chair, bench, or wall) for support, with feet shoulder‑width apart.\n'
        '2. Hold a homemade weight in your free hand and let it hang straight down.\n'
        '3. Pull the weight up towards your hip, squeezing your lat and keeping your back flat.\n'
        '4. Lower with control, then switch sides after completing the set.\n'
        '5. Keep your core engaged to prevent twisting.',
  ),
  ExercisePoolEntry(
    id: 'back_homemade_deadlift',
    name: 'Homemade Weight Deadlift',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    usesWeight: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Full Posterior Chain**\n\n'
        '1. Stand with feet hip‑width apart, holding a heavy homemade weight (or two) in front of your thighs.\n'
        '2. Hinge at your hips, keeping your back flat, and lower the weight towards the floor while bending your knees slightly.\n'
        '3. Drive through your heels to stand up, squeezing your glutes and lats at the top.\n'
        '4. Lower with control to the starting position.\n'
        '5. Keep the weight close to your body throughout the lift.',
  ),
  ExercisePoolEntry(
    id: 'back_homemade_pullover',
    name: 'Homemade Weight Pullover (Back version)',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats**\n\n'
        '1. Lie across a bench (or on the floor) with only your upper back supported, holding a homemade weight with both hands above your chest.\n'
        '2. Keeping your arms slightly bent, lower the weight behind your head in an arc until you feel a stretch in your lats.\n'
        '3. Pull the weight back up using your lats, squeezing at the top.\n'
        '4. Keep your hips stable and core tight.\n'
        '5. Perform the movement slowly for maximum lat engagement.',
  ),
  ExercisePoolEntry(
    id: 'back_homemade_shrugs',
    name: 'Homemade Weight Shrugs',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.back],
    usesWeight: true,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Traps**\n\n'
        '1. Stand upright with feet shoulder‑width apart, holding a homemade weight in each hand at your sides.\n'
        '2. Shrug your shoulders straight up towards your ears as high as possible, squeezing your traps.\n'
        '3. Hold for a second, then slowly lower back down.\n'
        '4. Keep your arms straight and your neck relaxed.\n'
        '5. Avoid rotating your shoulders; focus on the vertical movement.',
  ),
];
