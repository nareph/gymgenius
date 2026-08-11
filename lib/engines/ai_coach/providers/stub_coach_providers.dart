import 'package:gymgenius/engines/ai_coach/providers/ai_provider.dart';
import 'package:gymgenius/engines/ai_coach/providers/coach_request_options.dart';

/// Stub — OpenAI not wired in v4.0.
class OpenAICoachProvider implements AIProvider {
  const OpenAICoachProvider();

  @override
  String get id => 'openai';

  @override
  bool get isAvailable => false;

  @override
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    CoachRequestOptions options = const CoachRequestOptions(),
  }) {
    throw UnsupportedError('OpenAI provider is not enabled in v4.0.');
  }
}

/// Stub — Claude not wired in v4.0.
class ClaudeCoachProvider implements AIProvider {
  const ClaudeCoachProvider();

  @override
  String get id => 'claude';

  @override
  bool get isAvailable => false;

  @override
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    CoachRequestOptions options = const CoachRequestOptions(),
  }) {
    throw UnsupportedError('Claude provider is not enabled in v4.0.');
  }
}
