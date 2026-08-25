import 'package:hive/hive.dart';

part 'logged_food_portion_hive_model.g.dart';

@HiveType(typeId: 24)
class LoggedFoodPortionHiveModel extends HiveObject {
  @HiveField(0)
  String foodId;

  @HiveField(1)
  String foodName;

  @HiveField(2)
  double grams;

  LoggedFoodPortionHiveModel({
    required this.foodId,
    required this.foodName,
    required this.grams,
  });
}
