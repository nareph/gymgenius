import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';

import 'split_catalog.dart';
import 'split_score.dart';

/// Chooses the best collection of training splits for a user.
///
/// Unlike the previous implementation, this planner is goal-driven
/// rather than template-driven.
///
/// Instead of:
///
///     3 workouts -> Push / Pull / Legs
///
/// it asks:
///
/// • Which splits best cover the user's priorities?
/// • Which splits provide the best weekly balance?
/// • Which splits minimize unnecessary overlap?
///
/// This allows GymGenius to evolve toward specialization programs
/// without changing the planner architecture.
class SplitPlanner {
  const SplitPlanner();

  /// Builds the weekly split plan.
  List<MuscleSplit> plan({
    required int workoutDays,
    required ExperienceLevel experience,
    required List<MuscleGroup> focusMuscles,
    FitnessGoal? goal,
  }) {
    final selected = <MuscleSplit>[];

    while (selected.length < workoutDays) {
      SplitScore? best;

      for (final split in SplitCatalog.all) {
        if (selected.contains(split)) {
          continue;
        }

        // --------------------------------------------------------
        // Experience filters
        // --------------------------------------------------------

        if (!_isAllowedForExperience(
          split,
          experience,
          workoutDays,
        )) {
          continue;
        }

        final score = SplitScore.evaluate(
          split: split,
          focusMuscles: focusMuscles,
          selectedSplits: selected,
          goal: goal,
          workoutDays: workoutDays,
        );

        if (best == null || score.score > best.score) {
          best = score;
        }
      }

      if (best == null) {
        break;
      }

      selected.add(best.split);
    }

    return _order(selected);
  }

  // ============================================================
  // Filters
  // ============================================================

  bool _isAllowedForExperience(
    MuscleSplit split,
    ExperienceLevel experience,
    int workoutDays,
  ) {
    // Beginners:
    //
    // Avoid excessive specialization when training only
    // a few days per week.

    if (experience == ExperienceLevel.beginner) {
      if (workoutDays <= 2) {
        return split.isUpperBody || split.isLowerBody || split.isFullBody;
      }

      if (workoutDays == 3) {
        return split.name == 'Push' ||
            split.name == 'Pull' ||
            split.name == 'Legs' ||
            split.isFullBody;
      }
    }

    return true;
  }

  // ============================================================
  // Final ordering
  // ============================================================

  List<MuscleSplit> _order(
    List<MuscleSplit> splits,
  ) {
    final ordered = <MuscleSplit>[];

    final remaining = [...splits];

    while (remaining.isNotEmpty) {
      if (ordered.isEmpty) {
        ordered.add(remaining.removeAt(0));
        continue;
      }

      final previous = ordered.last;

      final next = remaining.firstWhere(
        (split) =>
            split.isUpperBody != previous.isUpperBody ||
            split.isLowerBody != previous.isLowerBody,
        orElse: () => remaining.first,
      );

      remaining.remove(next);
      ordered.add(next);
    }

    return ordered;
  }
}
