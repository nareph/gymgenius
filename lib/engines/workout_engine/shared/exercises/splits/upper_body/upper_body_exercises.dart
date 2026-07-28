import 'bodyweight.dart';
import 'pull_up_bar.dart';
import 'dumbbells.dart';
import 'cable.dart';
import 'barbell.dart';
import 'selectorized.dart';
import 'resistance_bands.dart';
import 'smith.dart';

import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// All exercises for the Upper Body split, organised by equipment type.
const List<ExercisePoolEntry> upperBodyExercises = [
  ...upperBodyBodyweightExercises,
  ...upperBodyPullUpBarExercises,
  ...upperBodyDumbbellExercises,
  ...upperBodyCableExercises,
  ...upperBodyBarbellExercises,
  ...upperBodySelectorizedExercises,
  ...upperBodyResistanceBandsExercises,
  ...upperBodySmithExercises,
];
