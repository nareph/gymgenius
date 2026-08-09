import 'package:gymgenius/domain/enums/decision_reason.dart';
import 'package:gymgenius/domain/enums/workout_adjustment.dart';

/// Immutable decision produced by the Decision Engine.
///
/// This object never contains exercises.
/// It only describes how today's workout should be adapted.
class WorkoutDecision {
  final bool requiresAdaptation;
  final WorkoutAdjustment adjustment;
  final List<DecisionReason> reasons;
  final double confidence;

  /// Only populated for adjustments that need a numeric magnitude
  /// (currently: `deload`). Deliberately kept as plain doubles rather
  /// than importing DeloadPlan here, so WorkoutDecision stays decoupled
  /// from the progression model layer — the adaptation services only
  /// need a number, not where it came from.
  final double? volumeMultiplier;
  final double? intensityMultiplier;

  const WorkoutDecision({
    required this.requiresAdaptation,
    required this.adjustment,
    required this.reasons,
    required this.confidence,
    this.volumeMultiplier,
    this.intensityMultiplier,
  });

  // ----------------------------------------------------------
  // No adaptation
  // ----------------------------------------------------------

  factory WorkoutDecision.keepPlannedWorkout({
    double confidence = 1.0,
  }) {
    return WorkoutDecision(
      requiresAdaptation: false,
      adjustment: WorkoutAdjustment.none,
      reasons: const [DecisionReason.scheduledWorkout],
      confidence: confidence,
    );
  }

  // ----------------------------------------------------------
  // Deload — carries the real per-phase multipliers from DeloadPlan,
  // instead of the generic reduceVolume path guessing a fixed ratio.
  // ----------------------------------------------------------

  factory WorkoutDecision.deload({
    required double volumeMultiplier,
    required double intensityMultiplier,
    double confidence = 1.0,
  }) {
    return WorkoutDecision(
      requiresAdaptation: true,
      adjustment: WorkoutAdjustment.deload,
      reasons: const [DecisionReason.deloadWeek],
      confidence: confidence,
      volumeMultiplier: volumeMultiplier,
      intensityMultiplier: intensityMultiplier,
    );
  }

  // ----------------------------------------------------------
  // Reduce volume
  // ----------------------------------------------------------

  factory WorkoutDecision.reduceVolume({
    double confidence = 1.0,
  }) {
    return WorkoutDecision(
      requiresAdaptation: true,
      adjustment: WorkoutAdjustment.reduceVolume,
      reasons: const [DecisionReason.deloadWeek],
      confidence: confidence,
    );
  }

  // ----------------------------------------------------------
  // Reduce intensity
  // ----------------------------------------------------------

  factory WorkoutDecision.reduceIntensity({
    double confidence = 1.0,
  }) {
    return WorkoutDecision(
      requiresAdaptation: true,
      adjustment: WorkoutAdjustment.reduceIntensity,
      reasons: const [DecisionReason.recoveryRequired],
      confidence: confidence,
    );
  }

  // ----------------------------------------------------------
  // Recovery session
  // ----------------------------------------------------------

  factory WorkoutDecision.recoverySession({
    double confidence = 1.0,
  }) {
    return WorkoutDecision(
      requiresAdaptation: true,
      adjustment: WorkoutAdjustment.recoverySession,
      reasons: const [DecisionReason.recoveryRequired],
      confidence: confidence,
    );
  }

  // ----------------------------------------------------------
  // Rest day
  // ----------------------------------------------------------

  factory WorkoutDecision.restDay({
    double confidence = 1.0,
  }) {
    return WorkoutDecision(
      requiresAdaptation: true,
      adjustment: WorkoutAdjustment.restDay,
      reasons: const [DecisionReason.fatigueTooHigh],
      confidence: confidence,
    );
  }

  // ----------------------------------------------------------
  // Replace exercises
  // ----------------------------------------------------------

  factory WorkoutDecision.replaceExercises({
    double confidence = 1.0,
  }) {
    return WorkoutDecision(
      requiresAdaptation: true,
      adjustment: WorkoutAdjustment.replaceExercise,
      reasons: const [DecisionReason.exerciseSubstitution],
      confidence: confidence,
    );
  }

  WorkoutDecision copyWith({
    bool? requiresAdaptation,
    WorkoutAdjustment? adjustment,
    List<DecisionReason>? reasons,
    double? confidence,
    double? volumeMultiplier,
    double? intensityMultiplier,
  }) {
    return WorkoutDecision(
      requiresAdaptation: requiresAdaptation ?? this.requiresAdaptation,
      adjustment: adjustment ?? this.adjustment,
      reasons: reasons ?? this.reasons,
      confidence: confidence ?? this.confidence,
      volumeMultiplier: volumeMultiplier ?? this.volumeMultiplier,
      intensityMultiplier: intensityMultiplier ?? this.intensityMultiplier,
    );
  }

  @override
  String toString() {
    return '''
WorkoutDecision(
  adaptation: $requiresAdaptation,
  adjustment: $adjustment,
  confidence: $confidence,
  reasons: $reasons
)
''';
  }
}
