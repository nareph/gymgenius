import 'package:gymgenius/domain/entities/today_workout.dart';

/// Applies deload-specific adaptations.
///
/// This is intentionally separated from generic volume/intensity
/// adjustments because a deload usually combines several modifications.
class DeloadService {
  const DeloadService();

  /// [volumeMultiplier] comes from `DeloadPlan.volumeMultiplier`
  /// (0.60-0.75 depending on the current training phase) — previously
  /// this method hardcoded 0.7 regardless of phase, so every deload
  /// week behaved identically no matter where it fell in the program.
  TodayWorkout apply(
    TodayWorkout workout, {
    required double volumeMultiplier,
  }) {
    final exercises = workout.finalExercises;

    if (exercises.length <= 2) {
      return workout.copyWith(isAdapted: true);
    }

    final keep =
        (exercises.length * volumeMultiplier).ceil().clamp(2, exercises.length);

    return workout.copyWith(
      finalExercises: exercises.take(keep).toList(),
      isAdapted: true,
    );
  }
}
