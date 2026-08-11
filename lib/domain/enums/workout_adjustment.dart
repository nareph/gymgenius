/// Possible adjustments that the Decision Engine can apply to
/// today's workout.
///
/// These adjustments never modify the TrainingProgram itself.
/// They only affect the TodayWorkout generated for the current day.
enum WorkoutAdjustment {
  /// No modification.
  none,

  /// Reduce training volume.
  reduceVolume,

  /// Increase training volume.
  increaseVolume,

  /// Reduce intensity.
  reduceIntensity,

  /// Increase intensity.
  increaseIntensity,

  /// Replace one or more exercises.
  replaceExercise,

  /// Convert the workout into a recovery session.
  recoverySession,

  /// Skip today's workout.
  skipWorkout,

  /// Replace the workout by a complete rest day.
  restDay,

  /// Deload week — a dedicated, combined adjustment (currently volume
  /// only, via DeloadPlan.volumeMultiplier; may later also touch
  /// intensity/rest). Kept distinct from `reduceVolume` because a
  /// deload is planned periodization, not a reactive reduction, and
  /// may eventually combine several modifications at once (see
  /// DeloadService doc comment).
  deload,
}

extension WorkoutAdjustmentExtension on WorkoutAdjustment {
  String get value {
    switch (this) {
      case WorkoutAdjustment.none:
        return 'none';
      case WorkoutAdjustment.reduceVolume:
        return 'reduce_volume';
      case WorkoutAdjustment.increaseVolume:
        return 'increase_volume';
      case WorkoutAdjustment.reduceIntensity:
        return 'reduce_intensity';
      case WorkoutAdjustment.increaseIntensity:
        return 'increase_intensity';
      case WorkoutAdjustment.replaceExercise:
        return 'replace_exercise';
      case WorkoutAdjustment.recoverySession:
        return 'recovery_session';
      case WorkoutAdjustment.skipWorkout:
        return 'skip_workout';
      case WorkoutAdjustment.restDay:
        return 'rest_day';
      case WorkoutAdjustment.deload:
        return 'deload';
    }
  }

  String get displayName {
    switch (this) {
      case WorkoutAdjustment.none:
        return 'No change';
      case WorkoutAdjustment.reduceVolume:
        return 'Reduced volume';
      case WorkoutAdjustment.increaseVolume:
        return 'Increased volume';
      case WorkoutAdjustment.reduceIntensity:
        return 'Reduced intensity';
      case WorkoutAdjustment.increaseIntensity:
        return 'Increased intensity';
      case WorkoutAdjustment.replaceExercise:
        return 'Exercise replaced';
      case WorkoutAdjustment.recoverySession:
        return 'Recovery session';
      case WorkoutAdjustment.skipWorkout:
        return 'Skip workout';
      case WorkoutAdjustment.restDay:
        return 'Rest day';
      case WorkoutAdjustment.deload:
        return 'Deload';
    }
  }

  static WorkoutAdjustment fromValue(String value) {
    return WorkoutAdjustment.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WorkoutAdjustment.none,
    );
  }
}
