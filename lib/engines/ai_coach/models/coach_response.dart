/// Priority for coach insights / recommendations.
enum CoachPriority {
  low,
  medium,
  high,
}

extension CoachPriorityExtension on CoachPriority {
  String get value {
    switch (this) {
      case CoachPriority.low:
        return 'low';
      case CoachPriority.medium:
        return 'medium';
      case CoachPriority.high:
        return 'high';
    }
  }

  static CoachPriority fromValue(String value) {
    return CoachPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CoachPriority.medium,
    );
  }
}

/// Category of a coach recommendation (must align with Decision Engine).
enum CoachRecommendationCategory {
  workout,
  recovery,
  nutrition,
  progress,
  motivation,
  general,
}

extension CoachRecommendationCategoryExtension on CoachRecommendationCategory {
  String get value {
    switch (this) {
      case CoachRecommendationCategory.workout:
        return 'workout';
      case CoachRecommendationCategory.recovery:
        return 'recovery';
      case CoachRecommendationCategory.nutrition:
        return 'nutrition';
      case CoachRecommendationCategory.progress:
        return 'progress';
      case CoachRecommendationCategory.motivation:
        return 'motivation';
      case CoachRecommendationCategory.general:
        return 'general';
    }
  }

  static CoachRecommendationCategory fromValue(String value) {
    return CoachRecommendationCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CoachRecommendationCategory.general,
    );
  }
}

class CoachInsight {
  final String type;
  final String title;
  final String body;
  final CoachPriority priority;

  const CoachInsight({
    required this.type,
    required this.title,
    required this.body,
    this.priority = CoachPriority.medium,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'body': body,
        'priority': priority.value,
      };

  factory CoachInsight.fromJson(Map<String, dynamic> json) {
    return CoachInsight(
      type: json['type'] as String? ?? 'insight',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      priority: CoachPriorityExtension.fromValue(
        json['priority'] as String? ?? 'medium',
      ),
    );
  }
}

class CoachRecommendation {
  final CoachRecommendationCategory category;
  final String text;
  final String reason;
  final bool alignsWithDecision;

  /// Machine tag used by guardrails (e.g. increase_volume, rest).
  final String? actionTag;

  const CoachRecommendation({
    required this.category,
    required this.text,
    required this.reason,
    this.alignsWithDecision = true,
    this.actionTag,
  });

  Map<String, dynamic> toJson() => {
        'category': category.value,
        'text': text,
        'reason': reason,
        'alignsWithDecision': alignsWithDecision,
        'actionTag': actionTag,
      };

  factory CoachRecommendation.fromJson(Map<String, dynamic> json) {
    return CoachRecommendation(
      category: CoachRecommendationCategoryExtension.fromValue(
        json['category'] as String? ?? 'general',
      ),
      text: json['text'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      alignsWithDecision: json['alignsWithDecision'] as bool? ?? true,
      actionTag: json['actionTag'] as String?,
    );
  }
}

/// Structured AI Coach response (validated before UI display).
class CoachResponse {
  final String message;
  final List<CoachInsight> insights;
  final List<CoachRecommendation> recommendations;
  final String tone;
  final String generatedBy;
  final String providerId;
  final String promptVersion;
  final DateTime generatedAt;
  final bool usedFallback;

  const CoachResponse({
    required this.message,
    this.insights = const [],
    this.recommendations = const [],
    this.tone = 'supportive',
    this.generatedBy = 'ai_coach_v1',
    required this.providerId,
    required this.promptVersion,
    required this.generatedAt,
    this.usedFallback = false,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'insights': insights.map((e) => e.toJson()).toList(),
        'recommendations': recommendations.map((e) => e.toJson()).toList(),
        'tone': tone,
        'generatedBy': generatedBy,
        'providerId': providerId,
        'promptVersion': promptVersion,
        'generatedAt': generatedAt.toIso8601String(),
        'usedFallback': usedFallback,
      };

  factory CoachResponse.fromJson(
    Map<String, dynamic> json, {
    required String providerId,
    required String promptVersion,
    DateTime? generatedAt,
  }) {
    final insightsRaw = json['insights'] as List<dynamic>? ?? const [];
    final recsRaw = json['recommendations'] as List<dynamic>? ?? const [];

    return CoachResponse(
      message: json['message'] as String? ?? '',
      insights: insightsRaw
          .whereType<Map>()
          .map((e) => CoachInsight.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      recommendations: recsRaw
          .whereType<Map>()
          .map((e) =>
              CoachRecommendation.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      tone: json['tone'] as String? ?? 'supportive',
      generatedBy: json['generatedBy'] as String? ?? 'ai_coach_v1',
      providerId: json['providerId'] as String? ?? providerId,
      promptVersion: json['promptVersion'] as String? ?? promptVersion,
      generatedAt: generatedAt ??
          DateTime.tryParse(json['generatedAt'] as String? ?? '') ??
          DateTime.now(),
      usedFallback: json['usedFallback'] as bool? ?? false,
    );
  }

  CoachResponse copyWith({
    String? message,
    List<CoachInsight>? insights,
    List<CoachRecommendation>? recommendations,
    String? tone,
    String? generatedBy,
    String? providerId,
    String? promptVersion,
    DateTime? generatedAt,
    bool? usedFallback,
  }) {
    return CoachResponse(
      message: message ?? this.message,
      insights: insights ?? this.insights,
      recommendations: recommendations ?? this.recommendations,
      tone: tone ?? this.tone,
      generatedBy: generatedBy ?? this.generatedBy,
      providerId: providerId ?? this.providerId,
      promptVersion: promptVersion ?? this.promptVersion,
      generatedAt: generatedAt ?? this.generatedAt,
      usedFallback: usedFallback ?? this.usedFallback,
    );
  }
}
