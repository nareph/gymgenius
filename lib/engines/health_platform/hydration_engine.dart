import 'package:gymgenius/domain/entities/hydration_log.dart';

class HydrationDayStatus {
  final int targetMl;
  final int totalMl;
  final int percent;
  final List<String> reasons;

  const HydrationDayStatus({
    required this.targetMl,
    required this.totalMl,
    required this.percent,
    this.reasons = const [],
  });
}

/// Deterministic hydration target and daily totals.
class HydrationEngine {
  static const int defaultTargetMl = 2000;
  static const int minTargetMl = 1500;
  static const int maxTargetMl = 4000;

  /// ~30 ml per kg body weight, clamped; training day +300 ml.
  const HydrationEngine();

  int targetMl({
    double? weightKg,
    bool isTrainingDay = false,
  }) {
    var target = defaultTargetMl;
    if (weightKg != null && weightKg > 0) {
      target = (weightKg * 30).round();
    }
    if (isTrainingDay) target += 300;
    return target.clamp(minTargetMl, maxTargetMl);
  }

  HydrationDayStatus summarize({
    required List<HydrationLog> logs,
    double? weightKg,
    bool isTrainingDay = false,
  }) {
    final target = targetMl(weightKg: weightKg, isTrainingDay: isTrainingDay);
    final total = logs.fold<int>(0, (sum, e) => sum + e.amountMl);
    final percent = target == 0 ? 0 : ((total / target) * 100).round().clamp(0, 200);
    final reasons = <String>[];
    if (weightKg != null && weightKg > 0) {
      reasons.add('Target derived from body weight (~30 ml/kg)');
    } else {
      reasons.add('Default hydration target applied');
    }
    if (isTrainingDay) reasons.add('Training day: +300 ml');
    if (percent < 50) {
      reasons.add('Hydration below half of today\'s target');
    } else if (percent >= 100) {
      reasons.add('Hydration target reached');
    }
    return HydrationDayStatus(
      targetMl: target,
      totalMl: total,
      percent: percent,
      reasons: reasons,
    );
  }
}
