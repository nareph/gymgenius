import 'package:gymgenius/domain/entities/today_workout.dart';

/// Converts today's workout into a recovery session.
///
/// Later this may generate:
///
/// • stretching
/// • mobility
/// • walking
/// • yoga
/// • foam rolling
class RecoverySessionService {
  const RecoverySessionService();

  TodayWorkout createRecoverySession(
    TodayWorkout workout,
  ) {
    return workout.copyWith(
      finalExercises: const [],
      isAdapted: true,
    );
  }

  TodayWorkout restDay(
    TodayWorkout workout,
  ) {
    return workout.copyWith(
      finalExercises: const [],
      isAdapted: true,
    );
  }
}
