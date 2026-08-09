/// Calculates the current mesocycle and microcycle
/// of a training program.
///
/// This planner is deterministic and independent of
/// exercise generation.
///
/// Example (8-week program):
///
/// Weeks 1-4
///   Mesocycle 1
///      Week1 -> Microcycle 1
///      Week2 -> Microcycle 2
///      Week3 -> Microcycle 3
///      Week4 -> Microcycle 4
///
/// Weeks 5-8
///   Mesocycle 2
///      Week5 -> Microcycle 1
///      Week6 -> Microcycle 2
///      Week7 -> Microcycle 3
///      Week8 -> Microcycle 4
class MesocyclePlanner {
  const MesocyclePlanner({
    this.defaultMesocycleLength = 4,
  });

  /// Default length of one mesocycle.
  ///
  /// Can later become configurable depending on:
  ///
  /// - Goal
  /// - Experience
  /// - Sport
  final int defaultMesocycleLength;

  /// Returns the current mesocycle number.
  ///
  /// Example:
  ///
  /// Week 1 -> 1
  /// Week 4 -> 1
  /// Week 5 -> 2
  /// Week 8 -> 2
  /// Week 9 -> 3
  int mesocycleForWeek({
    required int currentWeek,
  }) {
    final week = currentWeek < 1 ? 1 : currentWeek;

    return ((week - 1) ~/ defaultMesocycleLength) + 1;
  }

  /// Returns the current microcycle inside the
  /// active mesocycle.
  ///
  /// Example:
  ///
  /// Week 5
  /// -> Mesocycle 2
  /// -> Microcycle 1
  int microcycleForWeek({
    required int currentWeek,
  }) {
    final week = currentWeek < 1 ? 1 : currentWeek;

    return ((week - 1) % defaultMesocycleLength) + 1;
  }

  /// Returns both values together.
  MesocycleInfo calculate({
    required int currentWeek,
  }) {
    return MesocycleInfo(
      mesocycle: mesocycleForWeek(
        currentWeek: currentWeek,
      ),
      microcycle: microcycleForWeek(
        currentWeek: currentWeek,
      ),
    );
  }
}

/// Immutable value object describing
/// the current training cycle.
class MesocycleInfo {
  final int mesocycle;
  final int microcycle;

  const MesocycleInfo({
    required this.mesocycle,
    required this.microcycle,
  });

  @override
  String toString() {
    return 'MesocycleInfo('
        'mesocycle: $mesocycle, '
        'microcycle: $microcycle'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return other is MesocycleInfo &&
        other.mesocycle == mesocycle &&
        other.microcycle == microcycle;
  }

  @override
  int get hashCode => Object.hash(
        mesocycle,
        microcycle,
      );
}
