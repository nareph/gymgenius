// lib/engines/workout_engine/ai/ai_config.dart

class AIConfig {
  AIConfig._();

  //==============================================================
  // Environment
  //==============================================================

  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isDevelopment => environment == 'development';

  static bool get isStaging => environment == 'staging';

  static bool get isProduction => environment == 'production';

  //==============================================================
  // AI Strategy
  //==============================================================

  /// Local Workout Engine is ALWAYS enabled.
  static const bool useLocalGenerator = true;

  /// Gemini is ONLY used to improve the locally generated program.
  static const bool enableAIOptimization = bool.fromEnvironment(
    'ENABLE_AI_OPTIMIZATION',
    defaultValue: true,
  );

  /// Automatically replace the local program if Gemini generates
  /// a better one.
  static const bool autoReplaceOptimizedProgram = true;

  /// Retry in background if optimization fails.
  static const bool retryOptimization = true;

  /// Maximum optimization attempts.
  static const int retryCount = 2;

  /// Maximum waiting time before falling back to Local Engine.
  static const Duration optimizationTimeout = Duration(seconds: 15);

  //==============================================================
  // Gemini
  //==============================================================

  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  static const String geminiModel = 'gemini-3-flash-preview';

  //==============================================================
  // HTTP
  //==============================================================

  static const Duration connectTimeout = Duration(seconds: 15);

  static const Duration sendTimeout = Duration(seconds: 15);

  static const Duration receiveTimeout = Duration(seconds: 45);

  //==============================================================
  // AI Coach (Phase 7)
  //==============================================================

  static const int coachMaxHistoryMessages = 20;

  static const int coachMaxOutputTokens = 2048;

  static const Duration coachTimeout = Duration(seconds: 30);

  static const bool enableCoachCloud = bool.fromEnvironment(
    'ENABLE_AI_COACH',
    defaultValue: true,
  );

  static bool get canUseCoachCloud => enableCoachCloud && hasGemini;

  //==============================================================
  // Generation
  //==============================================================

  static const int maxInputTokens = 6000;

  static const int maxOutputTokens = 16384;

  static const Duration retryDelay = Duration(seconds: 5);

  //==============================================================
  // Debug
  //==============================================================

  static const bool saveResponseForDebug = true;

  static const int maxPromptLength = 5000;

  //==============================================================
  // Helpers
  //==============================================================

  /// Is Gemini configured?
  static bool get hasGemini => geminiApiKey.trim().isNotEmpty;

  /// Can optimization be used?
  static bool get canOptimize => enableAIOptimization && hasGemini;

  /// Should WorkoutEngine use local generation?
  static bool get shouldUseLocalGenerator => useLocalGenerator;

  /// Environment name.
  static String get environmentName => environment;

  static bool get isConfigured => shouldUseLocalGenerator || canOptimize;
}
