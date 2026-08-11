enum CoachMessageRole {
  user,
  assistant,
  system,
}

extension CoachMessageRoleExtension on CoachMessageRole {
  String get value {
    switch (this) {
      case CoachMessageRole.user:
        return 'user';
      case CoachMessageRole.assistant:
        return 'assistant';
      case CoachMessageRole.system:
        return 'system';
    }
  }

  static CoachMessageRole fromValue(String value) {
    return CoachMessageRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CoachMessageRole.user,
    );
  }
}

class ConversationMessage {
  final String id;
  final CoachMessageRole role;
  final String content;
  final DateTime timestamp;

  const ConversationMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
}

class Conversation {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ConversationMessage> messages;

  const Conversation({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  Conversation copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ConversationMessage>? messages,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }
}
