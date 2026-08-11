// lib/domain/entities/daily_checkin.dart

import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/soreness_level.dart';

/// Domain Entity representing the user's daily check-in.
///
/// Captured once per day (auto-triggered on app launch).
/// Identified uniquely by ([userId], calendar day of [date]).
/// Saving again for the same day **replaces** the previous entry.
class DailyCheckIn {
  static const double minSleepHours = 0.0;
  static const double maxSleepHours = 12.0;
  static const int minMood = 1;
  static const int maxMood = 5;

  final String userId;
  final DateTime date;

  /// Optional body weight measurement for the day.
  final double weightKg;

  /// Hours of sleep last night ([minSleepHours]–[maxSleepHours], step 0.5).
  final double sleepHours;

  /// Muscle soreness level reported by the user (required).
  final SorenessLevel sorenessLevel;

  /// Subjective energy level reported by the user (required).
  final EnergyLevel energyLevel;

  /// Subjective mood on a 1–5 scale (1 = very bad, 5 = excellent).
  final int mood;

  DailyCheckIn({
    required this.userId,
    required this.date,
    required double sleepHours,
    required this.sorenessLevel,
    required this.energyLevel,
    required int mood,
    this.weightKg = 0.0,
  })  : sleepHours = sleepHours.clamp(minSleepHours, maxSleepHours),
        mood = mood.clamp(minMood, maxMood);

  /// Calendar-day key used for persistence identity.
  DateTime get dayKey => DateTime(date.year, date.month, date.day);

  bool get isWeightLogged => weightKg > 0;
  bool get isSleepLogged => sleepHours > 0;

  bool get isValid =>
      userId.isNotEmpty &&
      sleepHours >= minSleepHours &&
      sleepHours <= maxSleepHours &&
      mood >= minMood &&
      mood <= maxMood;

  @override
  String toString() =>
      'DailyCheckIn($date, sleep: ${sleepHours}h, soreness: ${sorenessLevel.name}, energy: ${energyLevel.name}, mood: $mood)';
}
