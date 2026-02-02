// lib/services/ai/api/gemini_api_client.dart
import 'package:dio/dio.dart';
import 'package:gymgenius/config/ai_config.dart';
import 'package:gymgenius/services/ai/json_repair_service.dart';
import 'package:gymgenius/services/logger_service.dart';

/// Service for making calls to Google's Gemini API using Dio
class GeminiAPIClient {
  late final Dio _dio;
  final JsonRepairService _jsonRepairService = JsonRepairService();
  static const _tag = 'GeminiAPI';
  GeminiAPIClient({Dio? dio}) {
    _dio = dio ?? _createDio();
  }
  Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AIConfig.geminiBaseUrl,
      connectTimeout: AIConfig.connectTimeout,
      sendTimeout: AIConfig.sendTimeout,
      receiveTimeout: AIConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));
// Add logging interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        Log.debug('Request: ${options.method} ${options.path}', tag: _tag);
        return handler.next(options);
      },
      onResponse: (response, handler) {
        Log.debug('Response: ${response.statusCode}', tag: _tag);
        return handler.next(response);
      },
      onError: (error, handler) {
        Log.error('Error: ${error.message}', tag: _tag, error: error);
        return handler.next(error);
      },
    ));

// Add retry interceptor
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      retries: AIConfig.maxRetries,
      retryDelays: List.generate(
        AIConfig.maxRetries,
        (i) => AIConfig.retryDelay * (i + 1),
      ),
    ));

    return dio;
  }

  /// Generate content using Gemini API
  Future<String> generateContent({
    required String prompt,
    double temperature = 0.7,
    int maxOutputTokens = 8192,
  }) async {
    try {
      final startTime = DateTime.now();
      Log.debug('Sending request', tag: _tag);
      Log.debug('Model: ${AIConfig.geminiModel}', tag: _tag);
      Log.debug('Prompt: ${prompt.length} chars', tag: _tag);
      Log.debug('MaxOutputTokens: $maxOutputTokens', tag: _tag);
      final response = await _dio.post(
        '/models/${AIConfig.geminiModel}:generateContent',
        queryParameters: {'key': AIConfig.geminiApiKey},
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': temperature,
            'maxOutputTokens': maxOutputTokens,
            'topP': 0.95,
            'topK': 64,
          },
          'safetySettings': [
            {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_NONE'},
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_NONE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_NONE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_NONE'
            },
          ],
        },
      );

      final duration = DateTime.now().difference(startTime);
      Log.debug('Response in ${duration.inSeconds}s', tag: _tag);

      // Extract text from response
      final candidates = response.data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw GeminiAPIException('No candidates in response');
      }

      final candidate = candidates[0] as Map<String, dynamic>;

      // Check finish reason
      final finishReason = candidate['finishReason'] as String?;
      if (finishReason == 'MAX_TOKENS') {
        Log.warning('Response hit MAX_TOKENS limit', tag: _tag);
      }

      final content = candidate['content'] as Map<String, dynamic>?;
      if (content == null) {
        throw GeminiAPIException('No content in candidate');
      }

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        throw GeminiAPIException('No parts in content');
      }

      final text = (parts[0] as Map<String, dynamic>)['text'] as String?;
      if (text == null || text.isEmpty) {
        throw GeminiAPIException('Empty text in response');
      }

      Log.debug('Received ${text.length} chars', tag: _tag);
      return text;
    } on DioException catch (e) {
      Log.error('Dio error', tag: _tag, error: e);
      throw GeminiAPIException(_handleDioError(e));
    } catch (e) {
      Log.error('Unexpected error', tag: _tag, error: e);
      throw GeminiAPIException('Unexpected error: $e');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timeout. Check internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?.toString() ?? 'Unknown error';
        return 'API error ($statusCode): $message';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error. Check internet connection.';
      default:
        return 'Network error: ${e.message}';
    }
  }

  /// Parse JSON response from Gemini with advanced error recovery
  Map<String, dynamic> parseJsonResponse(String text) {
    try {
      Log.debug('Parsing JSON (${text.length} chars)', tag: _tag);
// Use the advanced JSON repair service
      final parsed = _jsonRepairService.parseJsonWithRepair(
        text,
        'workout routine',
      );

      Log.debug('JSON parse successful', tag: _tag);
      return parsed;
    } catch (e, s) {
      Log.error('JSON parse failed', tag: _tag, error: e, stackTrace: s);
      throw GeminiAPIException('Failed to parse JSON: $e');
    }
  }

  void dispose() {
    _dio.close();
  }
}

/// Retry interceptor for Dio
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;
  RetryInterceptor({
    required this.dio,
    required this.retries,
    required this.retryDelays,
  });
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] ?? 0;
    if (retryCount >= retries) {
      return handler.next(err);
    }

// Only retry on specific errors
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    Log.debug('Retrying (${retryCount + 1}/$retries)', tag: 'RetryInterceptor');

    await Future.delayed(
      retryDelays[retryCount.clamp(0, retryDelays.length - 1)],
    );

    try {
      final options = err.requestOptions;
      options.extra['retryCount'] = retryCount + 1;

      final response = await dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}

/// Custom exception for Gemini API errors
class GeminiAPIException implements Exception {
  final String message;
  GeminiAPIException(this.message);
  @override
  String toString() => 'GeminiAPIException: $message';
}
