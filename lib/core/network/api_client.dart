import 'package:dio/dio.dart';
import 'package:f1sync/core/constants/api_constants.dart';
import 'package:f1sync/core/network/api_exception.dart';
import 'package:f1sync/core/network/rate_limiter.dart';

/// HTTP client for OpenF1 API with retry logic and rate limiting
///
/// Features:
/// - Generic getList<T>() for type-safe list responses
/// - Automatic retry with exponential backoff (3 attempts)
/// - Rate limiting (60 requests/minute)
/// - Comprehensive error handling with typed exceptions
/// - Timeout configuration (30s connect, 30s receive)
///
/// Usage:
/// ```dart
/// final client = OpenF1ApiClient(dio);
/// final drivers = await client.getList<Driver>(
///   endpoint: ApiConstants.drivers,
///   fromJson: Driver.fromJson,
///   queryParameters: {'session_key': 'latest'},
/// );
/// ```
class OpenF1ApiClient {
  final Dio _dio;
  final RateLimiter _rateLimiter;

  /// Maximum number of retry attempts
  static const int maxRetries = 3;

  /// Initial delay for exponential backoff (doubles each retry)
  static const Duration initialRetryDelay = Duration(seconds: 1);

  OpenF1ApiClient(
    this._dio, {
    RateLimiter? rateLimiter,
  }) : _rateLimiter = rateLimiter ?? RateLimiter();

  /// Fetch a list of items from the API
  ///
  /// Type parameter [T] specifies the model type to deserialize to.
  ///
  /// Parameters:
  /// - [endpoint]: API endpoint path (e.g., '/drivers')
  /// - [fromJson]: Factory function to convert JSON map to model instance
  /// - [queryParameters]: Optional query parameters for filtering/pagination (preferred)
  /// - [queryParams]: Alias for queryParameters (for backwards compatibility)
  ///
  /// Returns a list of [T] instances.
  ///
  /// Throws:
  /// - [NetworkException] for connectivity issues
  /// - [TimeoutException] for request timeouts
  /// - [ServerException] for HTTP errors (4xx, 5xx)
  /// - [ParseException] for JSON parsing failures
  Future<List<T>> getList<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? queryParams,
  }) async {
    // Wait if we've hit the rate limit
    await _rateLimiter.waitIfNeeded();

    // Use queryParams if provided, otherwise use queryParameters
    final params = queryParams ?? queryParameters;

    return await _retryRequest(
      () => _getListInternal(
        endpoint: endpoint,
        fromJson: fromJson,
        queryParameters: params,
      ),
    );
  }

  /// Internal method to fetch list (called by retry logic)
  Future<List<T>> _getListInternal<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      // Handle successful response
      if (response.data is List) {
        return (response.data as List)
            .map((json) => fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Empty or non-list response
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      // Catch parsing errors
      throw ParseException('Failed to parse response: $e');
    }
  }

  /// Retry logic with exponential backoff
  ///
  /// Retries only for:
  /// - Network errors (connectivity issues)
  /// - Timeout errors
  ///
  /// Does NOT retry for:
  /// - 4xx client errors (bad request, not found, etc.)
  /// - Parse errors
  ///
  /// Backoff delays: 1s, 2s, 4s
  Future<T> _retryRequest<T>(Future<T> Function() request) async {
    int attempts = 0;
    Duration delay = initialRetryDelay;

    while (true) {
      try {
        return await request();
      } on ApiException catch (e) {
        attempts++;

        // Check if we should retry
        final shouldRetry = _shouldRetryError(e) && attempts < maxRetries;

        if (!shouldRetry) {
          rethrow;
        }

        // Wait before retrying (exponential backoff)
        await Future.delayed(delay);
        delay *= 2; // Double the delay for next attempt
      }
    }
  }

  /// Determine if an error should trigger a retry
  bool _shouldRetryError(ApiException error) {
    return switch (error) {
      NetworkException() => true, // Retry network errors
      TimeoutException() => true, // Retry timeouts
      ServerException(:final statusCode) => statusCode >= 500, // Retry 5xx only
      ParseException() => false, // Don't retry parse errors
    };
  }

  /// Convert DioException to typed ApiException
  ApiException _handleError(DioException error) {
    return switch (error.type) {
      // Connection/network errors
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutException(),

      // Network connectivity errors
      DioExceptionType.connectionError =>
        NetworkException(error.message ?? 'Connection failed'),

      // HTTP errors (4xx, 5xx)
      DioExceptionType.badResponse => ServerException(
          error.response?.statusCode ?? 500,
          error.response?.statusMessage ?? 'Server error',
        ),

      // Request cancellation
      DioExceptionType.cancel => const NetworkException('Request cancelled'),

      // Unknown/other errors
      DioExceptionType.unknown ||
      DioExceptionType.badCertificate =>
        NetworkException(error.message ?? 'Unknown error occurred'),
    };
  }

  /// Get a single item from the API (convenience method)
  ///
  /// Useful for endpoints that return a single object or for getting
  /// the first item from a filtered list.
  Future<T?> getOne<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    final list = await getList<T>(
      endpoint: endpoint,
      fromJson: fromJson,
      queryParameters: queryParameters,
    );

    return list.isEmpty ? null : list.first;
  }

  /// Alias for getOne() to match data source interface
  ///
  /// This method exists for backwards compatibility with data sources
  /// that use the getSingle naming convention.
  Future<T?> getSingle<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParams,
  }) async {
    return getOne<T>(
      endpoint: endpoint,
      fromJson: fromJson,
      queryParameters: queryParams,
    );
  }

  /// Get the current rate limiter instance (useful for testing/debugging)
  RateLimiter get rateLimiter => _rateLimiter;
}
