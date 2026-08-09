import 'package:gymgenius/domain/enums/program_phase.dart';
import 'package:gymgenius/engines/decision_engine/Progression/deload_planner.dart';
import 'package:gymgenius/engines/decision_engine/Progression/mesocycle_planner.dart';
import 'package:gymgenius/engines/decision_engine/Progression/week_progression_calculator.dart';

/// Immutable snapshot describing the current state of a TrainingProgram.
///
/// Unlike TrainingProgram (which represents the strategy),
/// ProgramProgress represents the current temporal state.
///
/// It is recomputed every day by ProgramProgressService.
///
/// Future Decision Engine rules should depend on this object rather
/// than recalculating progression information.
class ProgramProgress {
  final int currentWeek;

  final int totalWeeks;

  final ProgramPhase currentPhase;

  final MesocycleInfo mesocycleInfo;

  final WeekProgression weekProgression;

  final DeloadPlan deloadPlan;

  final int weeksRemaining;

  /// Between 0 and 1.
  final double completion;

  const ProgramProgress({
    required this.currentWeek,
    required this.totalWeeks,
    required this.currentPhase,
    required this.mesocycleInfo,
    required this.weekProgression,
    required this.deloadPlan,
    required this.weeksRemaining,
    required this.completion,
  });

  bool get isDeloadWeek => deloadPlan.isDeload;

  int get currentMesocycle => mesocycleInfo.mesocycle;

  int get currentMicrocycle => mesocycleInfo.microcycle;

  @override
  String toString() {
    return '''
ProgramProgress(

  week: $currentWeek/$totalWeeks,

  phase: $currentPhase,

  mesocycle: ${mesocycleInfo.mesocycle},

  microcycle: ${mesocycleInfo.microcycle},

  deload: ${deloadPlan.isDeload},

  completion: ${(completion * 100).toStringAsFixed(1)}%

)
''';
  }
}
