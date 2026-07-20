/// Result of workout day frequency calculation.
class WorkoutDaysResult {
  final int count;
  final bool useSpecifiedDays;

  const WorkoutDaysResult({
    required this.count,
    required this.useSpecifiedDays,
  });
}
