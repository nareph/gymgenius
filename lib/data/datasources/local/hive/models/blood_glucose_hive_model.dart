import 'package:hive/hive.dart';

part 'blood_glucose_hive_model.g.dart';

@HiveType(typeId: 19)
class BloodGlucoseHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  double valueMmolL;

  @HiveField(3)
  String context;

  @HiveField(4)
  DateTime measuredAt;

  @HiveField(5)
  String? note;

  BloodGlucoseHiveModel({
    required this.id,
    required this.userId,
    required this.valueMmolL,
    required this.context,
    required this.measuredAt,
    this.note,
  });
}
