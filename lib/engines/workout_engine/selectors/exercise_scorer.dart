import 'dart:math';

import 'package:gymgenius/engines/workout_engine/models/focus_plan.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/selectors/selection_candidate.dart';
import 'package:gymgenius/engines/workout_engine/selectors/selection_state.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// ---------------------------------------------------------------------------
/// ExerciseScorer
/// ---------------------------------------------------------------------------
///
/// Scores every remaining exercise according to the CURRENT selection state.
///
/// The score is recomputed after EVERY selected exercise.
///
/// Priority order:
///
/// 1. Remaining focus quotas
/// 2. Split fidelity
/// 3. Compound preference
/// 4. Muscle richness
/// 5. Movement diversity
/// 6. Previous program variety
///
/// Nothing except duplicate prevention is a hard rule.
/// Everything is represented as weighted preferences.
///
/// The selector simply chooses the highest score at every iteration.
/// ---------------------------------------------------------------------------
class ExerciseScorer {
  const ExerciseScorer({
    Random? random,
  }) : _random = random;

  final Random? _random;

  //==========================================================================
  // Score constants
  //==========================================================================

  /// Reward for each remaining quota.
  ///
  /// remaining quota = 3 -> +360
  /// remaining quota = 2 -> +240
  /// remaining quota = 1 -> +120
  static const int _missingQuotaBonus = 120;

  /// Rewards exercises that naturally belong to the current split.
  static const int _splitMuscleBonus = 40;

  /// Compound movements are usually preferable.
  static const int _compoundBonus = 20;

  /// Multi-muscle exercises are valuable.
  static const int _primaryMuscleBonus = 15;

  static const int _secondaryMuscleBonus = 5;

  /// Encourage movement diversity.
  static const int _repeatedPatternPenalty = -25;

  /// Encourage program regeneration variety.
  static const int _previousProgramPenalty = -30;

  /// Small preference for muscles belonging to the split
  /// but not explicitly selected as primary focus.
  static const int _secondaryFocusBonus = 12;

  //==========================================================================
  // Main scoring
  //==========================================================================

  int score({
    required ExercisePoolEntry entry,
    required SelectionState state,
    required MuscleSplit split,
    required FocusPlan focusPlan,
    required Set<String> previousNames,
  }) {
    var total = 0;

    //----------------------------------------------------------------------
    // 1. Focus priorities
    //
    // Primary focus muscles:
    //   - have real quotas
    //   - strong scoring
    //
    // Secondary focus muscles:
    //   - have NO mandatory quota
    //   - receive a smaller preference
    //   - help preserve the balance of the split
    //----------------------------------------------------------------------

    //----------------------------------------------------------
    // Primary focus muscles
    //----------------------------------------------------------

    for (final muscle in entry.targetMuscles) {
      final quota = focusPlan.quotas[muscle];

      if (quota == null || quota <= 0) {
        continue;
      }

      final current = state.coverageCount(muscle);
      final remaining = quota - current;

      if (remaining > 0) {
        total += remaining * _missingQuotaBonus;
      } else {
        // IMPORTANT:
        // No more quota bonus once the primary quota is satisfied.
        //
        // This prevents an exercise from continuing to dominate
        // the selection simply because it targets the focus muscle.
        total += 0;
      }
    }

    //----------------------------------------------------------
    // Secondary focus muscles
    //----------------------------------------------------------
    //
    // Secondary muscles do NOT have quotas.
    //
    // They are simply preferred when they belong to the split
    // but are not part of the primary focus.
    //
    // Example:
    //
    // Push split:
    //   primary      = chest
    //   secondary    = shoulders, triceps, absCore
    //
    // An exercise targeting shoulders receives a small bonus,
    // but it can never compete with an exercise satisfying
    // a missing chest quota solely because of this bonus.
    //----------------------------------------------------------

    for (final muscle in entry.targetMuscles) {
      if (!focusPlan.secondaryFocusMuscles.contains(muscle)) {
        continue;
      }

      total += _secondaryFocusBonus;
    }

    //----------------------------------------------------------
    // Secondary muscles of the exercise
    //----------------------------------------------------------
    //
    // An exercise can also hit a secondary-focus muscle through
    // its secondaryMuscles field.
    //
    // Example:
    //
    // targetMuscles:
    //   [chest]
    //
    // secondaryMuscles:
    //   [triceps, shoulders]
    //
    // If triceps is a secondary focus of the split, reward it
    // slightly as well.
    //----------------------------------------------------------

    for (final muscle in entry.secondaryMuscles) {
      if (!focusPlan.secondaryFocusMuscles.contains(muscle)) {
        continue;
      }

      total += _secondaryFocusBonus;
    }

    //----------------------------------------------------------------------
    // 2. Split fidelity
    //----------------------------------------------------------------------

    for (final muscle in entry.targetMuscles) {
      if (split.targets(muscle)) {
        total += _splitMuscleBonus;
      }
    }

    //----------------------------------------------------------------------
    // 3. Compound bonus
    //----------------------------------------------------------------------

    if (entry.isCompound) {
      total += _compoundBonus;
    }

    //----------------------------------------------------------------------
    // 4. Muscle richness
    //----------------------------------------------------------------------

    total += entry.targetMuscles.length * _primaryMuscleBonus;

    total += entry.secondaryMuscles.length * _secondaryMuscleBonus;

    //----------------------------------------------------------------------
    // 5. Movement diversity
    //----------------------------------------------------------------------

    if (state.containsPattern(entry.movementPattern.name)) {
      total += _repeatedPatternPenalty;
    }

    //----------------------------------------------------------------------
    // 6. Previous program
    //----------------------------------------------------------------------

    if (previousNames.contains(entry.name)) {
      total += _previousProgramPenalty;
    }

    return total;
  }
  //==========================================================================
  // Tie-break
  //==========================================================================

