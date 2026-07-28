import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/optimizers/program_optimizer.dart';
import 'package:gymgenius/core/logger/logger_service.dart';

/// Local optimizer that improves programs using deterministic rules.
///
/// This optimizer is always available and does not require any external API.
class LocalProgramOptimizer implements ProgramOptimizer {
  const LocalProgramOptimizer();

  static const _tag = 'LocalProgramOptimizer';

  /// Weekly set targets per muscle group, from the Workout Engine spec
  /// (§10 Volume Planning). Muscle groups not listed here (glutes,
  /// calves, abs_core, forearms, traps) have no spec'd range, so they're
  /// left untouched — adjusting toward an unspecified target would just
  /// be guessing.
  static const Map<MuscleGroup, (int min, int max)> _weeklyVolumeTargets = {
    MuscleGroup.chest: (12, 18),
    MuscleGroup.back: (14, 20),
    MuscleGroup.shoulders: (10, 16),
    MuscleGroup.quadriceps: (12, 18),
    MuscleGroup.hamstrings: (10, 14),
    MuscleGroup.biceps: (8, 14),
    MuscleGroup.triceps: (8, 14),
  };

  @override
  Future<TrainingProgram> optimize({
    required TrainingProgram program,
    required HealthProfile profile,
    Map<String, dynamic>? options,
  }) async {
    // 1. Reorder exercises: compound before isolation, heavy before light
    final reorderedSchedule = _reorderExercises(program.weeklySchedule);

    // 2. Diagnostic pass: flag days where one muscle dominates the split's
    // intended distribution (see method doc — this does not mutate,
    // rebalancing would require re-selecting exercises, which is
    // ExerciseSelector's job, not this optimizer's).
    _balanceMuscleGroups(reorderedSchedule);

    // 3. Nudge existing exercises' set counts toward the weekly volume
    // targets above, without adding/removing any exercise.
    final adjustedSchedule = _adjustVolume(reorderedSchedule, profile);

    return program.copyWith(weeklySchedule: adjustedSchedule);
  }

  @override
  bool get isAvailable => true;

  // ============================================================
  // Private methods
  // ============================================================

  Map<String, List<Exercise>> _reorderExercises(
    Map<String, List<Exercise>> schedule,
  ) {
    final result = <String, List<Exercise>>{};
    for (final entry in schedule.entries) {
      final exercises = entry.value;
      final compound = exercises.where((e) => e.isCompound).toList();
      final isolation = exercises.where((e) => e.isIsolation).toList();
      result[entry.key] = [...compound, ...isolation];
    }
    return result;
  }

  /// Logs (does not mutate) days where a single muscle group accounts for
  /// most of that day's total sets — e.g. a "Push" day that ended up
  /// almost entirely chest with little shoulder/triceps work. This is a
  /// diagnostic signal for you as the developer (or a future AI Coach
  /// reading logs/metrics), not an automatic fix: actually rebalancing
  /// would mean swapping an exercise for a different one, which requires
  /// ExercisePool access this optimizer intentionally doesn't have — it
  /// only rearranges/tunes exercises ExerciseSelector already chose.
  void _balanceMuscleGroups(Map<String, List<Exercise>> schedule) {
    for (final entry in schedule.entries) {
      final day = entry.key;
      final exercises = entry.value;
      if (exercises.isEmpty) continue;

      final setsByMuscle = <MuscleGroup, int>{};
      var totalSets = 0;
      for (final exercise in exercises) {
        for (final muscle in exercise.primaryMuscles) {
          setsByMuscle[muscle] = (setsByMuscle[muscle] ?? 0) + exercise.sets;
        }
        totalSets += exercise.sets;
      }
      if (totalSets == 0 || setsByMuscle.length <= 1) continue;

      final dominant =
          setsByMuscle.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final dominantShare = dominant.value / totalSets;

      if (dominantShare > 0.6) {
        Log.debug(
            '$day is skewed towards ${dominant.key.displayName} '
            '(${(dominantShare * 100).round()}% of the day\'s sets) — '
            'consider whether ExerciseSelector should diversify this split.',
            tag: _tag);
      }
    }
  }

  /// Nudges existing exercises' `sets` by ±1 to bring each muscle group's
  /// TOTAL weekly sets (summed across every day, counting an exercise
  /// toward each of its primary muscles) into the target range from
  /// `_weeklyVolumeTargets`. Never adds or removes an exercise, never
  /// touches timed (duration-based) exercises — "sets" isn't a
  /// meaningful volume lever for a plank hold the way it is for a
  /// weighted compound lift.
  Map<String, List<Exercise>> _adjustVolume(
    Map<String, List<Exercise>> schedule,
    HealthProfile profile,
  ) {
    final weeklySets = <MuscleGroup, int>{};
    for (final exercises in schedule.values) {
      for (final exercise in exercises) {
        for (final muscle in exercise.primaryMuscles) {
          weeklySets[muscle] = (weeklySets[muscle] ?? 0) + exercise.sets;
        }
      }
    }

    // Positive = needs more weekly sets, negative = needs fewer.
    final remaining = <MuscleGroup, int>{};
    _weeklyVolumeTargets.forEach((muscle, range) {
      final (min, max) = range;
      final current = weeklySets[muscle] ?? 0;
      if (current < min) {
        remaining[muscle] = min - current;
      } else if (current > max) {
        remaining[muscle] = max - current;
      }
    });

    if (remaining.isEmpty) return schedule;

    final result = <String, List<Exercise>>{};

    for (final entry in schedule.entries) {
      result[entry.key] = entry.value.map((exercise) {
        if (exercise.isTimed) return exercise;

        for (final muscle in exercise.primaryMuscles) {
          final need = remaining[muscle];
          if (need == null || need == 0) continue;

          final delta = need > 0 ? 1 : -1;
          final newSets = (exercise.sets + delta).clamp(1, 6);
          if (newSets == exercise.sets) continue; // hit the clamp bound

          remaining[muscle] = need - delta;
          return exercise.copyWith(sets: newSets);
        }
        return exercise;
      }).toList();
    }

    final unresolved = remaining.entries.where((e) => e.value != 0).toList();
    if (unresolved.isNotEmpty) {
      Log.debug(
          'Could not fully close weekly volume gap for: '
          '${unresolved.map((e) => '${e.key.displayName} (${e.value > 0 ? '+' : ''}${e.value} sets)').join(', ')} '
          '— would require adding/removing an exercise, which stays '
          'ExerciseSelector\'s responsibility, not this optimizer\'s.',
          tag: _tag);
    }

    return result;
  }
}
