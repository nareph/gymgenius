import 'package:gymgenius/domain/enums/program_phase.dart';

/// Calculates the training prescription for a given week.
///
/// This class never modifies exercises.
///
/// It only determines how hard the week should be.
///
/// Responsibilities:
///
/// • progression
/// • volume
/// • intensity
/// • RPE target
/// • deload indication
///
/// This is deterministic and completely offline.
class WeekProgressionCalculator {
  const WeekProgressionCalculator();

  WeekProgression calculate({
    required int currentWeek,
    required int durationWeeks,
    required ProgramPhase phase,
  }) {
    final progress = currentWeek / durationWeeks;

    switch (phase) {
      case ProgramPhase.base:
        return WeekProgression(
          phase: phase,
          volumeMultiplier: 1.00 + (progress * 0.15),
          intensityMultiplier: 1.00,
          targetRpe: 7.0,
          isDeload: false,
        );

      case ProgramPhase.intensification:
        return WeekProgression(
          phase: phase,
          volumeMultiplier: 0.95,
          intensityMultiplier: 1.10,
          targetRpe: 8.5,
          isDeload: false,
        );

      case ProgramPhase.realization:
        return WeekProgression(
          phase: phase,
          volumeMultiplier: 0.80,
          intensityMultiplier: 1.20,
          targetRpe: 9.0,
          isDeload: false,
        );
    }
  }
}

/// Immutable weekly prescription.
///
/// This object tells the Workout Engine how
/// the current week should behave.
class WeekProgression {
  final ProgramPhase phase;

  /// Multiplies total training volume.
  ///
  /// Example:
  ///
  /// 1.10 = +10%
  ///
  /// 0.80 = -20%
  final double volumeMultiplier;

  /// Multiplies target intensity.
  final double intensityMultiplier;

  /// Desired perceived effort.
  final double targetRpe;

  /// Future integration with DeloadPlanner.
  final bool isDeload;

  const WeekProgression({
    required this.phase,
    required this.volumeMultiplier,
    required this.intensityMultiplier,
    required this.targetRpe,
    required this.isDeload,
  });

  @override
  String toString() {
    return '''
WeekProgression(
  phase: $phase,
  volume: $volumeMultiplier,
  intensity: $intensityMultiplier,
  rpe: $targetRpe,
  deload: $isDeload
)
''';
  }
}
