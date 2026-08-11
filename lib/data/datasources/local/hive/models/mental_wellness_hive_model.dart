import 'package:hive/hive.dart';

part 'mental_wellness_hive_model.g.dart';

@HiveType(typeId: 21)
class MentalWellnessHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  int mood;

  @HiveField(4)
  String stress;

  @HiveField(5)
  String energy;

  @HiveField(6)
  String? notes;

  MentalWellnessHiveModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    required this.stress,
    required this.energy,
    this.notes,
  });
}
