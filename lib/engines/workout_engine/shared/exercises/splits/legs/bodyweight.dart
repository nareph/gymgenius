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

const List<ExercisePoolEntry> legsBodyweightExercises = [
  ExercisePoolEntry(
    id: 'legs_bw_squats',
    name: 'Bodyweight Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
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
    description:
        '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Stand with feet shoulder‑width apart, toes slightly pointed out, arms extended forward for balance.\n'
        '2. Push your hips back and bend your knees, lowering your body as if sitting in a chair.\n'
        '3. Go as low as you can while keeping your chest up and back straight (ideally thighs parallel or below).\n'
        '4. Drive through your heels to return to the starting position, squeezing your glutes at the top.\n'
        '5. Keep your knees tracking over your toes and avoid letting them cave inward.',
  ),
  ExercisePoolEntry(
    id: 'legs_bw_jump_squats',
    name: 'Jump Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.calves],
    usesWeight: false,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Quadriceps, Glutes, Hamstrings (Power)**\n\n'
        '1. Start in a squat position with feet shoulder‑width apart.\n'
        '2. Squat down until your thighs are parallel to the floor, then explode upward, jumping as high as possible.\n'
        '3. Land softly with bent knees to absorb the impact, immediately descending into the next squat.\n'
        '4. Keep your chest up and core tight throughout.\n'
        '5. Focus on explosive power and controlled landings to protect your joints.',
  ),
  ExercisePoolEntry(
    id: 'legs_bw_sumo_squats',
    name: 'Sumo Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.adductors],
    usesWeight: false,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description:
        '**Target: Inner Thighs, Glutes, Quadriceps**\n\n'
        '1. Stand with feet wider than shoulder‑width apart, toes pointed out at about 45°.\n'
        '2. Push your hips back and lower your body straight down, keeping your chest up and back straight.\n'
        '3. Descend until your thighs are at least parallel to the floor, feeling the stretch in your inner thighs.\n'
        '4. Drive through your heels to stand back up, squeezing your glutes at the top.\n'
        '5. Keep your knees tracking over your toes to avoid strain.',
  ),
  ExercisePoolEntry(
    id: 'legs_bw_pistol_squats_assisted',
    name: 'Pistol Squats (assisted)',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.calves],
    usesWeight: false,
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Quadriceps, Glutes (Unilateral)**\n\n'
        '1. Stand on one leg, extending the other leg forward and keeping it off the floor.\n'
        '2. Squat down on the standing leg, lowering your hips as far as you can while maintaining balance.\n'
        '3. Push through the heel of the standing leg to return to the starting position.\n'
        '4. To assist, hold onto a support (e.g., a chair or pole) or use a counterweight.\n'
        '5. Keep your chest up and back as straight as possible.',
  ),
  ExercisePoolEntry(
    id: 'legs_bw_lunges',
    name: 'Lunges',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Stand upright with feet hip‑width apart, hands on your hips.\n'
        '2. Step forward with your right leg, lowering your hips until both knees are bent at 90° (front knee over ankle, back knee hovering just above the floor).\n'
        '3. Push through your front heel to return to the starting position.\n'
        '4. Repeat with the left leg, alternating each rep.\n'
        '5. Keep your torso upright and core engaged throughout.',
  ),
  ExercisePoolEntry(
    id: 'legs_bw_walking_lunges',
    name: 'Walking Lunges',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
        '1. Stand with feet together, take a long step forward with your right leg.\n'
        '2. Lower your hips until both knees are bent at 90°, with your back knee nearly touching the floor.\n'
        '3. Push off your back foot and step forward into the next lunge, alternating legs as you move forward.\n'
        '4. Keep your torso upright and core braced.\n'
        '5. Continue for the desired number of reps per leg.',
  ),
  ExercisePoolEntry(
    id: 'legs_bw_side_lunges',
    name: 'Side Lunges',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.quadriceps,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.adductors],
    usesWeight: false,
    movementPattern: MovementPattern.lunge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.frontal,
    description:
        '**Target: Inner Thighs, Glutes**\n\n'
        '1. Stand with feet together, then take a wide step to the right with your right foot.\n'
        '2. Bend your right knee and push your hips back, lowering into a lunge while keeping your left leg straight.\n'
        '3. Push off your right foot to return to the starting position.\n'
        '4. Repeat on the left side, alternating.\n'
        '5. Keep your chest up and back straight throughout the movement.',
  ),
  ExercisePoolEntry(
    id: 'legs_bw_glute_bridges',
    name: 'Glute Bridges',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.hamstrings],
    usesWeight: false,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Glutes**\n\n'
        '1. Lie on your back with your knees bent, feet flat on the floor, hip‑width apart.\n'
        '2. Place your arms at your sides, palms down.\n'
        '3. Press through your heels to lift your hips off the floor until your body forms a straight line from shoulders to knees.\n'
        '4. Squeeze your glutes at the top and hold for a second.\n'
        '5. Lower your hips back down with control.',
  ),
  ExercisePoolEntry(
    id: 'legs_bw_single_leg_glute_bridges',
    name: 'Single-Leg Glute Bridges',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.hamstrings],
    usesWeight: false,
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Glutes (Unilateral)**\n\n'
        '1. Lie on your back with one foot flat on the floor, the other leg extended straight up.\n'
        '2. Drive through the heel of the grounded foot to lift your hips off the floor.\n'
        '3. Squeeze your glute at the top, then lower with control.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. Keep your core braced to maintain stability.',
  ),
  ExercisePoolEntry(
    id: 'legs_bw_calf_raises',
    name: 'Bodyweight Calf Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.calves,
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Calves**\n\n'
        '1. Stand upright with feet hip‑width apart, holding onto a wall or chair for balance if needed.\n'
        '2. Raise your heels as high as possible by pushing through the balls of your feet.\n'
        '3. Squeeze your calves at the top, hold for a second.\n'
        '4. Lower your heels back to the floor with control.\n'
        '5. Perform the movement slowly to maximise muscle tension.',
  ),
  ExercisePoolEntry(
    id: 'legs_bw_single_leg_calf_raises',
    name: 'Single-Leg Calf Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [
      MuscleGroup.calves,
    ],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description:
        '**Target: Calves (Unilateral)**\n\n'
        '1. Stand on one leg, using a wall or chair for balance.\n'
        '2. Raise your heel as high as possible, squeezing the calf.\n'
        '3. Hold at the top for a moment, then lower with control.\n'
        '4. Complete all reps on one side before switching.\n'
        '5. To increase difficulty, perform on the edge of a step for a greater range of motion.',
  ),
];