import 'package:hive/hive.dart';

part 'blood_pressure_hive_model.g.dart';

@HiveType(typeId: 18)
class BloodPressureHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  int systolic;

  @HiveField(3)
  int diastolic;

  @HiveField(4)
  int? heartRateBpm;

  @HiveField(5)
  DateTime measuredAt;

  @HiveField(6)
  String? note;

  BloodPressureHiveModel({
    required this.id,
    required this.userId,
    required this.systolic,
    required this.diastolic,
    this.heartRateBpm,
    required this.measuredAt,
    this.note,
  });
}
