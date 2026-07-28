import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

import 'splits/exports.dart';

/// Central repository of exercises, aggregated from individual split files.
class ExercisePool {
  ExercisePool._();

  /// Returns the exercise entries for the given split, filtered by allowed
  /// equipment, optionally excluding entries that target any muscle in
  /// [excludeMuscles], and optionally sorted by relevance to
  /// [focusMuscles].
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

  /// Searches EVERY split's pool for an exercise named [name]
  /// (case-insensitive, trimmed), restricted to [allowedEquipment].
  ///
  /// Used to validate exercise names suggested by an AI optimizer against
  /// the real local catalog before trusting them: a suggested name not
  /// found here (wrong name, hallucinated exercise, or requires equipment
  /// the user doesn't have) is treated as unavailable and the caller
  /// should ignore it rather than fabricate an Exercise from AI text
  /// alone. Returns the first match found (split search order is
  /// unspecified — fine here since only equipment + a valid name matter).
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

  static final Map<String, List<ExercisePoolEntry>> _exercisePools = {
    'Push': pushExercises,
    'Pull': pullExercises,
    'Legs': legsExercises,
    'Chest': chestExercises,
    'Back': backExercises,
    'Arms': armsExercises,
    'Chest & Triceps': chestTricepsExercises,
    'Back & Biceps': backBicepsExercises,
    'Shoulders & Core': shouldersCoreExercises,
    'Upper Body': upperBodyExercises,
    'Lower Body': lowerBodyExercises,
  };
}
