import 'package:gymgenius/domain/enums/blood_pressure_category.dart';
import 'package:gymgenius/domain/enums/glucose_category.dart';
import 'package:gymgenius/domain/enums/health_caution_level.dart';

import 'blood_glucose_reading.dart';
import 'blood_pressure_reading.dart';
import 'lifestyle_status.dart';
import 'mental_wellness_checkin.dart';

/// Day snapshot from [HealthPlatformEngine] for UI / Decision / Coach.
class HealthPlatformSnapshot {
  final String userId;
  final DateTime computedAt;

  final BloodPressureReading? latestBloodPressure;
  final BloodPressureCategory? bloodPressureCategory;
  final bool hasBpCaution;

  final BloodGlucoseReading? latestBloodGlucose;
  final GlucoseCategory? glucoseCategory;
  final bool hasGlucoseCaution;

  final int hydrationTargetMl;
  final int hydrationTotalMl;
  final int hydrationPercent;

  final MentalWellnessCheckIn? todayWellness;
  final String? wellnessTrendLabel;

  final int activeHabitsCount;
  final int habitsCompletedToday;
  final int habitsCompletionPercent;
  final int longestCurrentStreak;

  final LifestyleStatus? lifestyle;

  final HealthCautionLevel overallCaution;
  final List<String> recommendations;
  final List<String> reasons;
  final String generatedBy;

  const HealthPlatformSnapshot({
    required this.userId,
    required this.computedAt,
    this.latestBloodPressure,
    this.bloodPressureCategory,
    this.hasBpCaution = false,
    this.latestBloodGlucose,
    this.glucoseCategory,
    this.hasGlucoseCaution = false,
    this.hydrationTargetMl = 2000,
    this.hydrationTotalMl = 0,
    this.hydrationPercent = 0,
    this.todayWellness,
    this.wellnessTrendLabel,
    this.activeHabitsCount = 0,
    this.habitsCompletedToday = 0,
    this.habitsCompletionPercent = 0,
    this.longestCurrentStreak = 0,
    this.lifestyle,
    this.overallCaution = HealthCautionLevel.none,
    this.recommendations = const [],
    this.reasons = const [],
    this.generatedBy = 'health_platform_engine_v1',
  });

  bool get hasAnyData =>
      latestBloodPressure != null ||
      latestBloodGlucose != null ||
      hydrationTotalMl > 0 ||
      todayWellness != null ||
      activeHabitsCount > 0;

  /// Safe labels for AI Coach — no raw BP/glucose values.
  Map<String, dynamic> toCoachSafeMap() {
    return {
      'hydrationPercent': hydrationPercent,
      'habitsCompletionPercent': habitsCompletionPercent,
      'habitsStreakSummary': longestCurrentStreak > 0
          ? 'longest_streak_$longestCurrentStreak'
          : 'no_streak',
      'wellnessTrend': wellnessTrendLabel,
      'hasBpCaution': hasBpCaution,
      'hasGlucoseCaution': hasGlucoseCaution,
      'overallCaution': overallCaution.value,
      'lifestyleReasons': lifestyle?.reasons ?? const <String>[],
    };
  }

  @override
  String toString() =>
      'HealthPlatformSnapshot(caution: ${overallCaution.value}, hydration: $hydrationPercent%)';
}
