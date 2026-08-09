// lib/engines/workout_engine/selectors/selection_candidate.dart

import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// A pool entry paired with its score for the CURRENT selection round.
///
/// Never cached across rounds — ExerciseScorer recomputes scores fresh
/// every time a new exercise is added, since covered-muscle state and
/// used-pattern state change after every pick.
class SelectionCandidate {
  final ExercisePoolEntry entry;
  final int score;

  const SelectionCandidate({
    required this.entry,
    required this.score,
  });
}
