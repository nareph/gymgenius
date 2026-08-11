import 'package:gymgenius/domain/entities/mental_wellness_checkin.dart';
import 'package:gymgenius/domain/enums/stress_level.dart';

class MentalWellnessStatus {
  final MentalWellnessCheckIn? today;
  final String? trendLabel;
  final List<String> recommendations;
  final List<String> reasons;

  const MentalWellnessStatus({
    this.today,
    this.trendLabel,
    this.recommendations = const [],
    this.reasons = const [],
  });
}

/// Non-clinical wellness trend helpers.
class MentalWellnessEngine {
  const MentalWellnessEngine();

  MentalWellnessStatus analyze({
    MentalWellnessCheckIn? today,
    List<MentalWellnessCheckIn> recent = const [],
  }) {
    final reasons = <String>[];
    final recs = <String>[];
    String? trend;

    if (today == null) {
      reasons.add('No wellness check-in today');
      recs.add('A quick mood/stress check-in can help spot patterns');
      return MentalWellnessStatus(
        recommendations: recs,
        reasons: reasons,
      );
    }

    reasons.add('Today mood ${today.mood}/5, stress ${today.stress.displayName}');

    if (today.stress == StressLevel.high ||
        today.stress == StressLevel.veryHigh) {
      recs.add('Consider a short walk, breathing break, or earlier wind-down');
    }
    if (today.mood <= 2) {
      recs.add('Be kind to yourself today — light movement and rest can help');
    }
    if (today.mood >= 4 &&
        (today.stress == StressLevel.low ||
            today.stress == StressLevel.veryLow)) {
      recs.add('Nice balance today — keep the routines that support you');
    }

    if (recent.length >= 3) {
      final avg = recent.map((e) => e.mood).reduce((a, b) => a + b) /
          recent.length;
      final latestAvg = recent.length >= 5
          ? recent.take(3).map((e) => e.mood).reduce((a, b) => a + b) / 3
          : today.mood.toDouble();
      if (latestAvg > avg + 0.4) {
        trend = 'improving';
      } else if (latestAvg < avg - 0.4) {
        trend = 'declining';
      } else {
        trend = 'stable';
      }
      reasons.add('Recent mood trend: $trend');
    }

    recs.add(
      'This tool is not a psychological diagnosis — seek professional help if needed',
    );

    return MentalWellnessStatus(
      today: today,
      trendLabel: trend,
      recommendations: recs,
      reasons: reasons,
    );
  }
}
