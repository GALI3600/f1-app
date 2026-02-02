import 'package:dio/dio.dart';
import 'package:f1sync/core/constants/jolpica_constants.dart';
import 'package:f1sync/core/network/api_interceptor.dart';
import 'package:f1sync/core/network/jolpica_api_client.dart';
import 'package:f1sync/core/network/rate_limiter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Provides the RateLimiter instance (singleton)
///
/// Enforces rate limits:
/// - 200 requests per hour (Jolpica API limit)
///
/// Uses keepAlive: true to ensure the same rate limiter is shared
/// across all API client instances and persists across navigation.
@Riverpod(keepAlive: true)
RateLimiter rateLimiter(RateLimiterRef ref) {
  return RateLimiter();
}

/// Provides the Dio HTTP client for Jolpica API
@riverpod
Dio jolpicaDio(JolpicaDioRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: JolpicaConstants.baseUrl,
      connectTimeout: Duration(milliseconds: JolpicaConstants.timeout),
      receiveTimeout: Duration(milliseconds: JolpicaConstants.timeout),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    RequestTimestampInterceptor(),
    ApiInterceptor(),
  ]);

  ref.onDispose(() {
    dio.close();
  });

  return dio;
}

/// Provides the Jolpica API client instance
///
/// Usage:
/// ```dart
/// final apiClient = ref.watch(jolpicaApiClientProvider);
/// final drivers = await apiClient.getDrivers<Driver>(
///   fromJson: Driver.fromJolpica,
///   season: 'current',
/// );
/// ```
@riverpod
JolpicaApiClient jolpicaApiClient(JolpicaApiClientRef ref) {
  final dio = ref.watch(jolpicaDioProvider);
  final rateLimiter = ref.watch(rateLimiterProvider);

  return JolpicaApiClient(
    dio,
    rateLimiter: rateLimiter,
  );
}
