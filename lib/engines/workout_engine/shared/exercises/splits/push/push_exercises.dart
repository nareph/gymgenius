import '../core/core_exercises.dart';
import 'bodyweight.dart';
import 'dumbbells.dart';
import 'barbell.dart';
import 'smith.dart';
import 'selectorized.dart';
import 'cable.dart';
import 'kettlebell.dart';
import 'resistance_bands.dart';
import 'chair.dart';
import 'dip.dart';

import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// All exercises for the Push split, organised by equipment type.
List<ExercisePoolEntry> pushExercises = [
  ...pushBodyweightExercises,
  ...pushDumbbellExercises,
  ...pushBarbellExercises,
  ...pushSmithExercises,
  ...pushSelectorizedExercises,
  ...pushCableExercises,
  ...pushKettlebellExercises,
  ...pushResistanceBandsExercises,
  ...pushChairExercises,
  ...pushDipExercises,
  ...coreExercises,
];
