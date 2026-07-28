import 'package:gymgenius/domain/entities/user.dart';
import 'package:gymgenius/data/datasources/local/hive/models/user_hive_model.dart';

class UserMapper {
  const UserMapper._();

  static User toDomain(UserHiveModel model) {
    return User(
      id: model.uid,
      email: model.email,
      displayName: model.displayName,
    );
  }

  static UserHiveModel toHive(User user) {
    return UserHiveModel(
      uid: user.id,
      email: user.email,
      displayName: user.displayName,
      createdAt: DateTime.now(),
    );
  }
}
