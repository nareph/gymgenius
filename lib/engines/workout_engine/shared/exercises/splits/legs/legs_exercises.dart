import 'bodyweight.dart';
import 'chair.dart';
import 'stairs.dart';
import 'dumbbells.dart';
import 'kettlebell.dart';
import 'barbell.dart';
import 'smith.dart';
import 'leg_press.dart';
import 'hack_squat.dart';
import 'leg_extension.dart';
import 'leg_curl.dart';
import 'cable.dart';
import 'selectorized.dart';
import 'resistance_bands.dart';

import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// All exercises for the Legs split, organised by equipment type.
const List<ExercisePoolEntry> legsExercises = [
  ...legsBodyweightExercises,
  ...legsChairExercises,
  ...legsStairsExercises,
  ...legsDumbbellExercises,
  ...legsKettlebellExercises,
  ...legsBarbellExercises,
  ...legsSmithExercises,
  ...legsLegPressExercises,
  ...legsHackSquatExercises,
  ...legsLegExtensionExercises,
  ...legsLegCurlExercises,
  ...legsCableExercises,
  ...legsSelectorizedExercises,
  ...legsResistanceBandsExercises,
];
