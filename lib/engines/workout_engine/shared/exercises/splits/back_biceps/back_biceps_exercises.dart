import 'bodyweight.dart';
import 'pull_up_bar.dart';
import 'dumbbells.dart';
import 'barbell.dart';
import 'cable.dart';
import 'selectorized.dart';
import 'resistance_bands.dart';
import 'kettlebell.dart';
import 'smith.dart';

import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// All exercises for the Back & Biceps split, organised by equipment type.
const List<ExercisePoolEntry> backBicepsExercises = [
  ...backBicepsBodyweightExercises,
  ...backBicepsPullUpBarExercises,
  ...backBicepsDumbbellExercises,
  ...backBicepsBarbellExercises,
  ...backBicepsCableExercises,
  ...backBicepsSelectorizedExercises,
  ...backBicepsResistanceBandsExercises,
  ...backBicepsKettlebellExercises,
  ...backBicepsSmithExercises,
];
