import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/engines/recovery_engine/recovery_thresholds.dart';

/// Applies a volume reduction or increase.
///
/// This service never decides WHEN to change volume.
/// It only knows HOW to modify today's workout.
///
/// Phase 4 recovery path reduces **sets per exercise** using the exact
/// [volumeMultiplier] from [WorkoutDecision] / RecoveryEngine.
/// The original planned exercises list is preserved; only [finalExercises]
/// are adapted, and each exercise keeps at least
/// [RecoveryThresholds.minSetsPerExercise] set.
class VolumeAdjustmentService {
  const VolumeAdjustmentService();

  TodayWorkout reduceVolume(
    TodayWorkout workout, {
    double volumeMultiplier = 0.7,
  }) {
    final clamped = volumeMultiplier.clamp(
      RecoveryThresholds.significantReduction,
      RecoveryThresholds.fullVolume,
    );

    if (clamped >= RecoveryThresholds.fullVolume) {
      return workout;
    }

    final adapted = workout.finalExercises.map((exercise) {
      final reduced = (exercise.sets * clamped)
          .round()
          .clamp(RecoveryThresholds.minSetsPerExercise, exercise.sets);
      return exercise.copyWith(sets: reduced);
    }).toList();

    return workout.copyWith(
      finalExercises: adapted,
      isAdapted: true,
      volumeMultiplier: clamped,
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
