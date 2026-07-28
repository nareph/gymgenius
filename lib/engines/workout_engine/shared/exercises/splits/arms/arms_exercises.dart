import 'bodyweight.dart';
import 'dumbbells.dart';
import 'barbell.dart';
import 'cable.dart';
import 'resistance_bands.dart';

import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// All exercises for the Arms split, organised by equipment type.
const List<ExercisePoolEntry> armsExercises = [
  ...armsBodyweightExercises,
  ...armsDumbbellExercises,
  ...armsBarbellExercises,
  ...armsCableExercises,
  ...armsResistanceBandsExercises,
];
