import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

const List<ExercisePoolEntry> coreHomemadeExercises = [
  ExercisePoolEntry(
    id: 'core_homemade_russian_twist',
    name: 'Homemade Weight Russian Twist',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Sit on the floor with your knees bent and feet lifted, holding a homemade weight (e.g., bag of rice, water jug) with both hands.\n'
        '2. Lean your torso back slightly, keeping your back straight and core tight.\n'
        '3. Rotate your torso to the right, tapping the weight beside your hip, then rotate to the left.\n'
        '4. Keep the movement controlled and avoid using momentum.\n'
        '5. Ensure the weight is secure to avoid injury.',
  ),
  ExercisePoolEntry(
    id: 'core_homemade_sit_up',
    name: 'Homemade Weight Sit-up',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Abs**\n\n'
        '1. Lie on your back with your knees bent, holding a homemade weight on your chest.\n'
        '2. Curl your upper body toward your knees, keeping the weight stable.\n'
        '3. Squeeze your abs at the top, then lower back down with control.\n'
        '4. Keep your feet flat on the floor and your core engaged.\n'
        '5. Avoid pulling with your neck; let your abs do the work.',
  ),
  ExercisePoolEntry(
    id: 'core_homemade_side_bend',
    name: 'Homemade Weight Side Bend',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Obliques**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a homemade weight in one hand at your side.\n'
        '2. Bend your torso sideways toward the weighted side, then return to upright using your obliques.\n'
        '3. Perform the movement slowly and with control.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. Avoid leaning forward or backward; keep the movement strictly lateral.',
  ),
  ExercisePoolEntry(
    id: 'core_homemade_plank_pull',
    name: 'Homemade Weight Plank Pull',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Start in a high plank position with a homemade weight placed on the floor in front of you.\n'
        '2. Reach one hand forward, grab the weight, and pull it toward you, keeping your hips stable.\n'
        '3. Place the weight back down and repeat with the other arm.\n'
        '4. Keep your core tight and avoid letting your hips sway.\n'
        '5. This exercise challenges both core stability and coordination.',
  ),
  ExercisePoolEntry(
    id: 'core_homemade_v_up',
    name: 'Homemade Weight V-Up',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.homemadeWeights,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Full Core**\n\n'
        '1. Lie on your back holding a homemade weight overhead with both hands, legs extended.\n'
        '2. Simultaneously raise your arms, torso, and legs off the floor, reaching the weight toward your feet.\n'
        '3. Your body should form a V shape at the top.\n'
        '4. Lower back down with control.\n'
        '5. Use a light weight to maintain control and form.',
  ),
];
