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

const List<ExercisePoolEntry> legsBarbellExercises = [
  ExercisePoolEntry(
    id: 'legs_bb_squats',
    name: 'Barbell Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
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
        '1. Position a barbell across your upper back (low bar or high bar), feet shoulder‑width apart, toes slightly pointed out.\n'
        '2. Unrack the bar, brace your core, and initiate the squat by pushing your hips back and bending your knees.\n'
        '3. Lower your body until your thighs are at least parallel to the floor, keeping your chest up and back straight.\n'
        '4. Drive through your heels to stand back up to the starting position, squeezing your glutes at the top.\n'
        '5. Keep your knees tracking over your toes and avoid letting them cave inward.',
  ),
  ExercisePoolEntry(
    id: 'legs_bb_front_squats',
    name: 'Front Squats',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.squat,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Quadriceps, Glutes**\n\n'
        '1. Rest the barbell across the front of your shoulders, crossing your arms to hold it in place (or using a clean grip with elbows high).\n'
        '2. Keep your elbows up and chest proud throughout the movement.\n'
        '3. Squat down by pushing your hips back and bending your knees, keeping your torso as upright as possible.\n'
        '4. Descend until your thighs are parallel to the floor or deeper.\n'
        '5. Drive through your heels to stand back up, keeping the bar stable and your core braced.',
  ),
  ExercisePoolEntry(
    id: 'legs_bb_deadlifts',
    name: 'Barbell Deadlifts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [
      MuscleGroup.hamstrings,
      MuscleGroup.glutes,
      MuscleGroup.quadriceps
    ],
    secondaryMuscles: [MuscleGroup.back],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings, Glutes, Lower Back**\n\n'
        '1. Stand with feet hip‑width apart, barbell over the middle of your feet, shins touching the bar.\n'
        '2. Hinge at your hips and bend your knees to grip the bar just outside your knees with a shoulder‑width grip.\n'
        '3. Keep your back flat, chest up, and drive through your heels to lift the bar off the floor, keeping it close to your body.\n'
        '4. Stand tall with the bar at hip height, squeezing your glutes at the top.\n'
        '5. Lower the bar back to the floor with control, maintaining a flat back throughout.',
  ),
  ExercisePoolEntry(
    id: 'legs_bb_sumo_deadlifts',
    name: 'Sumo Deadlifts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [
      MuscleGroup.glutes,
      MuscleGroup.hamstrings,
      MuscleGroup.quadriceps
    ],
    secondaryMuscles: [MuscleGroup.adductors, MuscleGroup.back],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Glutes, Inner Thighs, Hamstrings**\n\n'
        '1. Stand with your feet much wider than shoulder‑width apart, toes pointed out at about 45°.\n'
        '2. Position the barbell over the middle of your feet, with your shins touching the bar.\n'
        '3. Grip the bar with your hands inside your knees, using a shoulder‑width grip (or slightly narrower).\n'
        '4. Keep your chest up, back flat, and drive through your heels to lift the bar, squeezing your glutes at the top.\n'
        '5. Lower the bar with control, maintaining tension in your hamstrings and glutes.',
  ),
  ExercisePoolEntry(
    id: 'legs_bb_romanian_deadlifts',
    name: 'Barbell Romanian Deadlifts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.hamstrings, MuscleGroup.glutes],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Hamstrings, Glutes**\n\n'
        '1. Stand with feet hip‑width apart, holding a barbell in front of your thighs with an overhand grip.\n'
        '2. Keeping your knees slightly bent, push your hips back and lower the barbell down your legs, keeping your back flat.\n'
        '3. Lower until you feel a deep stretch in your hamstrings (bar around mid‑shin), then drive your hips forward to stand back up.\n'
        '4. Keep the bar close to your body throughout the movement.\n'
        '5. Avoid rounding your back; the movement is predominantly a hip hinge.',
  ),
  ExercisePoolEntry(
    id: 'legs_bb_hip_thrusts',
    name: 'Barbell Hip Thrusts',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.barbellAndPlates,
    targetMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Heavy',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Glutes, Hamstrings**\n\n'
        '1. Sit on the floor with your upper back resting against a bench, a barbell placed over your hips (use a pad for comfort).\n'
        '2. Place your feet flat on the floor, knees bent, about shoulder‑width apart.\n'
        '3. Drive through your heels to lift your hips toward the ceiling, squeezing your glutes at the top.\n'
        '4. Pause for a second at the top, then lower your hips back down with control.\n'
        '5. Keep your chin tucked and your core engaged to protect your spine.',
  ),
];
