// lib/engines/workout_engine/ai/api/gemini_api_client.dart

import 'package:dio/dio.dart';
import 'package:gymgenius/core/logger/logger_service.dart';

import '../ai_config.dart';
import '../repair/json_repair_service.dart';

class GeminiAPIClient {
  static const _tag = 'GeminiAPI';

  late final Dio _dio;

  final JsonRepairService _jsonRepairService = JsonRepairService();

  GeminiAPIClient({Dio? dio}) {
    _dio = dio ?? _createDio();
  }

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AIConfig.geminiBaseUrl,
        connectTimeout: AIConfig.connectTimeout,
        sendTimeout: AIConfig.sendTimeout,
        receiveTimeout: AIConfig.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          Log.debug(
            '➡ ${options.method} ${options.path}',
            tag: _tag,
          );

          return handler.next(options);
        },
        onResponse: (response, handler) {
          Log.debug(
            '⬅ ${response.statusCode}',
            tag: _tag,
          );

          return handler.next(response);
        },
        onError: (error, handler) {
          Log.error(
            error.message ?? 'Unknown error',
            tag: _tag,
            error: error,
          );

          return handler.next(error);
        },
      ),
    );

    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        retries: AIConfig.retryCount,
        retryDelay: AIConfig.retryDelay,
      ),
    );

    return dio;
  }

  //==========================================================
  // Generate Content
  //==========================================================

  Future<String> generateContent({
    required String prompt,
    double temperature = 0.4,
    int? maxOutputTokens,
  }) async {
    if (!AIConfig.canOptimize) {
      throw GeminiAPIException(
        'AI optimization is disabled.',
      );
    }

    return generateText(
      prompt: prompt,
      temperature: temperature,
      maxOutputTokens: maxOutputTokens,
    );
  }

  /// Generic text generation for AI Coach (requires API key only).
  Future<String> generateText({
    required String prompt,
    double temperature = 0.4,
    int? maxOutputTokens,
  }) async {
    if (AIConfig.geminiApiKey.isEmpty) {
      throw GeminiAPIException(
        'Gemini API key not configured.',
      );
    }

    final start = DateTime.now();

    Log.debug(
      'Generating content...',
      tag: _tag,
    );

    try {
      final response = await _dio.post(
        '/models/${AIConfig.geminiModel}:generateContent',
        queryParameters: {
          'key': AIConfig.geminiApiKey,
        },
        data: {
          "contents": [
            {
              "parts": [
                {
                  "text": prompt,
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": temperature,
            "topP": 0.95,
            "topK": 40,
            "maxOutputTokens": maxOutputTokens ?? AIConfig.maxOutputTokens,
          },
          "safetySettings": [
            {
              "category": "HARM_CATEGORY_HARASSMENT",
              "threshold": "BLOCK_NONE",
            },
            {
              "category": "HARM_CATEGORY_HATE_SPEECH",
              "threshold": "BLOCK_NONE",
            },
            {
              "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
              "threshold": "BLOCK_NONE",
            },
            {
              "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
              "threshold": "BLOCK_NONE",
            },
          ],
        },
      );

      final duration = DateTime.now().difference(start);

      Log.debug(
        'Generation completed in ${duration.inMilliseconds} ms',
        tag: _tag,
      );

      return _extractText(response.data);
    } on DioException catch (e) {
      throw GeminiAPIException(
        _handleNetworkError(e),
      );
    }
  }

  //==========================================================
  // Extract Gemini Response
  //==========================================================

  String _extractText(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List<dynamic>?;

    if (candidates == null || candidates.isEmpty) {
      throw GeminiAPIException(
        'Gemini returned no candidates.',
      );
    }

    final candidate = candidates.first as Map<String, dynamic>;

    final finishReason = candidate['finishReason'] as String?;

    if (finishReason == 'MAX_TOKENS') {
      Log.warning(
        'Gemini response reached MAX_TOKENS.',
        tag: _tag,
      );
    }

    final content = candidate['content'] as Map<String, dynamic>?;

    if (content == null) {
      throw GeminiAPIException(
        'Gemini returned an empty content.',
      );
    }

    final parts = content['parts'] as List<dynamic>?;

    if (parts == null || parts.isEmpty) {
      throw GeminiAPIException(
        'Gemini returned no content parts.',
      );
    }

    final first = parts.first as Map<String, dynamic>;

    final text = first['text'] as String?;

    if (text == null || text.trim().isEmpty) {
      throw GeminiAPIException(
        'Gemini returned empty text.',
      );
    }

    Log.debug(
      'Received ${text.length} characters.',
      tag: _tag,
    );

    return text;
  }

  //==========================================================
  // Network Error Handling
  //==========================================================

  String _handleNetworkError(
    DioException error,
  ) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout.';

      case DioExceptionType.sendTimeout:
        return 'Send timeout.';

      case DioExceptionType.receiveTimeout:
        return 'Receive timeout.';

      case DioExceptionType.connectionError:
        return 'Unable to connect to Gemini servers.';

      case DioExceptionType.cancel:
        return 'Request cancelled.';

      case DioExceptionType.badResponse:
        final code = error.response?.statusCode ?? 0;

        final body = error.response?.data.toString() ?? '';

        return 'Gemini API Error ($code): $body';

      default:
        return error.message ?? 'Unknown network error.';
    }
  }

  //==========================================================
  // JSON Parsing
  //==========================================================

  Map<String, dynamic> parseJsonResponse(
    String response,
  ) {
    try {
      Log.debug(
        'Repairing JSON...',
        tag: _tag,
      );

      final json = _jsonRepairService.parseJsonWithRepair(
        response,
        'optimized workout program',
      );

      Log.debug(
        'JSON repaired successfully.',
        tag: _tag,
      );

      return json;
    } catch (e, s) {
      Log.error(
        'Unable to parse Gemini JSON.',
        tag: _tag,
        error: e,
        stackTrace: s,
      );

      throw GeminiAPIException(
        'Failed to parse Gemini JSON.\n$e',
      );
    }
  }

  //==========================================================
  // Dispose
  //==========================================================

  void dispose() {
    _dio.close(force: true);
  }
}

//==============================================================
// Retry Interceptor
//==============================================================

class RetryInterceptor extends Interceptor {
  final Dio dio;

  final int retries;

  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    required this.retries,
    required this.retryDelay,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retry = err.requestOptions.extra['retry'] ?? 0;

    if (retry >= retries) {
      return handler.next(err);
    }

    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    Log.warning(
      'Retry ${retry + 1}/$retries...',
      tag: 'RetryInterceptor',
    );

    await Future.delayed(retryDelay);

    try {
      final options = err.requestOptions;

      options.extra['retry'] = retry + 1;

      final response = await dio.fetch(options);

      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;

        // Retry only on temporary server errors
        return statusCode >= 500;

      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }
}

//==============================================================
// Gemini API Exception
//==============================================================

class GeminiAPIException implements Exception {
  final String message;

  const GeminiAPIException(this.message);

  @override
  String toString() => 'GeminiAPIException: $message';
}
