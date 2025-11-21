import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Custom Dio interceptor for API request/response logging
///
/// Only logs in debug mode to avoid performance overhead and sensitive
/// data leakage in production.
///
/// Logs:
/// - Request details (method, URL, headers, body)
/// - Response details (status, data)
/// - Errors
///
/// Usage:
/// ```dart
/// dio.interceptors.add(ApiInterceptor());
/// ```
class ApiInterceptor extends Interceptor {
  final Logger _logger;

  /// Create interceptor with optional custom logger
  ApiInterceptor({Logger? logger})
      : _logger = logger ??
            Logger(
              printer: PrettyPrinter(
                methodCount: 0,
                errorMethodCount: 5,
                lineLength: 80,
                colors: true,
                printEmojis: true,
                dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
              ),
            );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only log in debug mode
    if (kDebugMode) {
      _logger.d(
        '┌─────────────────────────────────────────────────────\n'
        '│ REQUEST\n'
        '├─────────────────────────────────────────────────────\n'
        '│ Method: ${options.method}\n'
        '│ URL: ${options.uri}\n'
        '│ Headers:\n${_formatMap(options.headers)}'
        '${options.data != null ? '│ Body: ${options.data}\n' : ''}'
        '└─────────────────────────────────────────────────────',
      );
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only log in debug mode
    if (kDebugMode) {
      // Truncate large responses for readability
      final responseData = _truncateData(response.data);

      _logger.i(
        '┌─────────────────────────────────────────────────────\n'
        '│ RESPONSE\n'
        '├─────────────────────────────────────────────────────\n'
        '│ Status: ${response.statusCode} ${response.statusMessage}\n'
        '│ URL: ${response.requestOptions.uri}\n'
        '│ Duration: ${_getDuration(response)}\n'
        '│ Data: $responseData\n'
        '└─────────────────────────────────────────────────────',
      );
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Only log in debug mode
    if (kDebugMode) {
      _logger.e(
        '┌─────────────────────────────────────────────────────\n'
        '│ ERROR\n'
        '├─────────────────────────────────────────────────────\n'
        '│ Type: ${err.type}\n'
        '│ URL: ${err.requestOptions.uri}\n'
        '│ Status: ${err.response?.statusCode}\n'
        '│ Message: ${err.message}\n'
        '${err.response?.data != null ? '│ Data: ${err.response?.data}\n' : ''}'
        '└─────────────────────────────────────────────────────',
        error: err,
        stackTrace: err.stackTrace,
      );
    }

    super.onError(err, handler);
  }

  /// Format map entries with indentation
  String _formatMap(Map<String, dynamic> map) {
    if (map.isEmpty) return '';

    final buffer = StringBuffer();
    map.forEach((key, value) {
      buffer.writeln('│   $key: $value');
    });
    return buffer.toString();
  }

  /// Truncate large data for readability
  String _truncateData(dynamic data) {
    final dataString = data.toString();
    const maxLength = 500;

    if (dataString.length <= maxLength) {
      return dataString;
    }

    // For lists, show count
    if (data is List) {
      return '[List with ${data.length} items] (truncated)';
    }

    // For other data, show preview
    return '${dataString.substring(0, maxLength)}... (truncated)';
  }

  /// Calculate request duration
  String _getDuration(Response response) {
    final start = response.requestOptions.extra['request_start_time'];
    if (start is DateTime) {
      final duration = DateTime.now().difference(start);
      return '${duration.inMilliseconds}ms';
    }
    return 'unknown';
  }
}

/// Interceptor to add request timestamp for duration calculation
class RequestTimestampInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['request_start_time'] = DateTime.now();
    super.onRequest(options, handler);
  }
}
