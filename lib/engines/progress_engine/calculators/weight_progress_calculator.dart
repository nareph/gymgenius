import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/weight_trend.dart';
import 'package:gymgenius/domain/enums/trend_direction.dart';
import 'package:gymgenius/engines/progress_engine/progress_thresholds.dart';

/// Computes body-weight trends from daily check-in weight entries.
class WeightProgressCalculator {
  const WeightProgressCalculator();

  WeightTrend? calculate({
    required List<DailyCheckIn> checkIns,
    required DateTime from,
    required DateTime to,
    double? targetWeightKg,
  }) {
    final points = _extractWeightPoints(checkIns, from, to);
    if (points.isEmpty) {
      return const WeightTrend(
        currentWeightKg: null,
        weeklyAverageKg: null,
        changeKg: null,
        direction: TrendDirection.insufficientData,
        distanceToTargetKg: null,
        dataPointCount: 0,
      );
    }

    final filtered = _filterOutliers(points);
    if (filtered.length < ProgressThresholds.minWeightDataPoints) {
      return WeightTrend(
        currentWeightKg: filtered.isNotEmpty ? filtered.last.weight : null,
        weeklyAverageKg: null,
        changeKg: null,
        direction: TrendDirection.insufficientData,
        distanceToTargetKg:
            _distanceToTarget(filtered.last.weight, targetWeightKg),
        dataPointCount: filtered.length,
      );
    }

    final current = filtered.last.weight;
    final weeklyAverage = _weeklyAverage(filtered, to);
    final changeKg = filtered.last.weight - filtered.first.weight;
    final direction = _direction(filtered, changeKg);
    final distance = _distanceToTarget(current, targetWeightKg);

    return WeightTrend(
      currentWeightKg: current,
      weeklyAverageKg: weeklyAverage,
      changeKg: changeKg,
      direction: direction,
      distanceToTargetKg: distance,
      dataPointCount: filtered.length,
    );
  }

  List<_WeightPoint> _extractWeightPoints(
    List<DailyCheckIn> checkIns,
    DateTime from,
    DateTime to,
  ) {
    final fromDay = _dayKey(from);
    final toDay = _dayKey(to);

    final points = checkIns
        .where((c) => c.isWeightLogged)
        .where((c) {
          final day = _dayKey(c.date);
          return !day.isBefore(fromDay) && !day.isAfter(toDay);
        })
        .map((c) => _WeightPoint(_dayKey(c.date), c.weightKg))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Deduplicate by day — keep latest entry for each calendar day.
    final byDay = <DateTime, _WeightPoint>{};
    for (final p in points) {
      byDay[p.date] = p;
    }
    return byDay.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  List<_WeightPoint> _filterOutliers(List<_WeightPoint> points) {
    if (points.length < 2) return points;

    final filtered = <_WeightPoint>[points.first];
    for (var i = 1; i < points.length; i++) {
      final prev = filtered.last.weight;
      final current = points[i].weight;
      if ((current - prev).abs() <= ProgressThresholds.maxDailyWeightChangeKg) {
        filtered.add(points[i]);
      }
    }
    return filtered;
  }

  double? _weeklyAverage(List<_WeightPoint> points, DateTime to) {
    final weekStart = _dayKey(to).subtract(const Duration(days: 6));
    final weekPoints =
        points.where((p) => !p.date.isBefore(weekStart)).toList();
    if (weekPoints.isEmpty) return null;
    final sum = weekPoints.fold<double>(0, (s, p) => s + p.weight);
    return sum / weekPoints.length;
  }

  TrendDirection _direction(List<_WeightPoint> points, double changeKg) {
    if (points.length < ProgressThresholds.minWeightDataPoints) {
      return TrendDirection.insufficientData;
    }

    final days = points.last.date.difference(points.first.date).inDays;
    final weeks = days > 0 ? days / 7.0 : 1.0;
    final weeklyChange = changeKg / weeks;

    if (weeklyChange.abs() <= ProgressThresholds.stableWeightChangeKgPerWeek) {
      final variance = _variance(points.map((p) => p.weight).toList());
      return variance > 0.5
          ? TrendDirection.fluctuating
          : TrendDirection.stable;
    }
    return weeklyChange > 0 ? TrendDirection.gaining : TrendDirection.losing;
  }

  double _variance(List<double> values) {
    if (values.length < 2) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final sqDiff =
        values.fold<double>(0, (s, v) => s + (v - mean) * (v - mean));
    return sqDiff / values.length;
  }

  double? _distanceToTarget(double? current, double? target) {
    if (current == null || target == null || target <= 0) return null;
    return (target - current).abs();
  }

  DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);
}

class _WeightPoint {
  final DateTime date;
  final double weight;

  const _WeightPoint(this.date, this.weight);
}
