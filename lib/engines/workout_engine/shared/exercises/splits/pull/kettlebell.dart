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

const List<ExercisePoolEntry> pullKettlebellExercises = [
  ExercisePoolEntry(
    id: 'pull_kb_kettlebell_rows',
    name: 'Kettlebell Rows',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Place one knee and one hand on a flat bench, with your other foot on the floor for stability.\n'
        '2. With your free hand, grab a kettlebell and let it hang straight down.\n'
        '3. Pull the kettlebell up towards your hip, keeping your elbow close to your body and squeezing your lat.\n'
        '4. Lower with control, feeling the stretch in your lat, then complete all reps on one side before switching.\n'
        '5. Keep your back flat and your core engaged throughout.',
  ),
  ExercisePoolEntry(
    id: 'pull_kb_single_arm_swing',
    name: 'Single-Arm Kettlebell Swing',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [
      MuscleGroup.back,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Glutes, Hamstrings**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a kettlebell in one hand between your legs.\n'
        '2. Hinge at your hips, swing the kettlebell back between your legs, keeping your back flat.\n'
        '3. Drive your hips forward explosively to swing the kettlebell up to chest height, squeezing your glutes and lats.\n'
        '4. Allow the kettlebell to swing back down between your legs with control.\n'
        '5. Complete all reps on one side before switching.',
  ),
  ExercisePoolEntry(
    id: 'pull_kb_deadlift',
    name: 'Kettlebell Deadlift',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [
      MuscleGroup.back,
      MuscleGroup.glutes,
      MuscleGroup.hamstrings
    ],
    secondaryMuscles: [MuscleGroup.quadriceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.hinge,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Full Posterior Chain**\n\n'
        '1. Stand with feet hip‑width apart, a kettlebell on the floor between your feet.\n'
        '2. Hinge at your hips and bend your knees, grip the kettlebell handle with both hands, and keep your back flat.\n'
        '3. Drive through your heels to stand up, squeezing your glutes and lats at the top.\n'
        '4. Lower the kettlebell back to the floor with control, maintaining a flat back.\n'
        '5. Reset each rep from a dead stop on the floor.',
  ),
  ExercisePoolEntry(
    id: 'pull_kb_shrugs',
    name: 'Kettlebell Shrugs',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.traps],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Traps**\n\n'
        '1. Stand upright with feet shoulder‑width apart, holding a kettlebell in each hand at your sides.\n'
        '2. Keeping your arms straight, shrug your shoulders straight up towards your ears as high as possible.\n'
        '3. Squeeze your traps at the top, hold for a second, then lower with control.\n'
        '4. Avoid rolling your shoulders; focus on a pure vertical movement.\n'
        '5. Use moderate weight to maintain strict form.',
  ),
  ExercisePoolEntry(
    id: 'pull_kb_renagade_row',
    name: 'Kettlebell Renegade Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.advanced,
    equipmentType: EquipmentType.kettlebell,
    targetMuscles: [MuscleGroup.back, MuscleGroup.absCore, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.closedChain,
    forceType: ForceType.pull,
    laterality: Laterality.alternating,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Core, Biceps**\n\n'
        '1. Start in a high plank position with a kettlebell in each hand, hands directly under your shoulders.\n'
        '2. Keep your core braced and hips stable, then row the right kettlebell up towards your hip, squeezing your lat.\n'
        '3. Lower the kettlebell back to the floor with control.\n'
        '4. Repeat on the left side, alternating each rep.\n'
        '5. This movement requires significant core stability; use a light weight to maintain form.',
  ),
];
