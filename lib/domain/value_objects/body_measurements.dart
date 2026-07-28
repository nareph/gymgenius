import 'package:gymgenius/domain/enums/gender.dart';

class BodyMeasurements {
  final int age;
  final double heightCm;
  final double currentWeightKg;
  final double? targetWeightKg;
  final Gender gender;

  const BodyMeasurements({
    required this.age,
    required this.heightCm,
    required this.currentWeightKg,
    this.targetWeightKg,
    required this.gender,
  });

  double get bmi {
    final meters = heightCm / 100.0;
    if (meters <= 0) return 0;
    return currentWeightKg / (meters * meters);
  }

  BodyMeasurements copyWith({
    int? age,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    Gender? gender,
  }) {
    return BodyMeasurements(
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      gender: gender ?? this.gender,
    );
  }
}
