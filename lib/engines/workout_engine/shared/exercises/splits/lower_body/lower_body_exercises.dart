import 'bodyweight.dart';
import 'chair.dart';
import 'stairs.dart';
import 'dumbbells.dart';
import 'leg_extension.dart';
import 'leg_curl.dart';
import 'leg_press.dart';
import 'hack_squat.dart';
import 'barbell.dart';
import 'cable.dart';
import 'selectorized.dart';
import 'resistance_bands.dart';
import 'kettlebell.dart';
import 'smith.dart';

import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// All exercises for the Lower Body split, organised by equipment type.
const List<ExercisePoolEntry> lowerBodyExercises = [
  ...lowerBodyBodyweightExercises,
  ...lowerBodyChairExercises,
  ...lowerBodyStairsExercises,
  ...lowerBodyDumbbellExercises,
  ...lowerBodyLegExtensionExercises,
  ...lowerBodyLegCurlExercises,
  ...lowerBodyLegPressExercises,
  ...lowerBodyHackSquatExercises,
  ...lowerBodyBarbellExercises,
  ...lowerBodyCableExercises,
  ...lowerBodySelectorizedExercises,
  ...lowerBodyResistanceBandsExercises,
  ...lowerBodyKettlebellExercises,
  ...lowerBodySmithExercises,
];
