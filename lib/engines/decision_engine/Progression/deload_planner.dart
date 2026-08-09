import 'package:gymgenius/domain/enums/program_phase.dart';

/// Determines whether the current training week
/// should be a deload week.
///
/// This planner is deterministic.
///
/// It does NOT modify:
///
/// - exercises
/// - sets
/// - reps
///
/// It only returns a recommendation that will later
/// be applied by the progression engine.
class DeloadPlanner {
  const DeloadPlanner();

  DeloadPlan calculate({
    required int currentWeek,
    required int durationWeeks,
    required ProgramPhase phase,
  }) {
    // Last week of every mesocycle
    final isDeloadWeek = currentWeek % 4 == 0;

    if (!isDeloadWeek) {
      return const DeloadPlan.none();
    }

    switch (phase) {
      case ProgramPhase.base:
        return const DeloadPlan(
          isDeload: true,
          volumeMultiplier: 0.75,
          intensityMultiplier: 0.90,
        );

      case ProgramPhase.intensification:
        return const DeloadPlan(
          isDeload: true,
          volumeMultiplier: 0.65,
          intensityMultiplier: 0.85,
        );

      case ProgramPhase.realization:
        return const DeloadPlan(
          isDeload: true,
          volumeMultiplier: 0.60,
          intensityMultiplier: 0.80,
        );
    }
  }
}

/// Immutable value object describing
/// the deload prescription.
class DeloadPlan {
  final bool isDeload;

  /// Training volume multiplier.
  ///
  /// Example:
  ///
  /// 0.75 = reduce total volume by 25%.
  final double volumeMultiplier;

  /// Training intensity multiplier.
  ///
  /// Example:
  ///
  /// 0.90 = reduce working weight by 10%.
  final double intensityMultiplier;

  const DeloadPlan({
    required this.isDeload,
    required this.volumeMultiplier,
    required this.intensityMultiplier,
  });

  const DeloadPlan.none()
      : isDeload = false,
        volumeMultiplier = 1.0,
        intensityMultiplier = 1.0;

  @override
  String toString() {
    return '''
DeloadPlan(
  isDeload: $isDeload,
  volume: $volumeMultiplier,
  intensity: $intensityMultiplier
)
''';
  }

  @override
  bool operator ==(Object other) {
    return other is DeloadPlan &&
        other.isDeload == isDeload &&
        other.volumeMultiplier == volumeMultiplier &&
        other.intensityMultiplier == intensityMultiplier;
  }

  @override
  int get hashCode => Object.hash(
        isDeload,
        volumeMultiplier,
        intensityMultiplier,
      );
}
