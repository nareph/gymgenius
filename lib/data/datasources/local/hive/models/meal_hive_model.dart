import 'package:hive/hive.dart';

part 'meal_hive_model.g.dart';

@HiveType(typeId: 12)
class MealHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type;

  @HiveField(3)
  String objective;

  @HiveField(4)
  List<String> ingredients;

  @HiveField(5)
  int calories;

  @HiveField(6)
  int proteinG;

  @HiveField(7)
  int carbsG;

  @HiveField(8)
  int fatG;

  @HiveField(9)
  String? timingNote;

  @HiveField(10)
  String? reason;

  MealHiveModel({
    required this.id,
    required this.name,
    required this.type,
    required this.objective,
    required this.ingredients,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.timingNote,
    this.reason,
  });
}
