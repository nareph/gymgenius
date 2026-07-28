/// A single logged set within an exercise during a workout session.
class LoggedSet {
  final int setNumber;
  final int reps;
  final double weightKg;
  final DateTime loggedAt;

  const LoggedSet({
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    required this.loggedAt,
  });

  LoggedSet copyWith({
    int? setNumber,
    int? reps,
    double? weightKg,
    DateTime? loggedAt,
  }) {
    return LoggedSet(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LoggedSet &&
        other.setNumber == setNumber &&
        other.reps == reps &&
        other.weightKg == weightKg &&
        other.loggedAt == loggedAt;
  }

  @override
  int get hashCode => Object.hash(setNumber, reps, weightKg, loggedAt);

  @override
  String toString() => 'LoggedSet($setNumber: ${reps}reps @ ${weightKg}kg)';
}
