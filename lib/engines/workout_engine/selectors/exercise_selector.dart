import 'dart:math';

import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';

import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/experience_level.dart';
import 'package:gymgenius/domain/enums/fitness_goal.dart';
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
/// Intelligent greedy selector.
///
/// Pipeline
///
/// 1.
/// Build candidate pool
///
///      - requested equipment
///      - bodyweight fallback
///      - deduplicate
///
/// 2.
/// Build a FocusPlan
///
///      - primary muscles
///      - secondary muscles
///      - quotas
///      - specialization ratio
///
/// 3.
/// Greedy selection
///
///      while workout not complete
///
///          score every remaining candidate
///
///          pick best candidate
///
///          update selection state
///
/// 4.
/// return selected exercises
///
///
/// Every decision is delegated to:
///
/// • FocusQuotaPlanner
///
/// • ExerciseScorer
///
/// • SelectionState
///
/// making ExerciseSelector only responsible for orchestration.
class ExerciseSelector {
  ExerciseSelector({
    Random? random,
    ExerciseScorer? scorer,
  })  : _random = random ?? Random(),
        _scorer = scorer ?? const ExerciseScorer();

  //---------------------------------------------------------------------------
  // Dependencies
  //---------------------------------------------------------------------------

  final Random _random;

  final ExerciseScorer _scorer;

  final FocusQuotaPlanner _quotaPlanner = const FocusQuotaPlanner();

  //---------------------------------------------------------------------------
  // Public API
  //---------------------------------------------------------------------------

  List<ExercisePoolEntry> select({
    required MuscleSplit split,
    required HealthProfile profile,
    required int desiredCount,
    TrainingProgram? previousProgram,
    List<MuscleGroup>? excludeMuscles,
  }) {
    final training = profile.training;

    //----------------------------------------------------------
    // Previous program
    //----------------------------------------------------------

    final previousNames = _previousExerciseNames(previousProgram);

    //----------------------------------------------------------
    // Candidate pool
    //----------------------------------------------------------

    final candidatePool = _buildCandidatePool(
      split: split,
      training: training,
      excludeMuscles: ProfileCoherence.resolveAvoidedMuscles(
        profileAvoided: training.avoidedMuscles,
        extra: excludeMuscles,
      ),
      experience: training.experience,
    );

    //----------------------------------------------------------
    // Focus plan
    //----------------------------------------------------------

    final focusMuscles = ProfileCoherence.resolveFocusAreas(
      goal: training.goal,
      userFocusAreas: training.focusAreas,
    );

    final FocusPlan focusPlan = _quotaPlanner.buildPlan(
      split: split,
      focusMuscles: focusMuscles,
      desiredExerciseCount: desiredCount,
    );

    //----------------------------------------------------------
    // Mutable state
    //----------------------------------------------------------

    final state = SelectionState();

    //----------------------------------------------------------
    // Greedy selection
    //----------------------------------------------------------

    while (!state.isComplete(desiredCount)) {
      final SelectionCandidate? candidate = _scorer.bestCandidate(
        pool: candidatePool,
        split: split,
        state: state,
        focusPlan: focusPlan,
        previousNames: previousNames,
      );

      //--------------------------------------------------------
      // Pool exhausted
      //--------------------------------------------------------

      if (candidate == null) {
        break;
      }

      //--------------------------------------------------------
      // Register exercise
      //--------------------------------------------------------

      state.add(candidate.entry);
    }

    //----------------------------------------------------------
    // Finished
    //----------------------------------------------------------

    return state.selected;
  }
  //----------------------------------------------------------------------------
  // Candidate Pool
  //----------------------------------------------------------------------------

  /// Builds the candidate pool used by the greedy selector.
  ///
  /// The pool is intentionally larger than the final workout.
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
  /// • shuffle once so tie-breaks vary naturally
  List<ExercisePoolEntry> _buildCandidatePool({
    required MuscleSplit split,
    required WorkoutPreferences training,
    List<MuscleGroup>? excludeMuscles,
    required ExperienceLevel experience,
  }) {
    //----------------------------------------------------------
    // Requested equipment
    //----------------------------------------------------------

    final requestedPool = ExercisePool.getExercises(
      splitName: split.name,
      allowedEquipment: training.equipment,
      excludeMuscles: excludeMuscles,
    );

    //----------------------------------------------------------
    // Bodyweight fallback
    //----------------------------------------------------------

    final bodyweightPool = ExercisePool.getExercises(
      splitName: split.name,
      allowedEquipment: const [
        EquipmentType.bodyweight,
      ],
      excludeMuscles: excludeMuscles,
    );

    //----------------------------------------------------------
    // Merge without duplicates
    //----------------------------------------------------------

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

    //----------------------------------------------------------
    // Shuffle
    //----------------------------------------------------------

    final pool = merged.values
        .where(
          (exercise) => ProfileCoherence.isExerciseAppropriateForExperience(
            exercise: exercise,
            experience: experience,
          ),
        )
        .toList();

    pool.shuffle(_random);

    return pool;
  }

  //----------------------------------------------------------------------------
  // Previous Program
  //----------------------------------------------------------------------------

  /// Collects every exercise already used in the previous generated
  /// program.
  ///
  /// ExerciseScorer applies only a soft penalty to these names,
  /// allowing reuse only when no better alternative exists.
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
