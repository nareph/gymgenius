import 'bodyweight.dart';
import 'resistance_bands.dart';
import 'chair.dart';
import 'dumbbells.dart';
import 'barbell.dart';
import 'adjustable_bench.dart';
import 'smith.dart';
import 'cable.dart';
import 'selectorized.dart';
import 'dip.dart';

import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// All exercises for the Chest split, organised by equipment type.
const List<ExercisePoolEntry> chestExercises = [
  ...chestBodyweightExercises,
  ...chestResistanceBandsExercises,
  ...chestChairExercises,
  ...chestDumbbellExercises,
  ...chestBarbellExercises,
  ...chestAdjustableBenchExercises,
  ...chestSmithExercises,
  ...chestCableExercises,
  ...chestSelectorizedExercises,
  ...chestDipExercises,
];
