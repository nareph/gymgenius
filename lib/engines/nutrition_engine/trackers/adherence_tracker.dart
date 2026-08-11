/// Minimal adherence tracker placeholder for Phase 3.
///
/// Full logging UI arrives in a later milestone.
class AdherenceTracker {
  const AdherenceTracker();

  /// Placeholder score until meal logging exists.
  double placeholderScore() => 0.0;

  /// Estimates adherence from logged vs target calories when available.
  double scoreFromCalories({
    required int targetCalories,
    required int loggedCalories,
  }) {
    if (targetCalories <= 0) return 0;
    final ratio = loggedCalories / targetCalories;
    if (ratio >= 0.9 && ratio <= 1.1) return 1.0;
    if (ratio >= 0.8 && ratio <= 1.2) return 0.7;
    if (ratio >= 0.7 && ratio <= 1.3) return 0.4;
    return 0.2;
  }
}
