import 'bodyweight.dart';
import 'dumbbells.dart';
import 'barbell.dart';
import 'cable.dart';
import 'selectorized.dart';
import 'dip.dart';
import 'resistance_bands.dart';
import 'chair.dart';

import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// All exercises for the Chest & Triceps split, organised by equipment type.
const List<ExercisePoolEntry> chestTricepsExercises = [
  ...chestTricepsBodyweightExercises,
  ...chestTricepsDumbbellExercises,
  ...chestTricepsBarbellExercises,
  ...chestTricepsCableExercises,
  ...chestTricepsSelectorizedExercises,
  ...chestTricepsDipExercises,
  ...chestTricepsResistanceBandsExercises,
  ...chestTricepsChairExercises,
];
