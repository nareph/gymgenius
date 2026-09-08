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

const List<ExercisePoolEntry> legsResistanceBandsExercises = [
  ExercisePoolEntry(
    id: 'legs_band_squats',
    name: 'Resistance Band Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Stand on a resistance band with feet shoulder‑width apart, holding the handles at shoulder height.\n'
        '2. Perform a squat, keeping your chest up and core tight, while maintaining tension on the band.\n'
        '3. Descend until your thighs are parallel to the floor.\n'
        '4. Drive through your heels to stand back up, keeping the band under tension.\n'
        '5. This adds resistance without heavy weights.',
  ),
  ExercisePoolEntry(
    id: 'legs_band_glute_bridges',
    name: 'Band Glute Bridges',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.hamstrings],
    usesWeight: false,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes**\n\n'
        '1. Place a resistance band just above your knees, and lie on your back with knees bent, feet flat.\n'
        '2. Drive through your heels to lift your hips, squeezing your glutes at the top.\n'
        '3. Push your knees apart against the band to increase glute activation.\n'
        '4. Lower your hips back down with control.\n'
        '5. This variation adds extra resistance to the standard glute bridge.',
  ),
  ExercisePoolEntry(
    id: 'legs_band_clamshells',
    name: 'Band Clamshells',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Glutes (Medius)**\n\n'
        '1. Lie on your side with knees bent at 90°, a band just above your knees.\n'
        '2. Keeping your feet together, open your knees like a clamshell, squeezing your glutes.\n'
        '3. Hold for a second at the top, then lower with control.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. This targets the glute medius and is great for warm‑up.',
  ),
  ExercisePoolEntry(
    id: 'legs_band_lateral_walks',
    name: 'Band Lateral Walks',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.glutes, MuscleGroup.adductors],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Glutes, Adductors**\n\n'
        '1. Place a band just above your knees, stand with feet shoulder‑width apart.\n'
        '2. Take small steps sideways, keeping tension on the band and maintaining a slight squat position.\n'
        '3. Move 10–15 steps in one direction, then return.\n'
        '4. Keep your chest up and core tight.\n'
        '5. This is an excellent warm‑up or activation exercise.',
  ),
  ExercisePoolEntry(
    id: 'legs_band_leg_curls',
    name: 'Band Leg Curls',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.hamstrings],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings**\n\n'
        '1. Anchor a resistance band at floor level behind you.\n'
        '2. Lie face down, loop the band around your ankles.\n'
        '3. Curl your heels towards your glutes, squeezing your hamstrings.\n'
        '4. Return slowly, resisting the band.\n'
        '5. This is a great home alternative to the leg curl machine.',
  ),
  ExercisePoolEntry(
    id: 'legs_band_calf_raises',
    name: 'Resistance Band Calf Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [
      MuscleGroup.calves,
    ],
    secondaryMuscles: [],
    usesWeight: false,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Calves**\n\n'
        '1. Stand on the middle of a resistance band, holding the ends at shoulder height for balance.\n'
        '2. Raise your heels as high as possible against the band tension.\n'
        '3. Squeeze your calves at the top, then lower slowly.\n'
        '4. Perform on a step for a greater range of motion.\n'
        '5. This adds extra resistance to bodyweight calf raises.',
  ),
  ExercisePoolEntry(
    id: 'legs_band_single_leg_calf_raises',
    name: 'Single-Leg Band Calf Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [
      MuscleGroup.calves,
    ],
    secondaryMuscles: [],
    usesWeight: false,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Calves (Unilateral)**\n\n'
        '1. Stand on the band with one foot, hold the band in the same‑side hand for balance.\n'
        '2. Raise your heel as high as possible against the band tension.\n'
        '3. Squeeze at the top, lower with control.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. This helps correct calf imbalances.',
  ),
];
