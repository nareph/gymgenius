/// Options for a single AI completion request.
class CoachRequestOptions {
  final double temperature;
  final int maxTokens;
  final Duration timeout;

  const CoachRequestOptions({
    this.temperature = 0.4,
    this.maxTokens = 1024,
    this.timeout = const Duration(seconds: 30),
  });
}
