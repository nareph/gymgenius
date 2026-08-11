/// Single source of truth for Progress Engine thresholds (Phase 5).
class ProgressThresholds {
  const ProgressThresholds._();

  // ── Weight ────────────────────────────────────────────────────────────────

  static const int minWeightDataPoints = 3;
  static const double maxDailyWeightChangeKg = 2.0;
  static const double stableWeightChangeKgPerWeek = 0.3;
  static const double weightPlateauMinDays = 14;
  static const double weightPlateauMaxChangeKg = 0.2;

  // ── Strength ──────────────────────────────────────────────────────────────

  static const int minStrengthSessions = 2;
  static const int strengthPlateauSessions = 3;
  static const double strengthProgressThresholdPercent = 2.0;
  static const int maxTrackedExercises = 5;

  // Epley formula: estimated1Rm = weight * (1 + reps / 30)
  static double estimated1Rm(double weightKg, int reps) {
    if (weightKg <= 0 || reps <= 0) return 0;
    return weightKg * (1 + reps / 30);
  }

  // ── Consistency ───────────────────────────────────────────────────────────

  static const int minPlannedWorkouts = 1;
  static const double irregularWeekCompletionRate = 0.5;
}
