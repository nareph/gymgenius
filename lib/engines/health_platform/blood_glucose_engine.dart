import 'package:gymgenius/domain/entities/blood_glucose_reading.dart';
import 'package:gymgenius/domain/enums/glucose_category.dart';
import 'package:gymgenius/domain/enums/glucose_context.dart';
import 'package:gymgenius/domain/enums/health_caution_level.dart';

/// Deterministic glucose classification — informational only.
class BloodGlucoseEngine {
  const BloodGlucoseEngine();

  GlucoseCategory classify(BloodGlucoseReading reading) {
    if (!reading.isValid) return GlucoseCategory.unknown;
    final v = reading.valueMmolL;

    switch (reading.context) {
      case GlucoseContext.fasting:
        if (v < 3.9) return GlucoseCategory.low;
        if (v <= 5.5) return GlucoseCategory.normal;
        if (v <= 6.9) return GlucoseCategory.elevated;
        return GlucoseCategory.high;
      case GlucoseContext.postMeal:
        if (v < 3.9) return GlucoseCategory.low;
        if (v <= 7.8) return GlucoseCategory.normal;
        if (v <= 11.0) return GlucoseCategory.elevated;
        return GlucoseCategory.high;
      case GlucoseContext.other:
        if (v < 3.9) return GlucoseCategory.low;
        if (v <= 7.8) return GlucoseCategory.normal;
        if (v <= 11.0) return GlucoseCategory.elevated;
        return GlucoseCategory.high;
    }
  }

  HealthCautionLevel cautionFor(GlucoseCategory category) {
    switch (category) {
      case GlucoseCategory.low:
      case GlucoseCategory.high:
        return HealthCautionLevel.caution;
      case GlucoseCategory.elevated:
        return HealthCautionLevel.info;
      case GlucoseCategory.normal:
      case GlucoseCategory.unknown:
        return HealthCautionLevel.none;
    }
  }

  String prudenceMessage(GlucoseCategory category) {
    switch (category) {
      case GlucoseCategory.low:
        return 'Glucose looks low. This is not a diagnosis — seek care if symptoms are present.';
      case GlucoseCategory.high:
        return 'Glucose looks high. Track trends and consult a healthcare professional.';
      case GlucoseCategory.elevated:
        return 'Glucose is somewhat elevated for the measurement context.';
      case GlucoseCategory.normal:
        return 'Glucose is within a typical range for this context.';
      case GlucoseCategory.unknown:
        return 'Unable to classify this reading.';
    }
  }
}
