import 'package:gymgenius/domain/entities/today_workout.dart';

/// Handles intensity modifications.
///
/// For now exercises remain unchanged.
/// Later this service will modify:
///
/// • target RPE
/// • target load
/// • percentage of 1RM
class IntensityAdjustmentService {
  const IntensityAdjustmentService();

  TodayWorkout reduceIntensity(
    TodayWorkout workout,
  ) {
    return workout.copyWith(
      isAdapted: true,
    );
  }

  TodayWorkout increaseIntensity(
    TodayWorkout workout,
  ) {
    return workout.copyWith(
      isAdapted: true,
    );
  }
}
