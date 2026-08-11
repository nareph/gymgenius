/// Manual blood pressure measurement (never a medical diagnosis).
class BloodPressureReading {
  static const int minSystolic = 60;
  static const int maxSystolic = 250;
  static const int minDiastolic = 40;
  static const int maxDiastolic = 150;
  static const int minHeartRate = 30;
  static const int maxHeartRate = 220;

  final String id;
  final String userId;
  final int systolic;
  final int diastolic;
  final int? heartRateBpm;
  final DateTime measuredAt;
  final String? note;

  BloodPressureReading({
    required this.id,
    required this.userId,
    required int systolic,
    required int diastolic,
    this.heartRateBpm,
    required this.measuredAt,
    this.note,
  })  : systolic = systolic.clamp(minSystolic, maxSystolic),
        diastolic = diastolic.clamp(minDiastolic, maxDiastolic);

  bool get isValid =>
      userId.isNotEmpty &&
      systolic >= minSystolic &&
      systolic <= maxSystolic &&
      diastolic >= minDiastolic &&
      diastolic <= maxDiastolic &&
      systolic > diastolic &&
      (heartRateBpm == null ||
          (heartRateBpm! >= minHeartRate && heartRateBpm! <= maxHeartRate));

  DateTime get dayKey =>
      DateTime(measuredAt.year, measuredAt.month, measuredAt.day);

  @override
  String toString() =>
      'BloodPressureReading($systolic/$diastolic @ $measuredAt)';
}
