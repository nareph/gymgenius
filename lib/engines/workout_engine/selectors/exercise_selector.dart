import 'dart:math';

import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';

import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';

import 'package:gymgenius/domain/value_objects/workout_preferences.dart';
import 'package:gymgenius/engines/workout_engine/models/focus_plan.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';

import 'package:gymgenius/engines/workout_engine/selectors/exercise_scorer.dart';
import 'package:gymgenius/engines/workout_engine/selectors/focus_quota_planner.dart';
import 'package:gymgenius/engines/workout_engine/selectors/selection_candidate.dart';
import 'package:gymgenius/engines/workout_engine/selectors/selection_state.dart';

import 'package:gymgenius/engines/workout_engine/shared/exercises/exercise_pool.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';
import 'package:gymgenius/engines/workout_engine/shared/profile_coherence.dart';

/// ---------------------------------------------------------------------------
/// ExerciseSelector
/// ---------------------------------------------------------------------------
///
/// Selects exercises for one workout day.
///
/// Selection is guided by:
///
/// • validated split scope
/// • explicit user focus areas
/// • focus quotas
/// • balanced coverage of the split muscles
/// • movement diversity
/// • experience level
/// • previous-program variety
/// • equipment availability
///
/// Important:
///
/// The selector never replaces the split.
/// It only fills the split with exercises.
///
/// Example:
///
/// Arms
///   → Biceps
///   → Triceps
///   → Forearms
///
/// The selector tries to make sure every available arm subgroup receives
/// meaningful representation when the workout has enough exercise slots.
///
/// The same principle applies to other multi-muscle splits such as:
///
/// Legs
///   → Quadriceps
///   → Hamstrings
///   → Glutes
///   → Calves
///
/// Shoulders & Core
///   → Shoulders
///   → Traps
///   → Abs/Core
class ExerciseSelector {
  ExerciseSelector({
    Random? random,
    ExerciseScorer? scorer,
  })  : _random = random ?? Random(),
        _scorer = scorer ?? const ExerciseScorer();

  //===========================================================================
  // Dependencies
  //===========================================================================

  final Random _random;

  final ExerciseScorer _scorer;

  final FocusQuotaPlanner _quotaPlanner = const FocusQuotaPlanner();

  //===========================================================================
  // Public API
  //===========================================================================

  List<ExercisePoolEntry> select({
    required MuscleSplit split,
    required HealthProfile profile,
    required int desiredCount,
    TrainingProgram? previousProgram,
    List<MuscleGroup>? excludeMuscles,
  }) {
    if (desiredCount <= 0) {
      return const [];
    }

    final training = profile.training;

    //-----------------------------------------------------------------------
    // Previous program
    //-----------------------------------------------------------------------

    final previousNames = _previousExerciseNames(previousProgram);

    //-----------------------------------------------------------------------
    // Avoided muscles
    //-----------------------------------------------------------------------

    final resolvedExcludedMuscles = ProfileCoherence.resolveAvoidedMuscles(
      profileAvoided: training.avoidedMuscles,
      extra: excludeMuscles,
    );

    //-----------------------------------------------------------------------
    // Candidate pool
    //-----------------------------------------------------------------------

    final candidatePool = _buildCandidatePool(
      split: split,
      training: training,
      excludeMuscles: resolvedExcludedMuscles,
      experience: training.experience,
    );

    if (candidatePool.isEmpty) {
      return const [];
    }

    //-----------------------------------------------------------------------
    // Focus plan
    //-----------------------------------------------------------------------

    final focusMuscles = ProfileCoherence.resolveFocusAreas(
      goal: training.goal,
      userFocusAreas: training.focusAreas,
    );

    final FocusPlan focusPlan = _quotaPlanner.buildPlan(
      split: split,
      focusMuscles: focusMuscles,
      desiredExerciseCount: desiredCount,
    );

    //-----------------------------------------------------------------------
    // Split-muscle coverage targets
    //
    // This is intentionally separate from focus quotas.
    //
    // Focus quotas answer:
    //
    //     "Which user-selected muscles are priorities?"
    //
    // Split coverage answers:
    //
    //     "Which muscles belonging to this split should receive
    //      representation so the day is not dominated by one subgroup?"
    //
    // This is what prevents an Arms workout from becoming almost entirely
    // triceps, for example.
    //-----------------------------------------------------------------------

    final splitCoverageQuotas = _buildSplitCoverageQuotas(
      split: split,
      candidatePool: candidatePool,
      desiredCount: desiredCount,
    );

    //-----------------------------------------------------------------------
    // Mutable state
    //-----------------------------------------------------------------------

    final state = SelectionState();

    //-----------------------------------------------------------------------
    // Greedy selection
    //-----------------------------------------------------------------------

    while (!state.isComplete(desiredCount)) {
      final candidate = _bestCandidate(
        pool: candidatePool,
        state: state,
        split: split,
        focusPlan: focusPlan,
        previousNames: previousNames,
        splitCoverageQuotas: splitCoverageQuotas,
      );

      if (candidate == null) {
        break;
      }

      state.add(candidate.entry);
    }

    return state.selected;
  }