  /// Used when two exercises have exactly the same score.
  ///
  /// Preference order:
  ///
  /// 1. Compound exercise
  /// 2. Better split fidelity
  /// 3. More primary muscles
  /// 4. More secondary muscles
  /// 5. Higher movement diversity
  /// 6. Random (optional)
  bool _isBetterTieBreak({
    required ExercisePoolEntry candidate,
    required ExercisePoolEntry current,
    required MuscleSplit split,
    required SelectionState state,
  }) {
    //----------------------------------------------------------------------
    // Compound first
    //----------------------------------------------------------------------

    if (candidate.isCompound != current.isCompound) {
      return candidate.isCompound;
    }

    //----------------------------------------------------------------------
    // Better split fidelity
    //----------------------------------------------------------------------

    final candidateSplit = candidate.targetMuscles.where(split.targets).length;

    final currentSplit = current.targetMuscles.where(split.targets).length;

    if (candidateSplit != currentSplit) {
      return candidateSplit > currentSplit;
    }

    //----------------------------------------------------------------------
    // Richer primary muscles
    //----------------------------------------------------------------------

    if (candidate.targetMuscles.length != current.targetMuscles.length) {
      return candidate.targetMuscles.length > current.targetMuscles.length;
    }

    //----------------------------------------------------------------------
    // Richer secondary muscles
    //----------------------------------------------------------------------

    if (candidate.secondaryMuscles.length != current.secondaryMuscles.length) {
      return candidate.secondaryMuscles.length >
          current.secondaryMuscles.length;
    }

    //----------------------------------------------------------------------
    // Prefer introducing a NEW movement pattern.
    //----------------------------------------------------------------------

    final candidateNewPattern =
        !state.containsPattern(candidate.movementPattern.name);

    final currentNewPattern =
        !state.containsPattern(current.movementPattern.name);

    if (candidateNewPattern != currentNewPattern) {
      return candidateNewPattern;
    }

    //----------------------------------------------------------------------
    // Final random tie-break.
    //----------------------------------------------------------------------

    if (_random != null) {
      return _random!.nextBool();
    }

    return false;
  }

  //==========================================================================
  // Candidate search
  //==========================================================================

  SelectionCandidate? bestCandidate({
    required List<ExercisePoolEntry> pool,
    required SelectionState state,
    required MuscleSplit split,
    required FocusPlan focusPlan,
    required Set<String> previousNames,
  }) {
    SelectionCandidate? best;

    for (final entry in pool) {
      //------------------------------------------------------------
      // Never select duplicates.
      //------------------------------------------------------------

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

      //------------------------------------------------------------
      // First candidate
      //------------------------------------------------------------

      if (best == null) {
        best = SelectionCandidate(
          entry: entry,
          score: value,
        );
        continue;
      }

      //------------------------------------------------------------
      // Better score
      //------------------------------------------------------------

      if (value > best.score) {
        best = SelectionCandidate(
          entry: entry,
          score: value,
        );
        continue;
      }

      //------------------------------------------------------------
      // Same score -> tie-break
      //------------------------------------------------------------

      if (value == best.score &&
          _isBetterTieBreak(
            candidate: entry,
            current: best.entry,
            split: split,
            state: state,
          )) {
        best = SelectionCandidate(
          entry: entry,
          score: value,
        );
      }
    }

    return best;
  }
}
