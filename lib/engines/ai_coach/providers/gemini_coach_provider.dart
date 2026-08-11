import 'package:gymgenius/engines/ai_coach/ai_config.dart';
import 'package:gymgenius/engines/ai_coach/api/gemini_api_client.dart';
import 'package:gymgenius/engines/ai_coach/providers/ai_provider.dart';
import 'package:gymgenius/engines/ai_coach/providers/coach_request_options.dart';

/// Gemini-backed coach provider (production path when API key is set).
class GeminiCoachProvider implements AIProvider {
  final GeminiAPIClient _client;

  GeminiCoachProvider({GeminiAPIClient? client})
      : _client = client ?? GeminiAPIClient();

  @override
  String get id => 'gemini';

  @override
  bool get isAvailable => AIConfig.hasGemini;

  @override
  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    CoachRequestOptions options = const CoachRequestOptions(),
  }) async {
    if (!isAvailable) {
      throw StateError('Gemini is not configured.');
    }

    final prompt = '$systemPrompt\n\n$userPrompt';
    return _client.generateText(
      prompt: prompt,
      temperature: options.temperature,
      maxOutputTokens: options.maxTokens,
    );
  }
}
