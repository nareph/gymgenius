import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/engines/workout_engine/builders/exercise_builder.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercises/exercise_pool.dart';

/// Provides equivalent exercises compatible with the user's
/// current equipment.
///
/// The Decision Engine never accesses ExercisePool directly.
///
/// Today this provider is backed by the local ExercisePool.
///
/// Future versions may retrieve alternatives from:
///
/// • AI recommendation engine
/// • cloud exercise database
/// • biomechanical similarity engine
/// • personalized exercise ranking
class ExerciseReplacementProvider {
  const ExerciseReplacementProvider();

  /// Returns a compatible replacement for [exercise].
  ///
  /// Returns null if no suitable alternative exists.
  Exercise? findReplacement({
    required Exercise exercise,
    required HealthProfile profile,
    Set<String> excludeNames = const {},
  }) {
    final equipment = profile.training.equipment;

    // Already compatible with the user's equipment.
    if (equipment.contains(exercise.equipment)) {
      return exercise;
    }

    final alternative = ExercisePool.findAlternative(
      targetMuscles: exercise.primaryMuscles,
      allowedEquipment: equipment,
      excludeNames: excludeNames,
    );

    if (alternative == null) {
      return null;
    }

    return const ExerciseBuilder().build(
      entry: alternative,
      profile: profile,
    );
  }
}
