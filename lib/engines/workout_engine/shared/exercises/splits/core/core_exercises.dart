import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';
import 'bodyweight.dart';
import 'resistance_bands.dart';
import 'dumbbells.dart';
import 'ab_wheel.dart';
import 'cable.dart';
import 'pull_up_bar.dart';
import 'selectorized.dart';

final List<ExercisePoolEntry> coreExercises = [
  ...coreBodyweightExercises,
  ...coreResistanceBandsExercises,
  ...coreDumbbellExercises,
  ...coreAbWheelExercises,
  ...coreCableExercises,
  ...corePullUpBarExercises,
  ...coreSelectorizedExercises,
];
