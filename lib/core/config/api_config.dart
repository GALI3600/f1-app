import 'package:f1sync/core/constants/api_constants.dart';

/// API Configuration for OpenF1
/// Centralizes API settings and provides helper methods
class ApiConfig {
  ApiConfig._();

  // ========== Base Configuration ==========

  /// Base URL for all API requests
  static String get baseUrl => ApiConstants.baseUrl;

  /// Connection timeout in milliseconds
  static int get connectionTimeout => ApiConstants.timeout;

  /// Receive timeout in milliseconds
  static int get receiveTimeout => ApiConstants.timeout;

  /// Send timeout in milliseconds
  static int get sendTimeout => ApiConstants.timeout;

  // ========== Rate Limiting ==========

  /// Maximum requests per minute (client-side rate limiting)
  static int get maxRequestsPerMinute => ApiConstants.rateLimitPerMinute;

  /// Delay between requests to avoid rate limiting (in milliseconds)
  static int get requestDelay => (60000 / maxRequestsPerMinute).floor();

  // ========== Headers ==========

  /// Default headers for API requests
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Headers for CSV requests
  static Map<String, String> get csvHeaders => {
        'Content-Type': 'text/csv',
        'Accept': 'text/csv',
      };

  // ========== Retry Configuration ==========

  /// Number of retry attempts for failed requests
  static const int maxRetries = 3;

  /// Delay between retries in milliseconds
  static const int retryDelay = 1000;

  /// HTTP status codes that should trigger a retry
  static const List<int> retryStatusCodes = [
    408, // Request Timeout
    429, // Too Many Requests
    500, // Internal Server Error
    502, // Bad Gateway
    503, // Service Unavailable
    504, // Gateway Timeout
  ];

  // ========== Cache Configuration ==========

  /// Enable caching globally
  static const bool enableCache = true;

  /// Maximum cache size in MB
  static const int maxCacheSizeMB = 100;

  /// Cache directory name
  static const String cacheDirectory = 'f1sync_cache';

  // ========== Logging ==========

  /// Enable request/response logging
  static const bool enableLogging = true;

  /// Enable detailed logging (includes request/response bodies)
  static const bool enableDetailedLogging = false;

  // ========== Endpoint-Specific Settings ==========

  /// Build full URL for an endpoint
  static String buildUrl(String endpoint, {Map<String, dynamic>? queryParameters}) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: _sanitizeQueryParams(queryParameters)).toString();
    }
    return uri.toString();
  }

  /// Sanitize query parameters (remove null values, convert to string)
  static Map<String, dynamic> _sanitizeQueryParams(Map<String, dynamic> params) {
    final sanitized = <String, dynamic>{};
    params.forEach((key, value) {
      if (value != null) {
        sanitized[key] = value.toString();
      }
    });
    return sanitized;
  }

  // ========== Environment Detection ==========

  /// Check if running in development mode
  static bool get isDevelopment {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  /// Check if running in production mode
  static bool get isProduction => !isDevelopment;

  // ========== API Status ==========

  /// OpenF1 API status page URL
  static const String statusPageUrl = 'https://status.openf1.org';

  /// OpenF1 API documentation URL
  static const String documentationUrl = 'https://openf1.org';

  // ========== Helper Methods ==========

  /// Get timeout for specific operation type
  static Duration getTimeout(TimeoutType type) {
    switch (type) {
      case TimeoutType.connection:
        return Duration(milliseconds: connectionTimeout);
      case TimeoutType.receive:
        return Duration(milliseconds: receiveTimeout);
      case TimeoutType.send:
        return Duration(milliseconds: sendTimeout);
    }
  }

  /// Check if request should be cached based on endpoint
  static bool shouldCache(String endpoint) {
    return enableCache && ApiConstants.getCacheTTL(endpoint) > Duration.zero;
  }

  /// Get cache key for request
  static String getCacheKey({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) {
    final params = queryParameters ?? {};
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final paramsString = sortedParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '${endpoint}_$paramsString';
  }
}

/// Timeout types for different operations
enum TimeoutType {
  connection,
  receive,
  send,
}
