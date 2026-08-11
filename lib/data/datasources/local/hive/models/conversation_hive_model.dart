import 'package:hive/hive.dart';

part 'conversation_hive_model.g.dart';

@HiveType(typeId: 16)
class ConversationHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  /// JSON-encoded list of messages.
  @HiveField(4)
  String messagesJson;

  ConversationHiveModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.messagesJson = '[]',
  });
}
