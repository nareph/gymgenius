import 'bodyweight.dart';
import 'pull_up_bar.dart';
import 'resistance_bands.dart';
import 'dumbbells.dart';
import 'barbell.dart';
import 'cable.dart';
import 'selectorized.dart';

import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// All exercises for the Back split, organised by equipment type.
const List<ExercisePoolEntry> backExercises = [
  ...backBodyweightExercises,
  ...backPullUpBarExercises,
  ...backResistanceBandsExercises,
  ...backDumbbellExercises,
  ...backBarbellExercises,
  ...backCableExercises,
  ...backSelectorizedExercises,
];
