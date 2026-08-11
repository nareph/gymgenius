import 'package:gymgenius/engines/ai_coach/providers/coach_request_options.dart';

/// Abstraction over LLM providers for the AI Coach.
///
/// Implementations must not mutate app state or domain engines.
abstract interface class AIProvider {
  String get id;

  bool get isAvailable;

  Future<String> complete({
    required String systemPrompt,
    required String userPrompt,
    CoachRequestOptions options = const CoachRequestOptions(),
  });
}
