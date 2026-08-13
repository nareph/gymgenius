import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';

import '../shared/profile_coherence.dart';

/// Represents the evaluation of a candidate split.
///
/// The SplitPlanner computes a SplitScore for every available split,
/// then sorts them from best to worst before selecting the required
/// number of training days.
///
/// This object is intentionally immutable so additional scoring
/// dimensions (recovery, specialization, AI preferences, etc.) can be
/// introduced without changing the planner API.
class SplitScore implements Comparable<SplitScore> {
  /// Candidate split.
  final MuscleSplit split;

  /// Number of user focus muscles covered by this split.
  final int focusCoverage;

  /// Number of muscles shared with already-selected splits.
  ///
  /// Lower is generally better because it improves weekly variety.
  final int overlap;

  /// Recovery cost of the split.
  final int recoveryCost;

  /// Final weighted score.
  final double score;

  const SplitScore({
    required this.split,
    required this.focusCoverage,
    required this.overlap,
    required this.recoveryCost,
    required this.score,
  });

  /// Creates a score from a split.
  ///
  /// Current heuristic:
  ///
  /// • Focus coverage is heavily rewarded.
  /// • Muscle overlap is penalized.
  /// • High recovery cost is slightly penalized.
  ///
  /// These weights are expected to evolve as the planner becomes more
  /// sophisticated.
  factory SplitScore.evaluate({
    required MuscleSplit split,
    required List<MuscleGroup> focusMuscles,
    List<MuscleSplit> selectedSplits = const [],
    FitnessGoal? goal,
    int workoutDays = 3,
  }) {
    final coverage = split.muscles.where(focusMuscles.contains).length;

    final overlap = selectedSplits.fold<int>(
      0,
      (count, selected) {
        return count + split.muscles.where(selected.muscles.contains).length;
      },
    );

    final goalBonus = goal == null
        ? 0.0
        : ProfileCoherence.goalSplitBonus(
            goal: goal,
            split: split,
            workoutDays: workoutDays,
          );

    final score = (coverage * 10.0) -
        (overlap * 2.0) -
        (split.recoveryCost * 0.5) +
        goalBonus;

    return SplitScore(
      split: split,
      focusCoverage: coverage,
      overlap: overlap,
      recoveryCost: split.recoveryCost,
      score: score,
    );
  }

  @override
  int compareTo(SplitScore other) {
    return other.score.compareTo(score);
  }

  @override
  String toString() {
    return '''
SplitScore(
  split: ${split.name},
  coverage: $focusCoverage,
  overlap: $overlap,
  recovery: $recoveryCost,
  score: ${score.toStringAsFixed(2)}
)
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SplitScore && split == other.split && score == other.score;
  }

  @override
  int get hashCode => Object.hash(split, score);
}
