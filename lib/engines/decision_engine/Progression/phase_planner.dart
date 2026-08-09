import 'package:gymgenius/domain/enums/program_phase.dart';

/// Determines the current training phase based on the
/// current week of the program.
///
/// This class is intentionally deterministic.
///
/// It does NOT calculate:
///
/// - sets
/// - reps
/// - intensity
/// - deload volume
///
/// Those responsibilities belong to other progression components.
///
/// The planner only answers:
///
/// "Which phase is active during this week?"
class PhasePlanner {
  const PhasePlanner();

  /// Returns the phase for the given week.
  ///
  /// Example for an 8-week program:
  ///
  /// Week 1-3 → Base
  ///
  /// Week 4-6 → Intensification
  ///
  /// Week 7-8 → Realization
  ProgramPhase phaseForWeek({
    required int currentWeek,
    required int durationWeeks,
  }) {
    if (durationWeeks <= 0) {
      throw ArgumentError.value(
        durationWeeks,
        'durationWeeks',
        'Program duration must be greater than zero.',
      );
    }

    final week = currentWeek.clamp(1, durationWeeks);

    final progress = week / durationWeeks;

    // -----------------------------
    // BASE
    // -----------------------------
    if (progress <= 0.40) {
      return ProgramPhase.base;
    }

    // -----------------------------
    // INTENSIFICATION
    // -----------------------------
    if (progress <= 0.80) {
      return ProgramPhase.intensification;
    }

    // -----------------------------
    // REALIZATION
    // -----------------------------
    return ProgramPhase.realization;
  }
}
