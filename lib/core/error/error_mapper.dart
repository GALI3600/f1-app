import 'package:flutter/material.dart';
import 'package:f1sync/core/network/api_exception.dart';
import 'package:f1sync/shared/widgets/error_widget.dart';

/// Utility for mapping exceptions to F1ErrorWidget variants
///
/// Provides centralized error mapping logic to ensure consistent
/// error presentation throughout the app.
///
/// Usage:
/// ```dart
/// // In a widget's error state:
/// error: (error, _) => ErrorMapper.mapToWidget(
///   error,
///   onRetry: () => ref.invalidate(someProvider),
/// )
/// ```
class ErrorMapper {
  ErrorMapper._();

  /// Map an exception to an F1ErrorWidget
  ///
  /// Returns the appropriate F1ErrorWidget variant based on the exception type.
  static Widget mapToWidget(
    Object error, {
    VoidCallback? onRetry,
    bool showDetails = false,
  }) {
    final errorDetails = showDetails ? error.toString() : null;

    if (error is ApiException) {
      return _mapApiException(
        error,
        onRetry: onRetry,
        errorDetails: errorDetails,
      );
    }

    // Generic error for unknown types
    return F1ErrorWidget.generic(
      onRetry: onRetry,
      errorDetails: errorDetails,
      showDetails: showDetails,
    );
  }

  /// Map ApiException to appropriate F1ErrorWidget variant
  static Widget _mapApiException(
    ApiException exception, {
    VoidCallback? onRetry,
    String? errorDetails,
  }) {
    return switch (exception) {
      NetworkException() => F1ErrorWidget.network(
          onRetry: onRetry,
          errorDetails: errorDetails,
          showDetails: errorDetails != null,
        ),
      TimeoutException() => F1ErrorWidget.timeout(
          onRetry: onRetry,
          errorDetails: errorDetails,
          showDetails: errorDetails != null,
        ),
      ServerException(:final statusCode) => _mapServerException(
          statusCode,
          onRetry: onRetry,
          errorDetails: errorDetails,
        ),
      ParseException() => F1ErrorWidget.server(
          title: 'Data Error',
          message: 'Failed to process server response. Please try again.',
          onRetry: onRetry,
          errorDetails: errorDetails,
          showDetails: errorDetails != null,
        ),
    };
  }

  /// Map server status codes to appropriate F1ErrorWidget variant
  static Widget _mapServerException(
    int statusCode, {
    VoidCallback? onRetry,
    String? errorDetails,
  }) {
    return switch (statusCode) {
      401 || 403 => F1ErrorWidget.unauthorized(
          onRetry: onRetry,
          errorDetails: errorDetails,
          showDetails: errorDetails != null,
        ),
      404 => F1ErrorWidget.notFound(
          onRetry: onRetry,
          errorDetails: errorDetails,
          showDetails: errorDetails != null,
        ),
      429 => F1ErrorWidget.rateLimited(
          onRetry: onRetry,
          errorDetails: errorDetails,
          showDetails: errorDetails != null,
        ),
      >= 500 && < 600 => F1ErrorWidget.server(
          onRetry: onRetry,
          errorDetails: errorDetails,
          showDetails: errorDetails != null,
        ),
      _ => F1ErrorWidget.server(
          title: 'Request Failed',
          message: 'Request failed with status $statusCode',
          onRetry: onRetry,
          errorDetails: errorDetails,
          showDetails: errorDetails != null,
        ),
    };
  }

  /// Get a user-friendly error message for an exception
  ///
  /// Returns a short, user-friendly message suitable for snackbars or toasts.
  static String getErrorMessage(Object error) {
    if (error is ApiException) {
      return _getApiExceptionMessage(error);
    }

    return 'An unexpected error occurred';
  }

  /// Get user-friendly message for ApiException
  static String _getApiExceptionMessage(ApiException exception) {
    return switch (exception) {
      NetworkException() => 'No internet connection',
      TimeoutException() => 'Request timed out',
      ServerException(:final statusCode) => _getServerErrorMessage(statusCode),
      ParseException() => 'Failed to process response',
    };
  }

  /// Get user-friendly message for server error status codes
  static String _getServerErrorMessage(int statusCode) {
    return switch (statusCode) {
      401 => 'Authentication required',
      403 => 'Access denied',
      404 => 'Not found',
      429 => 'Too many requests',
      >= 500 && < 600 => 'Server error',
      _ => 'Request failed ($statusCode)',
    };
  }

  /// Get an icon for an exception
  ///
  /// Returns an appropriate icon for the exception type.
  static IconData getErrorIcon(Object error) {
    if (error is ApiException) {
      return switch (error) {
        NetworkException() => Icons.wifi_off_rounded,
        TimeoutException() => Icons.schedule_outlined,
        ServerException(:final statusCode) => _getServerErrorIcon(statusCode),
        ParseException() => Icons.error_outline_rounded,
      };
    }

    return Icons.error_outline_rounded;
  }

  /// Get an icon for server error status codes
  static IconData _getServerErrorIcon(int statusCode) {
    return switch (statusCode) {
      401 || 403 => Icons.lock_outline_rounded,
      404 => Icons.search_off_rounded,
      429 => Icons.speed_rounded,
      _ => Icons.cloud_off_rounded,
    };
  }
}
