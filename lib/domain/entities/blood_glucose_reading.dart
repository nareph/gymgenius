import 'package:gymgenius/domain/enums/glucose_context.dart';

/// Manual blood glucose reading. Stored internally as mmol/L.
class BloodGlucoseReading {
  static const double minMmolL = 1.0;
  static const double maxMmolL = 40.0;
  static const double mgDlPerMmol = 18.0182;

  final String id;
  final String userId;
  final double valueMmolL;
  final GlucoseContext context;
  final DateTime measuredAt;
  final String? note;

  BloodGlucoseReading({
    required this.id,
    required this.userId,
    required double valueMmolL,
    required this.context,
    required this.measuredAt,
    this.note,
  }) : valueMmolL = valueMmolL.clamp(minMmolL, maxMmolL);

  double get valueMgDl => valueMmolL * mgDlPerMmol;

  static double mgDlToMmolL(double mgDl) => mgDl / mgDlPerMmol;

  bool get isValid =>
      userId.isNotEmpty &&
      valueMmolL >= minMmolL &&
      valueMmolL <= maxMmolL;

  DateTime get dayKey =>
      DateTime(measuredAt.year, measuredAt.month, measuredAt.day);

  @override
  String toString() =>
      'BloodGlucoseReading(${valueMmolL.toStringAsFixed(1)} mmol/L, ${context.value})';
}
