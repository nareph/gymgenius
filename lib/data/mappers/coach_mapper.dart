import 'dart:convert';

import 'package:gymgenius/data/datasources/local/hive/models/coach_cache_hive_model.dart';
import 'package:gymgenius/data/datasources/local/hive/models/conversation_hive_model.dart';
import 'package:gymgenius/engines/ai_coach/models/coach_response.dart';
import 'package:gymgenius/engines/ai_coach/models/conversation.dart';
import 'package:gymgenius/engines/ai_coach/prompts/coach_prompts.dart';

class CoachMapper {
  const CoachMapper._();

  static Conversation toConversation(ConversationHiveModel model) {
    final list = jsonDecode(model.messagesJson) as List<dynamic>? ?? const [];
    final messages = list.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return ConversationMessage(
        id: map['id'] as String,
        role: CoachMessageRoleExtension.fromValue(map['role'] as String),
        content: map['content'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
    }).toList();

    return Conversation(
      id: model.id,
      userId: model.userId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      messages: messages,
    );
  }

  static ConversationHiveModel fromConversation(Conversation entity) {
    final messagesJson = jsonEncode(
      entity.messages
          .map((m) => {
                'id': m.id,
                'role': m.role.value,
                'content': m.content,
                'timestamp': m.timestamp.toIso8601String(),
              })
          .toList(),
    );

    return ConversationHiveModel(
      id: entity.id,
      userId: entity.userId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      messagesJson: messagesJson,
    );
  }

  static CoachResponse toCoachResponse(CoachCacheHiveModel model) {
    final map = jsonDecode(model.responseJson) as Map<String, dynamic>;
    return CoachResponse.fromJson(
      map,
      providerId: model.providerId,
      promptVersion: map['promptVersion'] as String? ?? CoachPrompts.promptVersion,
      generatedAt: model.generatedAt,
    );
  }

  static CoachCacheHiveModel fromCoachResponse({
    required String id,
    required String userId,
    required String kind,
    required DateTime periodStart,
    required CoachResponse response,
  }) {
    return CoachCacheHiveModel(
      id: id,
      userId: userId,
      kind: kind,
      periodStart: periodStart,
      generatedAt: response.generatedAt,
      responseJson: jsonEncode(response.toJson()),
      providerId: response.providerId,
    );
  }
}
