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

const List<ExercisePoolEntry> backDumbbellExercises = [
  ExercisePoolEntry(
    id: 'back_db_bent_over_row',
    name: 'Dumbbell Bent-Over Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps**\n\n'
        '1. Stand with feet shoulder‑width apart, holding a dumbbell in each hand, palms facing your body.\n'
        '2. Bend at the hips with a flat back, torso nearly parallel to the floor, allowing the weights to hang straight down.\n'
        '3. Pull the dumbbells towards your lower chest, driving your elbows back and squeezing your shoulder blades.\n'
        '4. Pause at the top, then lower the weights with control to the starting position.\n'
        '5. Keep your core tight and avoid using momentum.',
  ),
  ExercisePoolEntry(
    id: 'back_db_single_arm_row',
    name: 'Single-Arm Dumbbell Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.absCore],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.unilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Back, Biceps (Unilateral)**\n\n'
        '1. Place one knee and one hand on a flat bench, with your other foot on the floor for stability.\n'
        '2. With your free hand, grab a dumbbell and let it hang straight down, palm facing your body.\n'
        '3. Pull the dumbbell up towards your hip, keeping your elbow close to your body and squeezing your lat.\n'
        '4. Lower with control, feeling the stretch in your lat, then complete all reps on one side before switching.\n'
        '5. Keep your back flat and your core engaged throughout.',
  ),
  ExercisePoolEntry(
    id: 'back_db_pullover',
    name: 'Dumbbell Pullover',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.back, MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Lats, Chest**\n\n'
        '1. Lie across a flat bench with only your upper back supported, feet firmly on the floor.\n'
        '2. Hold a single dumbbell with both hands, arms extended above your chest, palms pressing against the underside of the top plate.\n'
        '3. Keeping your arms slightly bent, lower the dumbbell in an arc behind your head until you feel a stretch in your lats.\n'
        '4. Use your lats to pull the dumbbell back up to the starting position, squeezing your lats at the top.\n'
        '5. Keep your hips low and your core stable throughout.',
  ),
  ExercisePoolEntry(
    id: 'back_db_rear_delt_fly',
    name: 'Dumbbell Rear Delt Fly',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: true,
    weightSuggestion: 'Light',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts**\n\n'
        '1. Bend forward at the hips with a flat back, holding a light dumbbell in each hand, palms facing each other.\n'
        '2. Let your arms hang straight down, then raise them out to the sides in a wide arc, squeezing your shoulder blades together.\n'
        '3. Pause when your arms are parallel to the floor, then lower with control.\n'
        '4. Keep a slight bend in your elbows throughout the movement.\n'
        '5. Use light weight to focus on form and the contraction of the rear delts.',
  ),
  ExercisePoolEntry(
    id: 'back_db_incline_row',
    name: 'Incline Dumbbell Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.dumbbells,
    targetMuscles: [MuscleGroup.back, MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.shoulders],
    usesWeight: true,
    weightSuggestion: 'Moderate',
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Upper Back, Biceps**\n\n'
        '1. Set an incline bench to about 30–45° and lie face down on it, holding a dumbbell in each hand, arms hanging straight down.\n'
        '2. Pull the dumbbells up towards your chest, driving your elbows back and squeezing your shoulder blades.\n'
        '3. Pause at the peak contraction, then lower the weights with control.\n'
        '4. Keep your neck relaxed and your chest against the bench.\n'
        '5. This variation reduces lower back strain and focuses on upper back development.',
  ),
];
