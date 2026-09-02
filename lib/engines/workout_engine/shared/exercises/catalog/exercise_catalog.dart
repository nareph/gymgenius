import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

import 'definitions/arms_exercises.dart';
import 'definitions/back_exercises.dart';
import 'definitions/chest_exercises.dart';
import 'definitions/core_exercises.dart';
import 'definitions/legs_exercises.dart';
import 'definitions/shoulders_exercises.dart';

/// Canonical exercise catalog.
///
/// This is the single source of truth for exercise definitions.
///
/// Each exercise exists only once, identified by its stable [ExercisePoolEntry.id].
/// Applicability to different splits is stored in [ExercisePoolEntry.compatibleSplits].
class ExerciseCatalog {
  ExerciseCatalog._();

  static List<ExercisePoolEntry>? _cachedExercises;
  static Map<String, ExercisePoolEntry>? _cachedById;

  /// Returns all canonical exercises.
  ///
  /// The catalog is deduplicated by stable exercise ID.
  /// The result is cached after the first call.
  static List<ExercisePoolEntry> getAll() {
    final cached = _cachedExercises;
    if (cached != null) {
      return cached;
    }

    final all = <String, ExercisePoolEntry>{};

    void addAll(List<ExercisePoolEntry> entries) {
      for (final entry in entries) {
        all[entry.id] = entry;
      }
    }

    addAll(chestDefinitions);
    addAll(backDefinitions);
    addAll(shouldersDefinitions);
    addAll(armsDefinitions);
    addAll(legsDefinitions);
    addAll(coreDefinitions);

    final result = List<ExercisePoolEntry>.unmodifiable(
      all.values,
    );

    _cachedExercises = result;
    _cachedById = Map<String, ExercisePoolEntry>.unmodifiable(
      all,
    );

    return result;
  }

  /// Finds a canonical exercise by its stable ID.
  static ExercisePoolEntry? findById(String id) {
    if (_cachedById == null) {
      getAll();
    }

    return _cachedById?[id];
  }

  /// Finds all canonical exercises matching [predicate].
  static List<ExercisePoolEntry> where(
    bool Function(ExercisePoolEntry entry) predicate,
  ) {
    return getAll().where(predicate).toList();
  }

  /// Returns the number of canonical exercises.
  static int get length => getAll().length;
}
