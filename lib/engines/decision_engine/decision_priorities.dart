/// Explicit Decision Engine priority policy (Phase 6).
///
/// Two layers:
/// 1. [domainEvaluationOrder] — rule evaluation order in DI / docs.
/// 2. [ConflictResolver] adjustment ranking — which [WorkoutAdjustment] wins.
///
/// Domain policy (highest → lowest influence on workout mutation):
/// Injury / Safety > Recovery > Deload / Progression > Equipment >
/// Progress / HealthPlatform (observe-only) > Nutrition (plan only).
class DecisionPriorities {
  const DecisionPriorities._();

  /// Human-readable domain priority list for docs and tests.
  static const List<String> domainEvaluationOrder = [
    'InjuryRule',
    'SafetyRule',
    'RecoveryRule',
    'DeloadRule',
    'ProgressionRule',
    'EquipmentRule',
    'ProgressRule', // observe-only
    'HealthPlatformRule', // observe-only
    'NutritionRule', // nutrition plan only
  ];

  /// Adjustment priority ranks used by [ConflictResolver] (higher wins).
  static const Map<String, int> adjustmentRanks = {
    'restDay': 100,
    'skipWorkout': 90,
    'recoverySession': 80,
    'deload': 70,
    'replaceExercise': 60,
    'reduceVolume': 50,
    'reduceIntensity': 40,
    'increaseVolume': 30,
    'increaseIntensity': 20,
    'none': 0,
  };
}
