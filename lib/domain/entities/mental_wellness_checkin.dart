import 'package:gymgenius/domain/enums/energy_level.dart';
import 'package:gymgenius/domain/enums/stress_level.dart';

/// Separate from Recovery [DailyCheckIn] — wellness-focused self-report.
///
/// Not a psychological diagnosis.
class MentalWellnessCheckIn {
  static const int minMood = 1;
  static const int maxMood = 5;
  static const int maxNotesLength = 500;

  final String id;
  final String userId;
  final DateTime date;
  final int mood;
  final StressLevel stress;
  final EnergyLevel energy;
  final String? notes;

  MentalWellnessCheckIn({
    required this.id,
    required this.userId,
    required this.date,
    required int mood,
    required this.stress,
    required this.energy,
    String? notes,
  })  : mood = mood.clamp(minMood, maxMood),
        notes = notes == null
            ? null
            : (notes.length > maxNotesLength
                ? notes.substring(0, maxNotesLength)
                : notes);

  DateTime get dayKey => DateTime(date.year, date.month, date.day);

  bool get isValid =>
      userId.isNotEmpty &&
      mood >= minMood &&
      mood <= maxMood;

  @override
  String toString() =>
      'MentalWellnessCheckIn($dayKey, mood: $mood, stress: ${stress.value})';
}
