// lib/engines/workout_engine/selectors/exercise_scorer.dart

import 'dart:math';

import 'package:gymgenius/engines/workout_engine/models/focus_plan.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/selectors/selection_candidate.dart';
import 'package:gymgenius/engines/workout_engine/selectors/selection_state.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// Scores every remaining exercise according to the current selection state.
class ExerciseScorer {
  const ExerciseScorer({
    Random? random,
  }) : _random = random;

  final Random? _random;

  //===========================================================================
  // Score constants
  //===========================================================================

  static const int _missingQuotaBonus = 120;

  static const int _splitCoverageBonus = 55;

  static const int _secondaryCoverageBonus = 20;

  static const int _compoundBonus = 20;

  static const int _primaryMuscleBonus = 15;

  static const int _secondaryMuscleBonus = 5;

  static const int _repeatedPatternPenalty = -30;

  static const int _previousProgramPenalty = -30;

  //===========================================================================
  // Main scoring
  //===========================================================================

  int score({
    required ExercisePoolEntry entry,
    required SelectionState state,
    required MuscleSplit split,
    required FocusPlan focusPlan,
    required Set<String> previousNames,
  }) {
    var total = 0;

    // -----------------------------------------------------------------------
    // 1. Primary focus quotas
    // -----------------------------------------------------------------------

    for (final muscle in entry.targetMuscles) {
      final quota = focusPlan.quotas[muscle];

      if (quota == null || quota <= 0) {
        continue;
      }

      final current = state.coverageCount(muscle);
      final remaining = quota - current;

      if (remaining > 0) {
        total += remaining * _missingQuotaBonus;
      }
    }

    // -----------------------------------------------------------------------
    // 2. Secondary split coverage
    // -----------------------------------------------------------------------

    for (final muscle in entry.targetMuscles) {
      if (!split.targets(muscle)) {
        continue;
      }

      total += _splitCoverageBonus;

      if (focusPlan.secondaryFocusMuscles.contains(muscle)) {
        total += _secondaryCoverageBonus;
      }
    }

    for (final muscle in entry.secondaryMuscles) {
      if (focusPlan.secondaryFocusMuscles.contains(muscle)) {
        total += _secondaryCoverageBonus;
      }
    }

    // -----------------------------------------------------------------------
    // 3. Reward muscles whose current coverage is still low.
    //
    // This prevents the greedy selector from repeatedly choosing the same
    // muscle once its quota is already satisfied.
    // -----------------------------------------------------------------------

    for (final muscle in entry.targetMuscles) {
      if (!split.targets(muscle)) {
        continue;
      }

      final currentCoverage = state.coverageCount(muscle);

      if (currentCoverage == 0) {
        total += 50;
      } else if (currentCoverage == 1) {
        total += 20;
      }
    }

    // -----------------------------------------------------------------------
    // 4. Compound
    // -----------------------------------------------------------------------

    if (entry.isCompound) {
      total += _compoundBonus;
    }

    // -----------------------------------------------------------------------
    // 5. Muscle richness
    // -----------------------------------------------------------------------

    total += entry.targetMuscles.length * _primaryMuscleBonus;
    total += entry.secondaryMuscles.length * _secondaryMuscleBonus;

    // -----------------------------------------------------------------------
    // 6. Movement diversity
    // -----------------------------------------------------------------------

    if (state.containsPattern(entry.movementPattern.name)) {
      total += _repeatedPatternPenalty;
    }

    // -----------------------------------------------------------------------
    // 7. Previous program variety
    // -----------------------------------------------------------------------

    if (previousNames.contains(entry.name)) {
      total += _previousProgramPenalty;
    }

    return total;
  }

  //===========================================================================
  // Candidate search
  //===========================================================================

  SelectionCandidate? bestCandidate({
    required List<ExercisePoolEntry> pool,
    required SelectionState state,
    required MuscleSplit split,
    required FocusPlan focusPlan,
    required Set<String> previousNames,
  }) {
    SelectionCandidate? best;

    for (final entry in pool) {
      if (state.containsExercise(entry.name)) {
        continue;
      }

      final value = score(
        entry: entry,
        state: state,
        split: split,
        focusPlan: focusPlan,
        previousNames: previousNames,
      );

      if (best == null) {
        best = SelectionCandidate(
          entry: entry,
          score: value,
        );
        continue;
      }

      if (value > best.score) {
        best = SelectionCandidate(
          entry: entry,
          score: value,
        );
        continue;
      }

      if (value == best.score &&
          _isBetterTieBreak(
            candidate: entry,
            current: best.entry,
            split: split,
            state: state,
            focusPlan: focusPlan,
          )) {
        best = SelectionCandidate(
          entry: entry,
          score: value,
        );
      }
    }

    return best;
  }

  //===========================================================================
  // Tie-break
  //===========================================================================

  bool _isBetterTieBreak({
    required ExercisePoolEntry candidate,
    required ExercisePoolEntry current,
    required MuscleSplit split,
    required SelectionState state,
    required FocusPlan focusPlan,
  }) {
    final candidateNeeds = _quotaNeed(
      candidate,
      state,
      focusPlan,
    );

    final currentNeeds = _quotaNeed(
      current,
      state,
      focusPlan,
    );

    if (candidateNeeds != currentNeeds) {
      return candidateNeeds > currentNeeds;
    }

    final candidateSplitCoverage =
        candidate.targetMuscles.where(split.targets).length;

    final currentSplitCoverage =
        current.targetMuscles.where(split.targets).length;

    if (candidateSplitCoverage != currentSplitCoverage) {
      return candidateSplitCoverage > currentSplitCoverage;
    }

    final candidateNewPattern =
        !state.containsPattern(candidate.movementPattern.name);

    final currentNewPattern =
        !state.containsPattern(current.movementPattern.name);

    if (candidateNewPattern != currentNewPattern) {
      return candidateNewPattern;
    }

    if (candidate.isCompound != current.isCompound) {
      return candidate.isCompound;
    }

    if (candidate.targetMuscles.length != current.targetMuscles.length) {
      return candidate.targetMuscles.length > current.targetMuscles.length;
    }

    if (candidate.secondaryMuscles.length != current.secondaryMuscles.length) {
      return candidate.secondaryMuscles.length >
          current.secondaryMuscles.length;
    }

    if (_random != null) {
      return _random!.nextBool();
    }

    return false;
  }

  int _quotaNeed(
    ExercisePoolEntry entry,
    SelectionState state,
    FocusPlan focusPlan,
  ) {
    var need = 0;

    for (final muscle in entry.targetMuscles) {
      final quota = focusPlan.quotas[muscle];

      if (quota == null || quota <= 0) {
        continue;
      }

      final current = state.coverageCount(muscle);

      if (current < quota) {
        need += quota - current;
      }
    }

    return need;
  }
}
