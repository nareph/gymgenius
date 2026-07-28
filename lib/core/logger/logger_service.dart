// lib/services/logger_service.dart
import 'package:logger/logger.dart';

class Log {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
    filter: ProductionFilter(),
  );

  // Helper method to format messages with tags
  static String _formatMessage(String message, {String? tag}) {
    if (tag != null && tag.isNotEmpty) {
      return '[$tag] $message';
    }
    return message;
  }

  static void trace(String message,
      {dynamic error, StackTrace? stackTrace, String? tag}) {
    _logger.t(_formatMessage(message, tag: tag),
        error: error, stackTrace: stackTrace);
  }

  static void debug(String message,
      {dynamic error, StackTrace? stackTrace, String? tag}) {
    _logger.d(_formatMessage(message, tag: tag),
        error: error, stackTrace: stackTrace);
  }

  static void info(String message,
      {dynamic error, StackTrace? stackTrace, String? tag}) {
    _logger.i(_formatMessage(message, tag: tag),
        error: error, stackTrace: stackTrace);
  }

  static void warning(String message,
      {dynamic error, StackTrace? stackTrace, String? tag}) {
    _logger.w(_formatMessage(message, tag: tag),
        error: error, stackTrace: stackTrace);
  }

  static void error(String message,
      {dynamic error, StackTrace? stackTrace, String? tag}) {
    _logger.e(_formatMessage(message, tag: tag),
        error: error, stackTrace: stackTrace);
  }

  static void fatal(String message,
      {dynamic error, StackTrace? stackTrace, String? tag}) {
    _logger.f(_formatMessage(message, tag: tag),
        error: error, stackTrace: stackTrace);
  }

  static String enumToString(dynamic enumValue) {
    return enumValue != null ? enumValue.toString().split('.').last : 'null';
  }

  static void apiRequest({
    required String method,
    required String url,
    dynamic body,
    Map<String, dynamic>? headers,
    String? tag,
  }) {
    _logger.d(_formatMessage('API Request', tag: tag), error: {
      'method': method,
      'url': url,
      'body': body,
      'headers': headers,
    });
  }

  static void apiResponse({
    required String method,
    required String url,
    required int statusCode,
    dynamic response,
    int? durationMs,
    String? tag,
  }) {
    _logger.i(_formatMessage('API Response', tag: tag), error: {
      'method': method,
      'url': url,
      'statusCode': statusCode,
      'response': response is String ? response : response.toString(),
      'durationMs': durationMs,
    });
  }
}

class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    const bool isReleaseMode = bool.fromEnvironment('dart.vm.product');
    if (isReleaseMode) {
      return event.level.index >= Level.warning.index;
    }
    return true;
  }
}
