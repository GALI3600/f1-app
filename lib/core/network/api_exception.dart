import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_exception.freezed.dart';

/// API Exception for handling errors from OpenF1 API
@freezed
class ApiException with _$ApiException implements Exception {
  const factory ApiException.network(String message) = NetworkException;
  const factory ApiException.timeout() = TimeoutException;
  const factory ApiException.server(int statusCode) = ServerException;
  const factory ApiException.parse(String message) = ParseException;

  const ApiException._();

  /// Get user-friendly error message
  String get userMessage {
    return when(
      network: (message) => 'Network error: $message',
      timeout: () => 'Request timed out. Please try again.',
      server: (code) {
        switch (code) {
          case 400:
            return 'Bad request. Please check your query.';
          case 404:
            return 'Data not found.';
          case 500:
            return 'Server error. Please try again later.';
          case 503:
            return 'Service unavailable. Please try again later.';
          default:
            return 'Server error ($code). Please try again.';
        }
      },
      parse: (message) => 'Failed to process data: $message',
    );
  }

  /// Check if error is network related
  bool get isNetworkError => maybeWhen(
        network: (_) => true,
        timeout: () => true,
        orElse: () => false,
      );

  /// Check if error is server related
  bool get isServerError => maybeWhen(
        server: (_) => true,
        orElse: () => false,
      );
}
