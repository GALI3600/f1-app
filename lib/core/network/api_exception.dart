/// Exception hierarchy for API errors
///
/// Provides typed exceptions for different network failure scenarios:
/// - [NetworkException]: General network connectivity issues
/// - [TimeoutException]: Request timeout
/// - [ServerException]: Server-side errors (4xx, 5xx)
/// - [ParseException]: JSON parsing failures
sealed class ApiException implements Exception {
  const ApiException();

  @override
  String toString() {
    return switch (this) {
      NetworkException(:final message) => 'Network Error: $message',
      TimeoutException() => 'Request Timeout: The request took too long to complete',
      ServerException(:final statusCode, :final message) => 'Server Error [$statusCode]: $message',
      ParseException(:final message) => 'Parse Error: $message',
    };
  }
}

/// Network connectivity error
///
/// Thrown when there's no internet connection or the request fails
/// due to network issues (DNS, connection refused, etc.)
class NetworkException extends ApiException {
  final String message;

  const NetworkException(this.message);
}

/// Request timeout error
///
/// Thrown when a request exceeds the configured timeout duration
/// (default: 30 seconds for both connect and receive)
class TimeoutException extends ApiException {
  const TimeoutException();
}

/// Server-side error
///
/// Thrown for HTTP errors (4xx client errors, 5xx server errors)
///
/// Common status codes:
/// - 400: Bad Request (invalid parameters)
/// - 404: Not Found (invalid endpoint)
/// - 429: Too Many Requests (rate limit exceeded)
/// - 500: Internal Server Error
/// - 503: Service Unavailable
class ServerException extends ApiException {
  final int statusCode;
  final String message;

  const ServerException(this.statusCode, [this.message = '']);
}

/// JSON parsing error
///
/// Thrown when the API response cannot be parsed into the expected model
class ParseException extends ApiException {
  final String message;

  const ParseException(this.message);
}
