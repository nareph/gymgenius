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

const List<ExercisePoolEntry> coreBodyweightExercises = [
  ExercisePoolEntry(
    id: 'core_bw_plank',
    name: 'Plank',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core**\n\n'
        '1. Start in a forearm plank position with your elbows directly under your shoulders and feet hip‑width apart.\n'
        '2. Keep your body in a straight line from head to heels, engaging your core and glutes.\n'
        '3. Hold this position for the prescribed time, maintaining tension throughout.\n'
        '4. Avoid letting your hips sag or pike up; keep your spine neutral.\n'
        '5. Breathe steadily and focus on keeping your core braced.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_side_plank',
    name: 'Side Plank',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Obliques**\n\n'
        '1. Lie on your side, propping yourself up on your forearm, with your elbow directly under your shoulder.\n'
        '2. Stack your feet and lift your hips off the floor, forming a straight line from head to heels.\n'
        '3. Hold for the prescribed time, keeping your hips elevated and core engaged.\n'
        '4. Avoid letting your hips drop or rotate.\n'
        '5. Repeat on the other side.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_bicycle_crunches',
    name: 'Bicycle Crunches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Abs, Obliques**\n\n'
        '1. Lie on your back with your knees bent, hands behind your head.\n'
        '2. Bring your right elbow toward your left knee while extending your right leg straight.\n'
        '3. Switch sides in a continuous pedaling motion, alternating each rep.\n'
        '4. Keep your lower back pressed into the floor throughout.\n'
        '5. Perform the movement in a controlled, steady rhythm.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_russian_twists',
    name: 'Russian Twists',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Sit on the floor with your knees bent and feet flat, lean your torso back at about 45°.\n'
        '2. Lift your feet off the floor and balance on your glutes.\n'
        '3. Rotate your torso to the right, tapping the floor beside your hip, then rotate to the left.\n'
        '4. Keep your core tight and your back straight.\n'
        '5. To increase difficulty, extend your legs further or hold a weight.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_mountain_climbers',
    name: 'Mountain Climbers',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.push,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Shoulders**\n\n'
        '1. Start in a high plank position with your hands directly under your shoulders.\n'
        '2. Drive one knee toward your chest, then quickly switch legs in a running motion.\n'
        '3. Keep your hips low and your core tight to maintain a stable plank.\n'
        '4. Perform at a steady pace, increasing speed as you progress.\n'
        '5. Avoid letting your hips rise too high.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_crunches',
    name: 'Crunches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Abs**\n\n'
        '1. Lie on your back with your knees bent and feet flat on the floor, hands behind your head.\n'
        '2. Curl your upper body toward your knees, lifting only your shoulder blades off the floor.\n'
        '3. Squeeze your abs at the top, then lower with control back to the starting position.\n'
        '4. Avoid pulling on your neck; keep your chin off your chest.\n'
        '5. Use a slow and controlled tempo for maximum muscle engagement.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_reverse_crunches',
    name: 'Reverse Crunches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Lie on your back with your arms at your sides, palms down, and your legs raised to a 90° angle.\n'
        '2. Use your lower abs to curl your hips off the floor, lifting your legs toward the ceiling.\n'
        '3. Squeeze at the top, then lower your hips back down with control.\n'
        '4. Keep your lower back pressed into the floor throughout.\n'
        '5. Avoid using momentum; focus on the contraction.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_leg_raises',
    name: 'Leg Raises',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Lie on your back with your legs straight, hands under your glutes for support.\n'
        '2. Raise your legs straight up to a 90° angle, keeping them straight.\n'
        '3. Lower them slowly back to the floor, stopping just before they touch to keep tension.\n'
        '4. Keep your lower back pressed into the floor throughout.\n'
        '5. For added difficulty, lower your legs closer to the floor without touching.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_flutter_kicks',
    name: 'Flutter Kicks',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs, Hip Flexors**\n\n'
        '1. Lie on your back with your legs extended and hands under your glutes.\n'
        '2. Lift your legs about 6 inches off the floor and alternate kicking them up and down.\n'
        '3. Keep your lower back pressed into the floor and your core engaged.\n'
        '4. Perform the movement in a steady, controlled rhythm.\n'
        '5. Avoid holding your breath; breathe steadily throughout.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_scissor_kicks',
    name: 'Scissor Kicks',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lower Abs**\n\n'
        '1. Lie on your back with your legs extended and hands under your glutes.\n'
        '2. Lift your legs about 6 inches off the floor and cross them over each other in a scissor motion.\n'
        '3. Keep your lower back pressed into the floor and your core engaged.\n'
        '4. Alternate quickly, maintaining control.\n'
        '5. This exercise targets the lower abs and hip flexors.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_heel_touches',
    name: 'Heel Touches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.rotation,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Obliques**\n\n'
        '1. Lie on your back with your knees bent and feet flat on the floor.\n'
        '2. Reach your right hand toward your right heel, curling your torso to the side.\n'
        '3. Return to the centre and repeat on the left side.\n'
        '4. Keep your lower back pressed into the floor throughout.\n'
        '5. Perform the movement in a controlled, steady rhythm.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_v_ups',
    name: 'V-Ups',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Full Core**\n\n'
        '1. Lie on your back with your arms extended overhead and legs straight.\n'
        '2. Simultaneously lift your arms, torso, and legs off the floor, reaching your hands toward your toes.\n'
        '3. Your body should form a V shape at the top of the movement.\n'
        '4. Hold for a second, then lower back down with control.\n'
        '5. Keep your core tight and avoid using momentum.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_dead_bug',
    name: 'Dead Bug',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Deep Core**\n\n'
        '1. Lie on your back with your arms extended toward the ceiling and your legs raised to a 90° angle.\n'
        '2. Slowly extend your right arm overhead and your left leg toward the floor, keeping your lower back pressed down.\n'
        '3. Return to the starting position and alternate sides.\n'
        '4. Keep your core braced and your hips stable throughout.\n'
        '5. This exercise improves core stability and coordination.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_toe_touches',
    name: 'Toe Touches',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Abs**\n\n'
        '1. Lie on your back with your legs extended straight up toward the ceiling.\n'
        '2. Reach your hands toward your toes, curling your shoulder blades off the floor.\n'
        '3. Squeeze your abs at the top, then lower back down with control.\n'
        '4. Keep your lower back pressed into the floor throughout.\n'
        '5. Avoid using momentum; focus on the contraction.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_plank_jacks',
    name: 'Plank Jacks',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.adductors],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Core, Adductors**\n\n'
        '1. Start in a high plank position with your hands directly under your shoulders.\n'
        '2. Jump your feet apart and then back together, keeping your hips stable and core engaged.\n'
        '3. Maintain a straight body line throughout the movement.\n'
        '4. Perform at a steady pace, focusing on control.\n'
        '5. To reduce impact, step your feet out one at a time.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_spiderman_plank',
    name: 'Spiderman Plank',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.isometric,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Hip Flexors**\n\n'
        '1. Start in a high plank position with your hands directly under your shoulders.\n'
        '2. Bring your right knee toward your right elbow, keeping your hips stable.\n'
        '3. Return to the starting position and repeat on the left side.\n'
        '4. Keep your core tight and avoid letting your hips rise.\n'
        '5. Alternate sides in a controlled manner.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_bird_dog',
    name: 'Bird Dog',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [MuscleGroup.back, MuscleGroup.glutes],
    usesWeight: false,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.isometric,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core, Lower Back**\n\n'
        '1. Start on all fours with your hands under your shoulders and knees under your hips.\n'
        '2. Extend your right arm forward and your left leg back, keeping your hips square.\n'
        '3. Hold for a second, then return to the starting position and switch sides.\n'
        '4. Keep your core braced and your spine neutral throughout.\n'
        '5. This exercise improves stability and coordination.',
  ),
  ExercisePoolEntry(
    id: 'core_bw_hollow_body_hold',
    name: 'Hollow Body Hold',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.bodyweight,
    targetMuscles: [MuscleGroup.absCore],
    secondaryMuscles: [],
    usesWeight: false,
    isTimed: true,
    movementPattern: MovementPattern.core,
    mechanics: Mechanics.openChain,
    forceType: ForceType.isometric,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Core**\n\n'
        '1. Lie on your back with your arms and legs extended.\n'
        '2. Lift your arms, shoulders, and legs off the floor, engaging your core.\n'
        '3. Your lower back should remain pressed into the floor throughout.\n'
        '4. Hold this position for the prescribed time, maintaining tension.\n'
        '5. Keep your chin tucked and your core braced.',
  ),
];
