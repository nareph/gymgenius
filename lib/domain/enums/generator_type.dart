enum GeneratorType {
  local,
  gemini,
  openAi,
  claude,
  custom,
}

extension GeneratorTypeExtension on GeneratorType {
  String get displayName {
    switch (this) {
      case GeneratorType.local:
        return 'Local Engine';
      case GeneratorType.gemini:
        return 'Gemini AI';
      case GeneratorType.openAi:
        return 'OpenAI';
      case GeneratorType.claude:
        return 'Claude';
      case GeneratorType.custom:
        return 'Custom';
    }
  }

  String get value {
    switch (this) {
      case GeneratorType.local:
        return 'local';
      case GeneratorType.gemini:
        return 'gemini';
      case GeneratorType.openAi:
        return 'openai';
      case GeneratorType.claude:
        return 'claude';
      case GeneratorType.custom:
        return 'custom';
    }
  }

  static GeneratorType fromValue(String value) {
    return GeneratorType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GeneratorType.local,
    );
  }
}
