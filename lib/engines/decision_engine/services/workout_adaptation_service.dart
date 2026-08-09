import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/today_workout.dart';
import 'package:gymgenius/domain/entities/workout_decision.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';

import 'deload_service.dart';
import 'exercise_substitution_service.dart';
import 'intensity_adjustment_service.dart';
import 'recovery_session_service.dart';
import 'volume_adjustment_service.dart';

/// Applies the decision produced by the Decision Engine.
///
/// This service is intentionally lightweight.
///
/// It never decides WHAT should happen.
/// It only delegates the requested adaptation to the specialized
/// adaptation services.
///
/// Decision:
///
/// WorkoutDecisionEvaluator
///         ↓
/// WorkoutAdaptationService
///         ↓
/// Specialized adaptation services
///         ↓
/// TodayWorkout
class WorkoutAdaptationService {
  final VolumeAdjustmentService _volumeService;
  final IntensityAdjustmentService _intensityService;
  final ExerciseSubstitutionService _exerciseService;
  final RecoverySessionService _recoveryService;
  final DeloadService _deloadService;

  const WorkoutAdaptationService({
    required VolumeAdjustmentService volumeAdjustmentService,
    required IntensityAdjustmentService intensityAdjustmentService,
    required ExerciseSubstitutionService exerciseSubstitutionService,
    required RecoverySessionService recoverySessionService,
    required DeloadService deloadService,
  })  : _volumeService = volumeAdjustmentService,
        _intensityService = intensityAdjustmentService,
        _exerciseService = exerciseSubstitutionService,
        _recoveryService = recoverySessionService,
        _deloadService = deloadService;

  TodayWorkout adapt({
    required TodayWorkout plannedWorkout,
    required WorkoutDecision decision,
    required HealthProfile profile,
  }) {
    final TodayWorkout adaptedWorkout;

    switch (decision.adjustment) {
      case WorkoutAdjustment.none:
        adaptedWorkout = plannedWorkout;

      case WorkoutAdjustment.reduceVolume:
        adaptedWorkout = _volumeService.reduceVolume(
          plannedWorkout,
        );

      case WorkoutAdjustment.increaseVolume:
        adaptedWorkout = _volumeService.increaseVolume(
          plannedWorkout,
        );

      case WorkoutAdjustment.reduceIntensity:
        adaptedWorkout = _intensityService.reduceIntensity(
          plannedWorkout,
        );

      case WorkoutAdjustment.increaseIntensity:
        adaptedWorkout = _intensityService.increaseIntensity(
          plannedWorkout,
        );

      case WorkoutAdjustment.replaceExercise:
        adaptedWorkout = _exerciseService.substituteExercises(
          plannedWorkout,
          profile,
        );

      case WorkoutAdjustment.recoverySession:
        adaptedWorkout = _recoveryService.createRecoverySession(
          plannedWorkout,
        );

      case WorkoutAdjustment.skipWorkout:
        adaptedWorkout = _recoveryService.restDay(
          plannedWorkout,
        );

      case WorkoutAdjustment.restDay:
        adaptedWorkout = _recoveryService.restDay(
          plannedWorkout,
        );

      case WorkoutAdjustment.deload:
        adaptedWorkout = _deloadService.apply(
          plannedWorkout,
          volumeMultiplier: decision.volumeMultiplier ?? 0.7,
        );
    }

    return adaptedWorkout.copyWith(
      isAdapted: decision.adjustment != WorkoutAdjustment.none,
      adjustments: [
        ...adaptedWorkout.adjustments,
        decision.adjustment,
      ],
      reasons: [
        ...adaptedWorkout.reasons,
        ...decision.reasons,
      ],
    );
  }
}
