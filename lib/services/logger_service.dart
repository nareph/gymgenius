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

  static void trace(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  static void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  static String enumToString(dynamic enumValue) {
    return enumValue != null ? enumValue.toString().split('.').last : 'null';
  }

  static void apiRequest({
    required String method,
    required String url,
    dynamic body,
    Map<String, dynamic>? headers,
  }) {
    _logger.d('API Request', error: {
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
  }) {
    _logger.i('API Response', error: {
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
