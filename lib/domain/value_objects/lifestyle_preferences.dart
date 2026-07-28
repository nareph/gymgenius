import 'package:gymgenius/domain/enums/budget_level.dart';

class LifestylePreferences {
  final String country;
  final String? city;
  final List<String> foodPreferences;
  final List<String> foodRestrictions;
  final BudgetLevel budget;
  final int? sleepSchedule; // hour 0-23
  final int? wakeUpTime; // hour 0-23
  final int? trainingTime; // hour 0-23

  const LifestylePreferences({
    required this.country,
    this.city,
    this.foodPreferences = const [],
    this.foodRestrictions = const [],
    required this.budget,
    this.sleepSchedule,
    this.wakeUpTime,
    this.trainingTime,
  });

  LifestylePreferences copyWith({
    String? country,
    String? city,
    List<String>? foodPreferences,
    List<String>? foodRestrictions,
    BudgetLevel? budget,
    int? sleepSchedule,
    int? wakeUpTime,
    int? trainingTime,
  }) {
    return LifestylePreferences(
      country: country ?? this.country,
      city: city ?? this.city,
      foodPreferences: foodPreferences ?? this.foodPreferences,
      foodRestrictions: foodRestrictions ?? this.foodRestrictions,
      budget: budget ?? this.budget,
      sleepSchedule: sleepSchedule ?? this.sleepSchedule,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      trainingTime: trainingTime ?? this.trainingTime,
    );
  }
}
