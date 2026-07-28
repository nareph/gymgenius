// lib/domain/entities/ai_recommendation.dart

/// Domain Entity representing an AI or Decision Engine recommendation.
class AIRecommendation {
  final String userId;
  final DateTime date;
  final String title;
  final String message;
  final String
      category; // 'workout', 'nutrition', 'recovery', 'lifestyle', 'motivation'
  final String priority; // 'low', 'medium', 'high', 'critical'
  final String source; // 'decision_engine_v1' | 'gemini' | etc.
  final String engineVersion;

  const AIRecommendation({
    required this.userId,
    required this.date,
    required this.title,
    required this.message,
    required this.category,
    required this.priority,
    required this.source,
    required this.engineVersion,
  });

  @override
  String toString() => 'AIRecommendation($date, $category, $priority)';
}
