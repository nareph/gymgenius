import 'package:gymgenius/domain/enums/blood_pressure_category.dart';
import 'package:gymgenius/domain/enums/health_caution_level.dart';
import 'package:gymgenius/domain/entities/blood_pressure_reading.dart';

/// Deterministic BP classification — informational only, never a diagnosis.
class BloodPressureEngine {
  const BloodPressureEngine();

  BloodPressureCategory classify(BloodPressureReading reading) {
    if (!reading.isValid) return BloodPressureCategory.unknown;

    final s = reading.systolic;
    final d = reading.diastolic;

    // Simplified adult categories (ACC/AHA-inspired, educational use only).
    if (s >= 180 || d >= 120) return BloodPressureCategory.crisis;
    if (s >= 140 || d >= 90) return BloodPressureCategory.highStage2;
    if (s >= 130 || d >= 80) return BloodPressureCategory.highStage1;
    if (s >= 120 && d < 80) return BloodPressureCategory.elevated;
    if (s < 90 || d < 60) return BloodPressureCategory.low;
    return BloodPressureCategory.normal;
  }

  HealthCautionLevel cautionFor(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.crisis:
        return HealthCautionLevel.urgent;
      case BloodPressureCategory.highStage2:
      case BloodPressureCategory.low:
        return HealthCautionLevel.caution;
      case BloodPressureCategory.highStage1:
      case BloodPressureCategory.elevated:
        return HealthCautionLevel.info;
      case BloodPressureCategory.normal:
      case BloodPressureCategory.unknown:
        return HealthCautionLevel.none;
    }
  }

  String prudenceMessage(BloodPressureCategory category) {
    switch (category) {
      case BloodPressureCategory.crisis:
        return 'Values look very high. This is not a diagnosis — seek urgent medical care if you feel unwell.';
      case BloodPressureCategory.highStage2:
      case BloodPressureCategory.highStage1:
      case BloodPressureCategory.elevated:
        return 'Elevated readings noted. Discuss trends with a healthcare professional.';
      case BloodPressureCategory.low:
        return 'Reading looks low. If you feel dizzy or unwell, seek medical advice.';
      case BloodPressureCategory.normal:
        return 'Reading is within a typical range. Keep tracking for trends.';
      case BloodPressureCategory.unknown:
        return 'Unable to classify this reading.';
    }
  }
}
