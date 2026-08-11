import 'package:hive/hive.dart';

part 'nutrition_profile_hive_model.g.dart';

@HiveType(typeId: 10)
class NutritionProfileHiveModel extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  int calories;

  @HiveField(3)
  int proteinG;

  @HiveField(4)
  int carbsG;

  @HiveField(5)
  int fatG;

  @HiveField(6)
  int? waterMl;

  @HiveField(7)
  String country;

  @HiveField(8)
  List<String> preferredFoods;

  @HiveField(9)
  List<String> restrictedFoods;

  @HiveField(10)
  double? adherenceScore;

  NutritionProfileHiveModel({
    required this.userId,
    required this.date,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.waterMl,
    required this.country,
    required this.preferredFoods,
    required this.restrictedFoods,
    this.adherenceScore,
  });
}
