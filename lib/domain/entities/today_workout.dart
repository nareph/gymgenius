import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/enums/decision_reason.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';

/// Represents the workout the user should actually perform today.
///
/// Unlike [TrainingProgram], this entity represents a temporary,
/// runtime-only version of today's session after the Decision Engine
/// has evaluated recovery, progression and other contextual signals.
///
/// The underlying TrainingProgram is never modified.
class TodayWorkout {
  /// Calendar date.
  final DateTime date;

  /// Day identifier ("monday", "tuesday", ...).
  final String dayKey;

  /// Workout originally planned by the Workout Engine.
  final List<Exercise> plannedExercises;

  /// Final workout after Decision Engine adaptations.
  final List<Exercise> finalExercises;

  /// Whether today's workout differs from the planned workout.
  final bool isAdapted;

  /// Applied adjustments.
  final List<WorkoutAdjustment> adjustments;

  /// Reasons explaining the decision.
  final List<DecisionReason> reasons;

  // ==========================================================
  // Runtime prescription
  //
  // These values NEVER modify TrainingProgram.
  // They only describe how today's workout should be executed.
  // ==========================================================

  /// Volume multiplier.
  ///
  /// Examples:
  ///
  /// 1.00 → unchanged
  ///
  /// 0.80 → reduce total volume by 20%
  ///
  /// 1.15 → increase volume by 15%
  final double volumeMultiplier;

  /// Intensity multiplier.
  ///
  /// Examples:
  ///
  /// 1.00 → unchanged
  ///
  /// 0.90 → reduce load by 10%
  ///
  /// 1.05 → increase load by 5%
  final double intensityMultiplier;

  /// Target RPE for today's workout.
  ///
  /// Null means "use the default prescription".
  final double? targetRpe;

  /// Suggested workout duration.
  ///
  /// Null means "use the original duration".
  final Duration? targetDuration;

  /// Whether today's workout is a recovery session.
  final bool isRecoverySession;

  /// Optional coach message.
  ///
  /// Examples:
  ///
  /// "Reduce rest periods today."
  ///
  /// "Focus on technique."
  ///
  /// "Avoid training to failure."
  final String? coachNote;

  const TodayWorkout({
    required this.date,
    required this.dayKey,
    required this.plannedExercises,
    required this.finalExercises,
    this.isAdapted = false,
    this.adjustments = const [],
    this.reasons = const [],
    this.volumeMultiplier = 1.0,
    this.intensityMultiplier = 1.0,
    this.targetRpe,
    this.targetDuration,
    this.isRecoverySession = false,
    this.coachNote,
  });

  bool get isRestDay => finalExercises.isEmpty;

  bool get hasExercises => finalExercises.isNotEmpty;

  int get plannedExerciseCount => plannedExercises.length;

  int get finalExerciseCount => finalExercises.length;

  bool get wasModified => isAdapted;

  TodayWorkout copyWith({
    DateTime? date,
    String? dayKey,
    List<Exercise>? plannedExercises,
    List<Exercise>? finalExercises,
    bool? isAdapted,
    List<WorkoutAdjustment>? adjustments,
    List<DecisionReason>? reasons,
    double? volumeMultiplier,
    double? intensityMultiplier,
    double? targetRpe,
    Duration? targetDuration,
    bool? isRecoverySession,
    String? coachNote,
  }) {
    return TodayWorkout(
      date: date ?? this.date,
      dayKey: dayKey ?? this.dayKey,
      plannedExercises: plannedExercises ?? this.plannedExercises,
      finalExercises: finalExercises ?? this.finalExercises,
      isAdapted: isAdapted ?? this.isAdapted,
      adjustments: adjustments ?? this.adjustments,
      reasons: reasons ?? this.reasons,
      volumeMultiplier: volumeMultiplier ?? this.volumeMultiplier,
      intensityMultiplier: intensityMultiplier ?? this.intensityMultiplier,
      targetRpe: targetRpe ?? this.targetRpe,
      targetDuration: targetDuration ?? this.targetDuration,
      isRecoverySession: isRecoverySession ?? this.isRecoverySession,
      coachNote: coachNote ?? this.coachNote,
    );
  }

  @override
  String toString() {
    return 'TodayWorkout('
        'day=$dayKey, '
        'planned=${plannedExercises.length}, '
        'final=${finalExercises.length}, '
        'volume=$volumeMultiplier, '
        'intensity=$intensityMultiplier, '
        'adapted=$isAdapted'
        ')';
  }
}
