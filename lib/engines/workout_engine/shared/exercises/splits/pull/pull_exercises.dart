import 'bodyweight.dart';
import 'pull_up_bar.dart';
import 'smith.dart';
import 'dumbbells.dart';
import 'kettlebell.dart';
import 'resistance_bands.dart';
import 'barbell.dart';
import 'cable.dart';
import 'selectorized.dart';

import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// All exercises for the Pull split, organised by equipment type.
const List<ExercisePoolEntry> pullExercises = [
  ...pullBodyweightExercises,
  ...pullPullUpBarExercises,
  ...pullSmithExercises,
  ...pullDumbbellExercises,
  ...pullKettlebellExercises,
  ...pullResistanceBandsExercises,
  ...pullBarbellExercises,
  ...pullCableExercises,
  ...pullSelectorizedExercises,
];
