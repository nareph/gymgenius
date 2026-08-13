import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

import 'splits/exports.dart';

/// Central repository of exercises, aggregated from individual split files.
///
/// IMPORTANT distinction between the three filters below:
///
/// - [allowedEquipment] and [excludeMuscles] are HARD constraints.
/// - [focusMuscles] is a SOFT preference — biases sort order, never
///   excludes (a strict filter here previously caused entire training
///   days to come back EMPTY whenever the requested focus didn't
///   overlap with that split's inherent target muscles).

class ExercisePool {
  ExercisePool._();

  static List<ExercisePoolEntry> getExercises({
    required String splitName,
    required List<EquipmentType> allowedEquipment,
    List<MuscleGroup>? focusMuscles,
    List<MuscleGroup>? excludeMuscles,
  }) {
    final pool = _exercisePools[splitName] ?? _exercisePools['Push']!;

    var filtered = pool
        .where((entry) => allowedEquipment.contains(entry.equipmentType))
        .toList();

    if (excludeMuscles != null && excludeMuscles.isNotEmpty) {
      filtered = filtered
          .where((entry) =>
              !entry.targetMuscles.any((m) => excludeMuscles.contains(m)))
          .toList();
    }

    if (focusMuscles != null && focusMuscles.isNotEmpty) {
      filtered.sort((a, b) {
        final scoreA =
            a.targetMuscles.where((m) => focusMuscles.contains(m)).length;
        final scoreB =
            b.targetMuscles.where((m) => focusMuscles.contains(m)).length;
        return scoreB.compareTo(scoreA);
      });
    }

    return filtered;
  }

  static ExercisePoolEntry? findByName(
    String name, {
    required List<EquipmentType> allowedEquipment,
  }) {
    final normalized = name.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    for (final entries in _exercisePools.values) {
      for (final entry in entries) {
        if (entry.name.toLowerCase() == normalized &&
            allowedEquipment.contains(entry.equipmentType)) {
          return entry;
        }
      }
    }
    return null;
  }

  static ExercisePoolEntry? findAlternative({
    required List<MuscleGroup> targetMuscles,
    required List<EquipmentType> allowedEquipment,
    Set<String> excludeNames = const {},
    List<MuscleGroup> excludeMuscles = const [],
  }) {
    ExercisePoolEntry? bestCandidate;
    var bestScore = -1;

    for (final entries in _exercisePools.values) {
      for (final entry in entries) {
        if (!allowedEquipment.contains(entry.equipmentType)) continue;
        if (excludeNames.contains(entry.name)) continue;
        if (excludeMuscles.isNotEmpty &&
            entry.targetMuscles.any(excludeMuscles.contains)) {
          continue;
        }

        final score = entry.targetMuscles.where(targetMuscles.contains).length;
        if (score == 0) continue;

        if (score > bestScore) {
          bestScore = score;
          bestCandidate = entry;
        }
      }
    }

    return bestCandidate;
  }

  // ============================================================
  // Combined pools
  // ============================================================

  /// Pool for the 'Shoulders & Core' split – combines shoulder + core.
  static final List<ExercisePoolEntry> _shouldersAndCoreExercises =
      _dedupeByName([
    ...shouldersExercises,
    ...coreExercises,
  ]);

  /// 'Full Body' split composition.
  static final List<ExercisePoolEntry> _fullBodyExercises = _dedupeByName([
    ...pushExercises,
    ...pullExercises,
    ...legsExercises,
    ...shouldersExercises,
    ...coreExercises,
  ]);

  static List<ExercisePoolEntry> _dedupeByName(
    List<ExercisePoolEntry> entries,
  ) {
    final seenNames = <String>{};
    final result = <ExercisePoolEntry>[];
    for (final entry in entries) {
      if (seenNames.add(entry.name)) {
        result.add(entry);
      }
    }
    return result;
  }

  // ============================================================
  // Main mapping
  // ============================================================

  static final Map<String, List<ExercisePoolEntry>> _exercisePools = {
    'Push': pushExercises,
    'Pull': pullExercises,
    'Legs': legsExercises,
    'Chest': chestExercises,
    'Back': backExercises,
    'Arms': armsExercises,
    'Chest & Triceps': chestTricepsExercises,
    'Back & Biceps': backBicepsExercises,
    'Shoulders & Core': _shouldersAndCoreExercises,
    'Upper Body': upperBodyExercises,
    'Lower Body': lowerBodyExercises,
    'Full Body': _fullBodyExercises,
  };
}
