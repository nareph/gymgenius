import 'package:flutter_test/flutter_test.dart';
import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/recommended_intensity.dart';
import 'package:gymgenius/domain/enums/soreness_level.dart';
import 'package:gymgenius/engines/recovery_engine/recovery_thresholds.dart';
import 'package:gymgenius/engines/recovery_engine/scorers/fatigue_estimator.dart';
import 'package:gymgenius/engines/recovery_engine/scorers/readiness_calculator.dart';
import 'package:gymgenius/engines/recovery_engine/scorers/sleep_scorer.dart';

void main() {
  const sleepScorer = SleepScorer();
  const fatigueEstimator = FatigueEstimator();
  const readinessCalc = ReadinessCalculator();

  group('SleepScorer boundaries', () {
    test('0 h → 0', () => expect(sleepScorer.score(0), 0));
    test('5 h → score in [25, 26]', () {
      expect(sleepScorer.score(5.0), inInclusiveRange(25, 26));
    });
    test('6 h → score in [50, 51]', () {
      expect(sleepScorer.score(6.0), inInclusiveRange(50, 51));
    });
    test('7 h → score in [70, 71]', () {
      expect(sleepScorer.score(7.0), inInclusiveRange(70, 71));
    });
    test('9 h → 100', () => expect(sleepScorer.score(9.0), 100));
    test('>9 h clamped to [80,100]', () {
      final s = sleepScorer.score(10.5);
      expect(s, greaterThanOrEqualTo(80));
      expect(s, lessThanOrEqualTo(100));
    });
  });

  group('FatigueEstimator all Soreness × Energy', () {
    for (final soreness in SorenessLevel.values) {
      for (final energy in EnergyLevel.values) {
        test('${soreness.name} × ${energy.name} ∈ [0,100]', () {
          final f = fatigueEstimator.estimate(
            sorenessLevel: soreness,
            energyLevel: energy,
          );
          expect(f, inInclusiveRange(0, 100));
        });
      }
    }
  });

  group('ReadinessCalculator mood extremes + coherence', () {
    test('mood 1 and 5 stay in [0,100]', () {
      final low = readinessCalc.readiness(
        sleepScore: 50,
        fatigueScore: 50,
        mood: 1,
      );
      final high = readinessCalc.readiness(
        sleepScore: 50,
        fatigueScore: 50,
        mood: 5,
      );
      expect(low, inInclusiveRange(0, 100));
      expect(high, inInclusiveRange(0, 100));
      expect(high, greaterThan(low));
    });

    test('recoveryScore and readiness stay in [0,100]', () {
      for (final sleep in [0, 25, 50, 75, 100]) {
        for (final fatigue in [0, 25, 50, 75, 100]) {
          final recovery = readinessCalc.recoveryScore(
            sleepScore: sleep,
            fatigueScore: fatigue,
          );
          final readiness = readinessCalc.readiness(
            sleepScore: sleep,
            fatigueScore: fatigue,
            mood: 3,
          );
          expect(recovery, inInclusiveRange(0, 100));
          expect(readiness, inInclusiveRange(0, 100));
        }
      }
    });

    test('volumeMultiplier matches RecoveryThresholds', () {
      for (final score in [90, 70, 50, 20]) {
        expect(
          readinessCalc.volumeMultiplier(score),
          RecoveryThresholds.volumeMultiplier(score),
        );
      }
    });

    test('intensity tiers', () {
      expect(readinessCalc.intensity(85), RecommendedIntensity.max);
      expect(readinessCalc.intensity(70), RecommendedIntensity.high);
      expect(readinessCalc.intensity(55), RecommendedIntensity.moderate);
      expect(readinessCalc.intensity(40), RecommendedIntensity.light);
      expect(readinessCalc.intensity(20), RecommendedIntensity.rest);
    });
  });
}
