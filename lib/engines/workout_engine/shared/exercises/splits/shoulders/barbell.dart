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

const List<ExercisePoolEntry> shouldersBarbellExercises = [
  ExercisePoolEntry(
    id: 'shoulders_core_bb_military_press',
    name: 'Military Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.chest],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a barbell at shoulder height with an overhand grip, hands just outside your shoulders.\n'
        '2. Keep your core tight, chest up, and press the bar straight overhead until your arms are fully extended.\n'
        '3. Pause briefly at the top, squeezing your shoulders.\n'
        '4. Lower the bar back to shoulder height with control.\n'
        '5. Avoid arching your back; keep the bar path vertical.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_bb_push_press',
    name: 'Push Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps, Quads**\n\n'
        '1. Hold a barbell at shoulder height with an overhand grip, feet shoulder‑width apart.\n'
        '2. Dip slightly by bending your knees (about 10–15°), keeping your torso upright.\n'
        '3. Explosively drive through your legs to generate momentum, pressing the bar overhead as you extend your hips and knees.\n'
        '4. Lock out your arms overhead, then lower the bar back to shoulder height with control.\n'
        '5. This variation uses leg drive to press heavier loads.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_bb_upright_row',
    name: 'Barbell Upright Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.biceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Traps**\n\n'
        '1. Stand upright with feet shoulder‑width apart, holding a barbell with an overhand grip, hands shoulder‑width apart.\n'
        '2. Let the bar hang at arm\'s length in front of your thighs.\n'
        '3. Pull the bar straight up towards your chin, leading with your elbows, keeping the bar close to your body.\n'
        '4. Pause at the top, then lower the bar with control back to the starting position.\n'
        '5. Avoid using momentum; use a controlled tempo.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_bb_zottman_curl',
    name: 'Barbell Zottman Curl (for shoulder stability)',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.biceps, MuscleGroup.forearms],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Biceps, Forearms, Shoulder Stabilizers**\n\n'
        '1. Stand upright holding a barbell with an underhand grip (palms up) at your thighs.\n'
        '2. Curl the bar up to shoulder height, squeezing your biceps.\n'
        '3. At the top, rotate your wrists so your palms face down (overhand grip).\n'
        '4. Lower the bar back to the starting position with palms down, controlling the descent.\n'
        '5. This builds forearm strength and shoulder stability.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_core_bb_overhead_carry',
    name: 'Overhead Barbell Carry',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    isTimed: true,
    movementPattern: MovementPattern.carry,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Core**\n\n'
        '1. Press a barbell overhead and lock it out with arms extended.\n'
        '2. Brace your core, keep your shoulders packed down, and walk forward for the prescribed distance or time.\n'
        '3. Maintain stability; keep the bar directly over your shoulders.\n'
        '4. Avoid letting the bar drift forward or backward.\n'
        '5. This exercise builds shoulder stability and core strength.',
  ),
];
