import 'package:gymgenius/domain/enums/program_phase.dart';

/// Represents the current progression state of a TrainingProgram.
///
/// This object is **computed**, never persisted.
///
/// It answers questions such as:
/// - Which week is the user currently in?
/// - Which mesocycle?
/// - Which microcycle?
/// - Which program phase?
/// - Is this a deload week?
///
/// It is intended to be produced by ProgramProgressService and consumed
/// by the Decision Engine.
class ProgramProgress {
  /// Current week since the program started (1-based).
  final int currentWeek;

  /// Total number of weeks in the program.
  final int totalWeeks;

  /// Current mesocycle number (1-based).
  final int currentMesocycle;

  /// Current microcycle number within the mesocycle (1-based).
  final int currentMicrocycle;

  /// Current phase of the program.
  final ProgramPhase currentPhase;

  /// Whether the current week is a planned deload week.
  final bool isDeloadWeek;

  /// Weeks remaining until program completion.
  final int weeksRemaining;

  /// Completion percentage (0.0 → 1.0).
  final double completion;

  const ProgramProgress({
    required this.currentWeek,
    required this.totalWeeks,
    required this.currentMesocycle,
    required this.currentMicrocycle,
    required this.currentPhase,
    required this.isDeloadWeek,
    required this.weeksRemaining,
    required this.completion,
  });

  bool get isCompleted => currentWeek > totalWeeks;

  @override
  String toString() {
    return 'ProgramProgress('
        'week: $currentWeek/$totalWeeks, '
        'phase: ${currentPhase.name}, '
        'mesocycle: $currentMesocycle, '
        'microcycle: $currentMicrocycle, '
        'deload: $isDeloadWeek'
        ')';
  }
}
