import 'dart:math';

import 'package:gymgenius/core/logger/logger_service.dart';
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
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercises/exercise_pool.dart';
import 'package:gymgenius/engines/workout_engine/shared/profile_coherence.dart';

/// Selects exercises for one workout day.
///
/// The selector works exclusively with canonical [ExercisePoolEntry] objects
/// coming from [ExercisePool].
///
/// Responsibilities:
/// - respect split applicability
/// - respect allowed equipment
/// - respect avoided muscles
/// - prioritize user focus areas
/// - avoid duplicates within a workout
/// - avoid duplicates across the same week when possible
/// - use bodyweight as a fallback when the preferred equipment pool is too
///   small
class ExerciseSelector {
  ExerciseSelector({
    Random? random,
    ExerciseScorer? scorer,
  })  : _random = random ?? Random(),
        _scorer = scorer ?? const ExerciseScorer();

  final Random _random;
  final ExerciseScorer _scorer;
  final FocusQuotaPlanner _quotaPlanner = const FocusQuotaPlanner();

  //===========================================================================
  // Public API
  //===========================================================================

  /// Selects up to [desiredCount] exercises for the given [split].
  ///
  /// [weeklyUsedExerciseIds] contains canonical exercise IDs already selected
  /// on previous days of the same week.
  ///
  /// Weekly duplicates are avoided whenever another suitable candidate exists.
  List<ExercisePoolEntry> select({
    required MuscleSplit split,
    required HealthProfile profile,
    required int desiredCount,
    TrainingProgram? previousProgram,
    List<MuscleGroup>? excludeMuscles,
    Set<String> weeklyUsedExerciseIds = const {},
  }) {
    if (desiredCount <= 0) {
      return const [];
    }

    final training = profile.training;

    final previousNames = _previousExerciseNames(
      previousProgram,
    );

    final resolvedExcludedMuscles = ProfileCoherence.resolveAvoidedMuscles(
      profileAvoided: training.avoidedMuscles,
      extra: excludeMuscles,
    );

    final candidatePool = _buildCandidatePool(
      split: split,
      training: training,
      excludeMuscles: resolvedExcludedMuscles,
      experience: training.experience,
      desiredCount: desiredCount,
      weeklyUsedExerciseIds: weeklyUsedExerciseIds,
    );

    if (candidatePool.isEmpty) {
      return const [];
    }

    final focusMuscles = ProfileCoherence.resolveFocusAreas(
      goal: training.goal,
      userFocusAreas: training.focusAreas,
    );

    final FocusPlan focusPlan = _quotaPlanner.buildPlan(
      split: split,
      focusMuscles: focusMuscles,
      desiredExerciseCount: desiredCount,
    );

    final splitCoverageQuotas = _buildSplitCoverageQuotas(
      split: split,
      candidatePool: candidatePool,
      desiredCount: desiredCount,
    );

    final state = SelectionState();

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

    for (final entry in pool) {
      // Canonical ID is the primary identity key.
      if (state.containsExerciseId(entry.id)) {
        continue;
      }

      final baseScore = _scorer.score(
        entry: entry,
        state: state,
        split: split,
        focusPlan: focusPlan,
        previousNames: previousNames,
      );

      final coverageBonus = missingSplitMuscles.isEmpty
          ? 0
          : _splitCoverageBonus(
              entry: entry,
              missingMuscles: missingSplitMuscles,
            );

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

  Map<MuscleGroup, int> _buildSplitCoverageQuotas({
    required MuscleSplit split,
    required List<ExercisePoolEntry> candidatePool,
    required int desiredCount,
  }) {
    final availableMuscles = <MuscleGroup>[];

    for (final muscle in split.muscles) {
      final available = candidatePool.any(
        (entry) => entry.targetMuscles.contains(muscle),
      );

      if (available) {
        availableMuscles.add(muscle);
      }
    }

    if (availableMuscles.isEmpty || desiredCount <= 0) {
      return const {};
    }

    final targetMuscleCount = min(
      availableMuscles.length,
      desiredCount,
    );

    final quotas = <MuscleGroup, int>{};

    // Initial one-per-muscle coverage.
    for (var i = 0; i < targetMuscleCount; i++) {
      quotas[availableMuscles[i]] = 1;
    }

    // Balanced distribution of remaining exercise slots.
    var remaining = desiredCount - targetMuscleCount;
    var index = 0;

    while (remaining > 0 && quotas.isNotEmpty) {
      final muscle = availableMuscles[index % targetMuscleCount];

      quotas[muscle] = quotas[muscle]! + 1;

      remaining--;
      index++;
    }

    return quotas;
  }

  List<MuscleGroup> _missingSplitMuscles({
    required SelectionState state,
    required Map<MuscleGroup, int> splitCoverageQuotas,
  }) {
    final missing = <MuscleGroup>[];

    for (final entry in splitCoverageQuotas.entries) {
      final current = state.coverageCount(
        entry.key,
      );

      if (current < entry.value) {
        missing.add(entry.key);
      }
    }

    return missing;
  }

  int _splitCoverageBonus({
    required ExercisePoolEntry entry,
    required List<MuscleGroup> missingMuscles,
  }) {
    final coveredMissing =
        entry.targetMuscles.where(missingMuscles.contains).length;

    if (coveredMissing == 0) {
      return 0;
    }

    return coveredMissing * 500;
  }

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

    final candidateNewPattern = !state.containsPattern(
      candidate.movementPattern.name,
    );

    final currentNewPattern = !state.containsPattern(
      current.movementPattern.name,
    );

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

    return _random.nextBool();
  }

  //===========================================================================
  // Candidate pool
  //===========================================================================

  /// Builds the candidate pool for the given split.
  ///
  /// Selection priority:
  ///
  /// 1. Equipment explicitly available in the user's profile.
  /// 2. If that pool is too small, bodyweight exercises are added as a
  ///    universal fallback.
  ///
  /// Bodyweight is therefore always available as a fallback, but it does not
  /// unnecessarily dilute a sufficiently large preferred-equipment pool.
  List<ExercisePoolEntry> _buildCandidatePool({
    required MuscleSplit split,
    required WorkoutPreferences training,
    required ExperienceLevel experience,
    required int desiredCount,
    List<MuscleGroup>? excludeMuscles,
    Set<String> weeklyUsedExerciseIds = const {},
  }) {
    // -----------------------------------------------------------------------
    // 1. Preferred equipment pool
    // -----------------------------------------------------------------------

    final requestedPool = ExercisePool.getExercises(
      splitName: split.name,
      allowedEquipment: training.equipment,
      excludeMuscles: excludeMuscles,
      split: split,
    );

    final merged = <String, ExercisePoolEntry>{};

    for (final exercise in requestedPool) {
      merged[exercise.id] = exercise;
    }

    // -----------------------------------------------------------------------
    // 2. Bodyweight fallback
    //
    // Bodyweight is treated as universally available equipment.
    // It is added only when the user's preferred equipment pool is too small.
    // -----------------------------------------------------------------------

    if (merged.length < desiredCount) {
      final bodyweightPool = ExercisePool.getExercises(
        splitName: split.name,
        allowedEquipment: const [
          EquipmentType.bodyweight,
        ],
        excludeMuscles: excludeMuscles,
        split: split,
      );

      for (final exercise in bodyweightPool) {
        merged.putIfAbsent(
          exercise.id,
          () => exercise,
        );
      }
    }

    // -----------------------------------------------------------------------
    // 3. Filter by experience level
    // -----------------------------------------------------------------------

    var pool = merged.values
        .where(
          (exercise) => ProfileCoherence.isExerciseAppropriateForExperience(
            exercise: exercise,
            experience: experience,
          ),
        )
        .toList();

    if (pool.isEmpty) {
      return const [];
    }

    // -----------------------------------------------------------------------
    // 4. Prefer unused exercises from the current week
    //
    // This applies the weekly uniqueness constraint after equipment and
    // experience filtering.
    // -----------------------------------------------------------------------

    if (weeklyUsedExerciseIds.isNotEmpty) {
      final filtered = pool
          .where(
            (exercise) => !weeklyUsedExerciseIds.contains(
              exercise.id,
            ),
          )
          .toList();

      if (filtered.isNotEmpty) {
        pool = filtered;
      } else {
        Log.debug(
          'All suitable exercises are already used this week. '
          'Allowing weekly repeats for this workout.',
          tag: 'ExerciseSelector',
        );
      }
    }

    // -----------------------------------------------------------------------
    // 5. Shuffle before scoring
    // -----------------------------------------------------------------------

    pool.shuffle(
      _random,
    );

    return pool;
  }

  //===========================================================================
  // Previous program
  //===========================================================================

  /// Returns the set of exercise names from the previous program.
  ///
  /// ExerciseScorer uses these names to penalize exercises that were already
  /// used in the previous program.
  Set<String> _previousExerciseNames(
    TrainingProgram? previousProgram,
  ) {
    if (previousProgram == null) {
      return {};
    }

    final names = <String>{};

    for (final exercises in previousProgram.weeklySchedule.values) {
      for (final exercise in exercises) {
        names.add(
          exercise.name,
        );
      }
    }

    return names;
  }
}
