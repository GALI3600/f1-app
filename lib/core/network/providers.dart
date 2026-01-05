import 'package:dio/dio.dart';
import 'package:f1sync/core/constants/api_constants.dart';
import 'package:f1sync/core/network/api_client.dart';
import 'package:f1sync/core/network/api_interceptor.dart';
import 'package:f1sync/core/network/rate_limiter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Provides the Dio HTTP client instance
///
/// Configured with:
/// - Base URL from ApiConstants
/// - 30s timeout for connect and receive
/// - Request timestamp interceptor
/// - API logging interceptor (debug mode only)
@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.timeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.timeout),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Add interceptors
  dio.interceptors.addAll([
    RequestTimestampInterceptor(),
    ApiInterceptor(),
  ]);

  // Clean up when provider is disposed
  ref.onDispose(() {
    dio.close();
  });

  return dio;
}

/// Provides the RateLimiter instance (singleton)
///
/// Enforces rate limits:
/// - 2 requests per second (OpenF1 API limit)
/// - 60 requests per minute (safety net)
///
/// Uses keepAlive: true to ensure the same rate limiter is shared
/// across all API client instances and persists across navigation.
@Riverpod(keepAlive: true)
RateLimiter rateLimiter(RateLimiterRef ref) {
  return RateLimiter();
}

/// Provides the OpenF1 API client instance
///
/// Dependencies:
/// - Dio HTTP client
/// - RateLimiter
///
/// Usage:
/// ```dart
/// final apiClient = ref.watch(apiClientProvider);
/// final drivers = await apiClient.getList<Driver>(
///   endpoint: ApiConstants.drivers,
///   fromJson: Driver.fromJson,
/// );
/// ```
@riverpod
OpenF1ApiClient apiClient(ApiClientRef ref) {
  final dio = ref.watch(dioProvider);
  final rateLimiter = ref.watch(rateLimiterProvider);

  return OpenF1ApiClient(
    dio,
    rateLimiter: rateLimiter,
  );
}
