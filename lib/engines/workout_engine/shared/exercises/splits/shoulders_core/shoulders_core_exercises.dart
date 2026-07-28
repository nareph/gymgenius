import 'bodyweight.dart';
import 'pull_up_bar.dart';
import 'dumbbells.dart';
import 'cable.dart';
import 'ab_wheel.dart';
import 'resistance_bands.dart';
import 'barbell.dart';
import 'selectorized.dart';

import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// All exercises for the Shoulders & Core split, organised by equipment type.
const List<ExercisePoolEntry> shouldersCoreExercises = [
  ...shouldersCoreBodyweightExercises,
  ...shouldersCorePullUpBarExercises,
  ...shouldersCoreDumbbellExercises,
  ...shouldersCoreCableExercises,
  ...shouldersCoreAbWheelExercises,
  ...shouldersCoreResistanceBandsExercises,
  ...shouldersCoreBarbellExercises,
  ...shouldersCoreSelectorizedExercises,
];
