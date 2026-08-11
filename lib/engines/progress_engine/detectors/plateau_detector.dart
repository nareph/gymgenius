import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/strength_progress.dart';
import 'package:gymgenius/domain/entities/weight_trend.dart';
import 'package:gymgenius/engines/progress_engine/progress_thresholds.dart';

/// Detects weight and strength plateaus from computed trends.
class PlateauDetector {
  const PlateauDetector();

  bool detectWeightPlateau({
    required List<DailyCheckIn> checkIns,
    required WeightTrend? trend,
    required DateTime to,
  }) {
    if (trend == null || !trend.hasSufficientData) return false;

    final cutoff = to.subtract(
      Duration(days: ProgressThresholds.weightPlateauMinDays.round()),
    );

    final recent = checkIns
        .where((c) => c.isWeightLogged)
        .where((c) => !_dayKey(c.date).isBefore(_dayKey(cutoff)))
        .where((c) => !_dayKey(c.date).isAfter(_dayKey(to)))
        .map((c) => c.weightKg)
        .toList();

    if (recent.length < ProgressThresholds.minWeightDataPoints) return false;

    final minW = recent.reduce((a, b) => a < b ? a : b);
    final maxW = recent.reduce((a, b) => a > b ? a : b);

    return (maxW - minW) <= ProgressThresholds.weightPlateauMaxChangeKg;
  }

  bool detectStrengthPlateau(StrengthProgress? strength) {
    if (strength == null || !strength.hasSufficientData) return false;
    return strength.plateauDetected;
  }

  DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);
}
