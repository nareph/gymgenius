import 'package:gymgenius/domain/entities/today_workout.dart';

/// Applies a volume reduction or increase.
///
/// This service never decides WHEN to change volume.
/// It only knows HOW to modify today's workout.
class VolumeAdjustmentService {
  const VolumeAdjustmentService();

  TodayWorkout reduceVolume(
    TodayWorkout workout,
  ) {
    final exercises = workout.finalExercises;

    if (exercises.length <= 2) {
      return workout;
    }

    final keep = (exercises.length * 0.7).ceil().clamp(2, exercises.length);

    return workout.copyWith(
      finalExercises: exercises.take(keep).toList(),
      isAdapted: true,
    );
  }

  TodayWorkout increaseVolume(
    TodayWorkout workout,
  ) {
    // Future:
    // Add accessory work.

    return workout.copyWith(
      isAdapted: true,
    );
  }
}
