// lib/config/ai_config.dart
class AIConfig {
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
// Gemini model - using latest flash model for better performance
  static const String geminiModel = 'gemini-3-flash-preview';
// Network timeouts
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 180);
// Token limits - optimized for 5-day routines
  static const int maxInputTokens = 6000;
  static const int maxOutputTokens =
      8192; // Increased for complete 5-day routines
// Retry settings
  static const int maxRetries = 2;
  static const Duration retryDelay = Duration(seconds: 5);
// Debug settings
  static const bool saveResponseForDebug = true;
  static const int maxPromptLength = 5000; // Force prompt optimization
  static bool get useRealAI {
    switch (environment) {
      case 'production':
      case 'staging':
        return geminiApiKey.isNotEmpty;
      case 'development':
      default:
        return const bool.fromEnvironment('USE_REAL_AI', defaultValue: false);
    }
  }

  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';
  static String get environmentName => environment;
  static bool get isConfigured {
    if (useRealAI) {
      return geminiApiKey.isNotEmpty;
    }
    return true;
  }
}
