import 'package:gymgenius/domain/entities/blood_glucose_reading.dart';
import 'package:gymgenius/domain/entities/blood_pressure_reading.dart';
import 'package:gymgenius/domain/entities/daily_checkin.dart';
import 'package:gymgenius/domain/entities/habit.dart';
import 'package:gymgenius/domain/entities/habit_log.dart';
import 'package:gymgenius/domain/entities/health_platform_snapshot.dart';
import 'package:gymgenius/domain/entities/hydration_log.dart';
import 'package:gymgenius/domain/entities/mental_wellness_checkin.dart';
import 'package:gymgenius/domain/enums/blood_pressure_category.dart';
import 'package:gymgenius/domain/enums/glucose_category.dart';
import 'package:gymgenius/domain/enums/health_caution_level.dart';
import 'package:gymgenius/engines/health_platform/blood_glucose_engine.dart';
import 'package:gymgenius/engines/health_platform/blood_pressure_engine.dart';
import 'package:gymgenius/engines/health_platform/habit_engine.dart';
import 'package:gymgenius/engines/health_platform/hydration_engine.dart';
import 'package:gymgenius/engines/health_platform/lifestyle_engine.dart';
import 'package:gymgenius/engines/health_platform/mental_wellness_engine.dart';

/// Facade aggregating Health Platform sub-engines into a day snapshot.
class HealthPlatformEngine {
  final BloodPressureEngine bloodPressureEngine;
  final BloodGlucoseEngine bloodGlucoseEngine;
  final HydrationEngine hydrationEngine;
  final MentalWellnessEngine mentalWellnessEngine;
  final HabitEngine habitEngine;
  final LifestyleEngine lifestyleEngine;

  const HealthPlatformEngine({
    this.bloodPressureEngine = const BloodPressureEngine(),
    this.bloodGlucoseEngine = const BloodGlucoseEngine(),
    this.hydrationEngine = const HydrationEngine(),
    this.mentalWellnessEngine = const MentalWellnessEngine(),
    this.habitEngine = const HabitEngine(),
    this.lifestyleEngine = const LifestyleEngine(),
  });

  HealthPlatformSnapshot buildSnapshot({
    required String userId,
    required DateTime now,
    BloodPressureReading? latestBp,
    BloodGlucoseReading? latestGlucose,
    List<HydrationLog> hydrationLogs = const [],
    MentalWellnessCheckIn? todayWellness,
    List<MentalWellnessCheckIn> recentWellness = const [],
    List<Habit> habits = const [],
    List<HabitLog> habitLogs = const [],
    DailyCheckIn? recoveryCheckIn,
    double? weightKg,
    bool isTrainingDay = false,
  }) {
    final day = DateTime(now.year, now.month, now.day);

    final bpCategory =
        latestBp == null ? null : bloodPressureEngine.classify(latestBp);
    final bpCaution = bpCategory == null
        ? HealthCautionLevel.none
        : bloodPressureEngine.cautionFor(bpCategory);

    final glucoseCategory = latestGlucose == null
        ? null
        : bloodGlucoseEngine.classify(latestGlucose);
    final glucoseCaution = glucoseCategory == null
        ? HealthCautionLevel.none
        : bloodGlucoseEngine.cautionFor(glucoseCategory);

    final dayHydration =
        hydrationLogs.where((l) => l.dayKey == day).toList(growable: false);
    final hydration = hydrationEngine.summarize(
      logs: dayHydration,
      weightKg: weightKg ??
          (recoveryCheckIn != null && recoveryCheckIn.isWeightLogged
              ? recoveryCheckIn.weightKg
              : null),
      isTrainingDay: isTrainingDay,
    );

    final wellness = mentalWellnessEngine.analyze(
      today: todayWellness,
      recent: recentWellness,
    );

    final habitsStats = habitEngine.computeStats(
      habits: habits,
      logs: habitLogs,
      day: day,
    );

    final lifestyle = lifestyleEngine.build(
      userId: userId,
      now: now,
      sleepHours: recoveryCheckIn?.sleepHours,
      hydration: hydration,
      habits: habitsStats,
      wellness: wellness,
    );

    final overall = _maxCaution([
      bpCaution,
      glucoseCaution,
      lifestyle.cautionLevel,
    ]);

    final recommendations = <String>[
      if (bpCategory != null) bloodPressureEngine.prudenceMessage(bpCategory),
      if (glucoseCategory != null)
        bloodGlucoseEngine.prudenceMessage(glucoseCategory),
      ...lifestyle.recommendations.take(3),
    ];

    final reasons = <String>[
      ...lifestyle.reasons,
      if (bpCategory != null) 'BP category: ${bpCategory.displayName}',
      if (glucoseCategory != null)
        'Glucose category: ${glucoseCategory.displayName}',
    ];

    return HealthPlatformSnapshot(
      userId: userId,
      computedAt: now,
      latestBloodPressure: latestBp,
      bloodPressureCategory: bpCategory,
      hasBpCaution: bpCategory?.requiresCaution ?? false,
      latestBloodGlucose: latestGlucose,
      glucoseCategory: glucoseCategory,
      hasGlucoseCaution: glucoseCategory?.requiresCaution ?? false,
      hydrationTargetMl: hydration.targetMl,
      hydrationTotalMl: hydration.totalMl,
      hydrationPercent: hydration.percent,
      todayWellness: todayWellness,
      wellnessTrendLabel: wellness.trendLabel,
      activeHabitsCount: habitsStats.activeCount,
      habitsCompletedToday: habitsStats.completedToday,
      habitsCompletionPercent: habitsStats.completionPercent,
      longestCurrentStreak: habitsStats.longestCurrentStreak,
      lifestyle: lifestyle,
      overallCaution: overall,
      recommendations: recommendations,
      reasons: reasons,
    );
  }

  HealthCautionLevel _maxCaution(List<HealthCautionLevel> levels) {
    var best = HealthCautionLevel.none;
    for (final level in levels) {
      if (level.index > best.index) best = level;
    }
    return best;
  }
}
