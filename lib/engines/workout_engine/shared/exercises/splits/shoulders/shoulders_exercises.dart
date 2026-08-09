import 'bodyweight.dart';
import 'barbell.dart';
import 'cable.dart';
import 'dumbbells.dart';
import 'resistance_bands.dart';
import 'selectorized.dart';

import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

const List<ExercisePoolEntry> shouldersExercises = [
  ...shouldersBodyweightExercises,
  ...shouldersBarbellExercises,
  ...shouldersCableExercises,
  ...shouldersDumbbellExercises,
  ...shouldersResistanceBandsExercises,
  ...shouldersSelectorizedExercises,
];
