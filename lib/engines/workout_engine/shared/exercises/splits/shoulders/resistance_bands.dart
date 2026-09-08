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

const List<ExercisePoolEntry> shouldersResistanceBandsExercises = [
  ExercisePoolEntry(
    id: 'shoulders_band_shoulder_press',
    name: 'Band Shoulder Press',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Triceps**\n\n'
        '1. Stand on a resistance band, holding the handles at shoulder height with palms facing forward.\n'
        '2. Press the handles overhead until your arms are fully extended, keeping the band under tension.\n'
        '3. Pause briefly, then lower with control back to shoulder height.\n'
        '4. Keep your core tight and avoid arching your back.\n'
        '5. For more resistance, use a thicker band or step further onto it.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_band_lateral_raise',
    name: 'Band Lateral Raise',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.frontal,
    description: '**Target: Side Shoulders**\n\n'
        '1. Stand on a resistance band, holding the handles at your sides with arms straight.\n'
        '2. Keeping a slight bend in your elbows, raise your arms out to the sides to shoulder height.\n'
        '3. Pause at the top, then lower slowly against the band tension.\n'
        '4. Keep your core tight and avoid swinging.\n'
        '5. This provides constant tension throughout the movement.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_band_face_pull',
    name: 'Band Face Pull',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.back],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.transverse,
    description: '**Target: Rear Delts, Traps**\n\n'
        '1. Anchor a resistance band at face height (e.g., to a door handle or pole).\n'
        '2. Hold the band with both hands, arms extended, and step back to create tension.\n'
        '3. Pull the band towards your face, keeping your elbows high and your hands near your ears.\n'
        '4. Squeeze your shoulder blades together at the peak, then return slowly.\n'
        '5. This exercise is excellent for correcting rounded shoulders and improving posture.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_band_front_raise',
    name: 'Band Front Raise',
    category: ExerciseCategory.isolation,
    difficulty: ExerciseDifficulty.beginner,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders],
    secondaryMuscles: [],
    usesWeight: false,
    movementPattern: MovementPattern.push,
    mechanics: Mechanics.openChain,
    forceType: ForceType.push,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Front Shoulders**\n\n'
        '1. Stand on a resistance band, holding the handles in front of your thighs, arms straight.\n'
        '2. Raise your arms forward to shoulder height, keeping them straight and the band under tension.\n'
        '3. Pause at the top, then lower with control.\n'
        '4. Keep your core tight and avoid using momentum.\n'
        '5. For increased tension, use a thicker band or step further onto it.',
  ),
  ExercisePoolEntry(
    id: 'shoulders_band_upright_row',
    name: 'Band Upright Row',
    category: ExerciseCategory.compound,
    difficulty: ExerciseDifficulty.intermediate,
    equipmentType: EquipmentType.resistanceBands,
    targetMuscles: [MuscleGroup.shoulders, MuscleGroup.traps],
    secondaryMuscles: [MuscleGroup.biceps],
    usesWeight: false,
    movementPattern: MovementPattern.pull,
    mechanics: Mechanics.openChain,
    forceType: ForceType.pull,
    laterality: Laterality.bilateral,
    planeOfMotion: PlaneOfMotion.sagittal,
    description: '**Target: Shoulders, Traps**\n\n'
        '1. Stand on a resistance band, holding the handles with an overhand grip in front of your thighs.\n'
        '2. Pull the handles straight up towards your chin, leading with your elbows.\n'
        '3. Keep the handles close to your body and pause at the top.\n'
        '4. Lower with control against the band tension.\n'
        '5. Avoid excessive tension to prevent shoulder impingement.',
  ),
];
