/// Machine-readable reasons explaining why the Decision Engine
/// produced a particular decision.
///
/// These values are never shown directly to the user.
/// They are intended for:
///
/// • Explainable AI
/// • Analytics
/// • Debugging
/// • Logging
/// • Future localization
///
/// The presentation layer or AI Coach will later translate these
/// reasons into user-friendly explanations.
enum DecisionReason {
  // ============================================================
  // Default
  // ============================================================

  /// Execute the workout exactly as planned.
  scheduledWorkout,

  // ============================================================
  // Recovery
  // ============================================================

  /// Recovery indicators are excellent.
  goodRecovery,

  /// Recovery indicators are below target.
  lowRecovery,

  /// General fatigue is too high.
  highFatigue,

  /// Fatigue exceeded the acceptable threshold.
  fatigueTooHigh,

  /// Muscle soreness is significant.
  muscleSoreness,

  /// A recovery-focused day is recommended.
  recoveryRequired,

  // ============================================================
  // Progression
  // ============================================================

  /// Planned deload week.
  deloadWeek,

  /// Program is currently in the realization phase.
  realizationPhase,

  /// Normal progression week.
  progressionWeek,

  /// Training plateau detected.
  plateauDetected,

  // ============================================================
  // Workout adaptation
  // ============================================================

  /// Exercises were substituted.
  exerciseSubstitution,

  /// Equipment availability changed.
  equipmentChanged,

  // ============================================================
  // User / Profile
  // ============================================================

  /// User goal changed.
  goalChanged,

  /// Medical restriction detected.
  medicalRestriction,

  // ============================================================
  // Program lifecycle
  // ============================================================

  /// Program duration has finished.
  programExpired,

  /// User manually requested regeneration.
  manualRegeneration,
}

extension DecisionReasonExtension on DecisionReason {
  String get value {
    switch (this) {
      case DecisionReason.scheduledWorkout:
        return 'scheduled_workout';

      case DecisionReason.goodRecovery:
        return 'good_recovery';

      case DecisionReason.lowRecovery:
        return 'low_recovery';

      case DecisionReason.highFatigue:
        return 'high_fatigue';

      case DecisionReason.fatigueTooHigh:
        return 'fatigue_too_high';

      case DecisionReason.muscleSoreness:
        return 'muscle_soreness';

      case DecisionReason.recoveryRequired:
        return 'recovery_required';

      case DecisionReason.deloadWeek:
        return 'deload_week';

      case DecisionReason.realizationPhase:
        return 'realization_phase';

      case DecisionReason.progressionWeek:
        return 'progression_week';

      case DecisionReason.plateauDetected:
        return 'plateau_detected';

      case DecisionReason.exerciseSubstitution:
        return 'exercise_substitution';

      case DecisionReason.equipmentChanged:
        return 'equipment_changed';

      case DecisionReason.goalChanged:
        return 'goal_changed';

      case DecisionReason.medicalRestriction:
        return 'medical_restriction';

      case DecisionReason.programExpired:
        return 'program_expired';

      case DecisionReason.manualRegeneration:
        return 'manual_regeneration';
    }
  }

  String get displayName {
    switch (this) {
      case DecisionReason.scheduledWorkout:
        return 'Scheduled workout';
      case DecisionReason.goodRecovery:
        return 'Good recovery';
      case DecisionReason.lowRecovery:
        return 'Low recovery';
      case DecisionReason.highFatigue:
        return 'High fatigue';
      case DecisionReason.fatigueTooHigh:
        return 'Fatigue too high';
      case DecisionReason.muscleSoreness:
        return 'Muscle soreness';
      case DecisionReason.recoveryRequired:
        return 'Recovery required';
      case DecisionReason.deloadWeek:
        return 'Deload week';
      case DecisionReason.realizationPhase:
        return 'Realization phase';
      case DecisionReason.progressionWeek:
        return 'Progression week';
      case DecisionReason.plateauDetected:
        return 'Plateau detected';
      case DecisionReason.exerciseSubstitution:
        return 'Exercise substitution';
      case DecisionReason.equipmentChanged:
        return 'Equipment changed';
      case DecisionReason.goalChanged:
        return 'Goal changed';
      case DecisionReason.medicalRestriction:
        return 'Medical restriction';
      case DecisionReason.programExpired:
        return 'Program expired';
      case DecisionReason.manualRegeneration:
        return 'Manual regeneration';
    }
  }

  static DecisionReason fromValue(String value) {
    return DecisionReason.values.firstWhere(
      (reason) => reason.value == value,
      orElse: () => DecisionReason.scheduledWorkout,
    );
  }
}
