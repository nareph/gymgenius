import 'package:hive/hive.dart';

part 'hydration_log_hive_model.g.dart';

@HiveType(typeId: 20)
class HydrationLogHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  int amountMl;

  @HiveField(3)
  DateTime loggedAt;

  @HiveField(4)
  String? note;

  HydrationLogHiveModel({
    required this.id,
    required this.userId,
    required this.amountMl,
    required this.loggedAt,
    this.note,
  });
}
