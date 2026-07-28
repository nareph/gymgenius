import 'dart:math';

import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/domain/value_objects/workout_preferences.dart';
import 'package:gymgenius/engines/workout_engine/models/muscle_split.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercises/exercise_pool.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// Mutable accumulator threaded through every pass — tracks what's been
/// picked so far so later passes never re-add or duplicate an exercise.
class _SelectionState {
  final List<ExercisePoolEntry> selected = [];
  final Set<String> usedNames = {};
  final Set<String> usedPatterns = {};

  //bool get isFull => false; // replaced per-call against desiredCount
}

/// Selects exercises for a workout day from the local exercise pool.
///
/// Never gives up before `desiredCount` is reached as long as the pool
/// has enough distinct exercises somewhere across the passes below.
/// Progressively more permissive:
///
/// 1. Requested equipment, unused vs previousProgram, pattern variety.
/// 2. Requested equipment, unused vs previousProgram, patterns may repeat.
/// 3. Bodyweight fallback, unused vs previousProgram, pattern variety.
/// 4. Bodyweight fallback, unused vs previousProgram, patterns may repeat.
/// 5. Final fallback: reuse exercises from previousProgram if still short.
///
/// Guarantees `selected.length == desiredCount` unless the combined
/// requested-equipment + bodyweight pool for this split genuinely has
/// fewer than `desiredCount` distinct exercises in total — a real pool
/// content limit, not a selection bug.
class ExerciseSelector {
  ExerciseSelector({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<ExercisePoolEntry> select({
    required MuscleSplit split,
    required HealthProfile profile,
    required int desiredCount,
    TrainingProgram? previousProgram,
    List<MuscleGroup>? excludeMuscles,
  }) {
    final training = profile.training;
    final previousNames = _previousExerciseNames(previousProgram);

    final requestedPool = ExercisePool.getExercises(
      splitName: split.name,
      allowedEquipment: training.equipment,
      focusMuscles: training.focusAreas,
      excludeMuscles: excludeMuscles,
    );

    final bodyweightPool = _bodyweightPool(
      split: split,
      training: training,
      excludeMuscles: excludeMuscles,
    );

    final state = _SelectionState();

    _firstPass(requestedPool, previousNames, desiredCount, state);
    _secondPass(requestedPool, previousNames, desiredCount, state);
    _thirdPassBodyweight(bodyweightPool, previousNames, desiredCount, state);
    _fourthPassBodyweight(bodyweightPool, previousNames, desiredCount, state);
    _finalFallback(requestedPool, bodyweightPool, desiredCount, state);

    return state.selected;
  }

  // ------------------------------------------------------------------
  // Passes
  // ------------------------------------------------------------------

  /// PASS 1: requested equipment, not in previousProgram, pattern variety.
  void _firstPass(
    List<ExercisePoolEntry> pool,
    Set<String> previousNames,
    int desiredCount,
    _SelectionState state,
  ) {
    _addExercises(
      pool: pool,
      desiredCount: desiredCount,
      state: state,
      excludeNames: previousNames,
      enforceVariety: true,
    );
  }

  /// PASS 2: requested equipment, not in previousProgram, patterns may repeat.
  void _secondPass(
    List<ExercisePoolEntry> pool,
    Set<String> previousNames,
    int desiredCount,
    _SelectionState state,
  ) {
    _addExercises(
      pool: pool,
      desiredCount: desiredCount,
      state: state,
      excludeNames: previousNames,
      enforceVariety: false,
    );
  }

  /// PASS 3: bodyweight fallback, not in previousProgram, pattern variety.
  void _thirdPassBodyweight(
    List<ExercisePoolEntry> pool,
    Set<String> previousNames,
    int desiredCount,
    _SelectionState state,
  ) {
    _addExercises(
      pool: pool,
      desiredCount: desiredCount,
      state: state,
      excludeNames: previousNames,
      enforceVariety: true,
    );
  }

  /// PASS 4: bodyweight fallback, not in previousProgram, patterns may repeat.
  void _fourthPassBodyweight(
    List<ExercisePoolEntry> pool,
    Set<String> previousNames,
    int desiredCount,
    _SelectionState state,
  ) {
    _addExercises(
      pool: pool,
      desiredCount: desiredCount,
      state: state,
      excludeNames: previousNames,
      enforceVariety: false,
    );
  }

  /// PASS 5: last resort — allow reusing previousProgram exercises, from
  /// the combined requested-equipment + bodyweight pool.
  void _finalFallback(
    List<ExercisePoolEntry> requestedPool,
    List<ExercisePoolEntry> bodyweightPool,
    int desiredCount,
    _SelectionState state,
  ) {
    if (state.selected.length >= desiredCount) return;

    final combined = <String, ExercisePoolEntry>{};
    for (final entry in [...requestedPool, ...bodyweightPool]) {
      combined[entry.name] = entry;
    }

    _addExercises(
      pool: combined.values.toList(),
      desiredCount: desiredCount,
      state: state,
      excludeNames: const {},
      enforceVariety: false,
    );
  }

  // ------------------------------------------------------------------
  // Shared pass logic
  // ------------------------------------------------------------------

  void _addExercises({
    required List<ExercisePoolEntry> pool,
    required int desiredCount,
    required _SelectionState state,
    required Set<String> excludeNames,
    required bool enforceVariety,
  }) {
    if (state.selected.length >= desiredCount || pool.isEmpty) return;

    for (final entry in _shuffle(pool)) {
      if (state.selected.length >= desiredCount) break;
      if (state.usedNames.contains(entry.name)) continue;
      if (excludeNames.contains(entry.name)) continue;

      final pattern = entry.movementPattern.name;
      if (enforceVariety && state.usedPatterns.contains(pattern)) continue;

      state.selected.add(entry);
      state.usedNames.add(entry.name);
      state.usedPatterns.add(pattern);
    }
  }

  List<ExercisePoolEntry> _shuffle(List<ExercisePoolEntry> pool) {
    return List<ExercisePoolEntry>.from(pool)..shuffle(_random);
  }

  List<ExercisePoolEntry> _bodyweightPool({
    required MuscleSplit split,
    required WorkoutPreferences training,
    List<MuscleGroup>? excludeMuscles,
  }) {
    return ExercisePool.getExercises(
      splitName: split.name,
      allowedEquipment: const [EquipmentType.bodyweight],
      focusMuscles: training.focusAreas,
      excludeMuscles: excludeMuscles,
    );
  }

  Set<String> _previousExerciseNames(TrainingProgram? previousProgram) {
    if (previousProgram == null) return {};

    final names = <String>{};
    for (final exercises in previousProgram.weeklySchedule.values) {
      for (final exercise in exercises) {
        names.add(exercise.name);
      }
    }
    return names;
  }
}