  //===========================================================================
  // Candidate selection
  //===========================================================================

  SelectionCandidate? _bestCandidate({
    required List<ExercisePoolEntry> pool,
    required SelectionState state,
    required MuscleSplit split,
    required FocusPlan focusPlan,
    required Set<String> previousNames,
    required Map<MuscleGroup, int> splitCoverageQuotas,
  }) {
    SelectionCandidate? best;

    final missingSplitMuscles = _missingSplitMuscles(
      state: state,
      splitCoverageQuotas: splitCoverageQuotas,
    );

    //-----------------------------------------------------------------------
    // When the current split still has uncovered muscle groups, give candidates
    // covering those groups a strong temporary priority.
    //
    // This happens before the normal scorer result is compared.
    //-----------------------------------------------------------------------

    final enforceSplitCoverage = missingSplitMuscles.isNotEmpty;

    for (final entry in pool) {
      if (state.containsExercise(entry.name)) {
        continue;
      }

      final baseScore = _scorer.score(
        entry: entry,
        state: state,
        split: split,
        focusPlan: focusPlan,
        previousNames: previousNames,
      );

      final coverageBonus = enforceSplitCoverage
          ? _splitCoverageBonus(
              entry: entry,
              missingMuscles: missingSplitMuscles,
            )
          : 0;

      final value = baseScore + coverageBonus;

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
          _isBetterCoverageTieBreak(
            candidate: entry,
            current: best.entry,
            missingMuscles: missingSplitMuscles,
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

  //===========================================================================
  // Split coverage quotas
  //===========================================================================

  /// Builds minimum representation targets for muscles belonging to the
  /// current split.
  ///
  /// The selector intentionally does not force every split muscle when the
  /// workout is too small.
  ///
  /// Examples:
  ///
  /// Arms + 6 exercises:
  ///
  ///   biceps   -> 1
  ///   triceps  -> 1
  ///   forearms -> 1
  ///
  /// Legs + 8 exercises:
  ///
  ///   quadriceps -> 1
  ///   hamstrings -> 1
  ///   glutes     -> 1
  ///   calves     -> 1
  ///
  /// The remaining slots are then decided by ExerciseScorer.
  Map<MuscleGroup, int> _buildSplitCoverageQuotas({
    required MuscleSplit split,
    required List<ExercisePoolEntry> candidatePool,
    required int desiredCount,
  }) {
    final availableMuscles = <MuscleGroup>[];

    //-----------------------------------------------------------------------
    // Only retain split muscles that actually occur as primary targets in
    // the candidate pool.
    //-----------------------------------------------------------------------

    for (final muscle in split.muscles) {
      final available = candidatePool.any(
        (entry) => entry.targetMuscles.contains(muscle),
      );

      if (available) {
        availableMuscles.add(muscle);
      }
    }

    if (availableMuscles.isEmpty) {
      return const {};
    }

    //-----------------------------------------------------------------------
    // A single exercise cannot meaningfully represent more categories than
    // there are workout slots.
    //-----------------------------------------------------------------------

    final targetMuscleCount = min(
      availableMuscles.length,
      desiredCount,
    );

    if (targetMuscleCount <= 0) {
      return const {};
    }

    //-----------------------------------------------------------------------
    // Prefer one minimum representation for each split muscle.
    //
    // Example:
    //
    // Arms = [biceps, triceps, forearms]
    // desiredCount = 6
    //
    // => each receives at least one slot.
    //-----------------------------------------------------------------------

    final quotas = <MuscleGroup, int>{};

    for (var i = 0; i < targetMuscleCount; i++) {
      quotas[availableMuscles[i]] = 1;
    }

    return quotas;
  }

  List<MuscleGroup> _missingSplitMuscles({
    required SelectionState state,
    required Map<MuscleGroup, int> splitCoverageQuotas,
  }) {
    final missing = <MuscleGroup>[];

    for (final entry in splitCoverageQuotas.entries) {
      final current = state.coverageCount(entry.key);

      if (current < entry.value) {
        missing.add(entry.key);
      }
    }

    return missing;
  }

  /// Strong temporary bonus used until every required split subgroup has
  /// received at least one primary exercise.
  ///
  /// This is intentionally lower than the largest possible focus-quota
  /// contribution, so an explicit focus can still dominate where appropriate.
  int _splitCoverageBonus({
    required ExercisePoolEntry entry,
    required List<MuscleGroup> missingMuscles,
  }) {
    final coveredMissing =
        entry.targetMuscles.where(missingMuscles.contains).length;

    if (coveredMissing == 0) {
      return 0;
    }

    return coveredMissing * 90;
  }

  //===========================================================================
  // Coverage tie-break
  //===========================================================================

  bool _isBetterCoverageTieBreak({
    required ExercisePoolEntry candidate,
    required ExercisePoolEntry current,
    required List<MuscleGroup> missingMuscles,
    required SelectionState state,
  }) {
    final candidateCoverage =
        candidate.targetMuscles.where(missingMuscles.contains).length;

    final currentCoverage =
        current.targetMuscles.where(missingMuscles.contains).length;

    if (candidateCoverage != currentCoverage) {
      return candidateCoverage > currentCoverage;
    }

    //-----------------------------------------------------------------------
    // Prefer an exercise that introduces a new movement pattern.
    //-----------------------------------------------------------------------

    final candidateNewPattern =
        !state.containsPattern(candidate.movementPattern.name);

    final currentNewPattern =
        !state.containsPattern(current.movementPattern.name);

    if (candidateNewPattern != currentNewPattern) {
      return candidateNewPattern;
    }

    //-----------------------------------------------------------------------
    // Compound movements remain preferred after category coverage.
    //-----------------------------------------------------------------------

    if (candidate.isCompound != current.isCompound) {
      return candidate.isCompound;
    }

    //-----------------------------------------------------------------------
    // More focused primary targets.
    //-----------------------------------------------------------------------

    if (candidate.targetMuscles.length != current.targetMuscles.length) {
      return candidate.targetMuscles.length > current.targetMuscles.length;
    }

    //-----------------------------------------------------------------------
    // More secondary coverage.
    //-----------------------------------------------------------------------

    if (candidate.secondaryMuscles.length != current.secondaryMuscles.length) {
      return candidate.secondaryMuscles.length >
          current.secondaryMuscles.length;
    }

    return _random.nextBool();
  }

  //===========================================================================
  // Candidate Pool
  //===========================================================================

  /// Builds the candidate pool used by the greedy selector.
  ///
  /// Sources:
  ///
  /// • User equipment
  /// • Bodyweight fallback
  ///
  /// Rules:
  ///
  /// • remove duplicates
  /// • preserve only one instance per exercise name
  /// • filter by experience
  /// • shuffle once for natural tie variation
  List<ExercisePoolEntry> _buildCandidatePool({
    required MuscleSplit split,
    required WorkoutPreferences training,
    List<MuscleGroup>? excludeMuscles,
    required ExperienceLevel experience,
  }) {
    //-----------------------------------------------------------------------
    // Requested equipment
    //-----------------------------------------------------------------------

    final requestedPool = ExercisePool.getExercises(
      splitName: split.name,
      allowedEquipment: training.equipment,
      excludeMuscles: excludeMuscles,
    );

    //-----------------------------------------------------------------------
    // Bodyweight fallback
    //
    // Bodyweight remains available as a fallback even when the user has
    // additional equipment.
    //-----------------------------------------------------------------------

    final bodyweightPool = ExercisePool.getExercises(
      splitName: split.name,
      allowedEquipment: const [
        EquipmentType.bodyweight,
      ],
      excludeMuscles: excludeMuscles,
    );

    //-----------------------------------------------------------------------
    // Merge without duplicates
    //-----------------------------------------------------------------------

    final merged = <String, ExercisePoolEntry>{};

    for (final exercise in requestedPool) {
      merged[exercise.name] = exercise;
    }

    for (final exercise in bodyweightPool) {
      merged.putIfAbsent(
        exercise.name,
        () => exercise,
      );
    }

    //-----------------------------------------------------------------------
    // Filter by experience and split scope.
    //
    // The latter is defensive: the pool should already be scoped by split,
    // but this prevents unrelated exercises from leaking into the selector
    // when a future pool implementation becomes broader.
    //-----------------------------------------------------------------------

    final splitMuscles = split.muscles.toSet();

    final pool = merged.values
        .where(
          (exercise) => ProfileCoherence.isExerciseAppropriateForExperience(
            exercise: exercise,
            experience: experience,
          ),
        )
        .where(
          (exercise) => _belongsToSplit(
            exercise: exercise,
            splitMuscles: splitMuscles,
          ),
        )
        .toList();

    pool.shuffle(_random);

    return pool;
  }

  bool _belongsToSplit({
    required ExercisePoolEntry exercise,
    required Set<MuscleGroup> splitMuscles,
  }) {
    if (splitMuscles.isEmpty) {
      return false;
    }

    //-----------------------------------------------------------------------
    // Primary target must belong to the split.
    //-----------------------------------------------------------------------

    return exercise.targetMuscles.any(
      splitMuscles.contains,
    );
  }

  //===========================================================================
  // Previous Program
  //===========================================================================

  /// Collects every exercise already used in the previous generated program.
  ///
  /// ExerciseScorer applies only a soft penalty to these names, allowing reuse
  /// when no better alternative exists.
  Set<String> _previousExerciseNames(
    TrainingProgram? previousProgram,
  ) {
    if (previousProgram == null) {
      return {};
    }

    final names = <String>{};

    for (final exercises in previousProgram.weeklySchedule.values) {
      for (final exercise in exercises) {
        names.add(exercise.name);
      }
    }

    return names;
  }
}
