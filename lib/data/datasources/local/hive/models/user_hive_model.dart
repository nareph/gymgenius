import 'package:hive/hive.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: 0)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String email;

  @HiveField(2)
  String? displayName;

  @HiveField(3)
  DateTime createdAt;

  UserHiveModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.createdAt,
  });
}
