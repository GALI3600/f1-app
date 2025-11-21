import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:f1sync/core/network/api_exception.dart';

/// Global error handler for catching and handling all uncaught exceptions
///
/// This service provides centralized error handling for the entire application,
/// including logging, user notifications, and crash prevention.
///
/// Usage:
/// ```dart
/// void main() {
///   GlobalErrorHandler.initialize();
///   runApp(MyApp());
/// }
/// ```
class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  factory GlobalErrorHandler() => _instance;
  GlobalErrorHandler._internal();

  /// Global key for accessing ScaffoldMessenger
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Initialize the global error handler
  ///
  /// This should be called in main() before runApp()
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
      _showErrorNotification('An unexpected error occurred');
    };

    // Handle errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      _showErrorNotification('An unexpected error occurred');
      return true; // Prevent app crash
    };
  }

  /// Log an error to console (and optionally to analytics/crash reporting)
  static void _logError(Object error, StackTrace? stack) {
    if (kDebugMode) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔴 Global Error Handler');
      debugPrint('Error: $error');
      if (stack != null) {
        debugPrint('Stack trace:\n$stack');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    // TODO: Send to crash reporting service (e.g., Sentry, Firebase Crashlytics)
    // CrashReporting.logError(error, stack);
  }

  /// Show a user-friendly error notification
  static void _showErrorNotification(String message) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  /// Handle a specific error and return a user-friendly message
  static String getErrorMessage(Object error) {
    if (error is ApiException) {
      return _getApiExceptionMessage(error);
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    if (error is FormatException) {
      return 'Invalid data format received.';
    }

    // Generic error message
    return 'An unexpected error occurred. Please try again.';
  }

  /// Convert ApiException to user-friendly message
  static String _getApiExceptionMessage(ApiException exception) {
    return switch (exception) {
      NetworkException() => 'No internet connection. Please check your network.',
      TimeoutException() => 'Request timed out. Please try again.',
      ServerException(:final statusCode) => _getServerErrorMessage(statusCode),
      ParseException() => 'Failed to process server response.',
    };
  }

  /// Get user-friendly message for server error status codes
  static String _getServerErrorMessage(int statusCode) {
    return switch (statusCode) {
      400 => 'Bad request. Please try again.',
      401 => 'Authentication required. Please sign in.',
      403 => 'Access denied.',
      404 => 'Resource not found.',
      429 => 'Too many requests. Please wait a moment.',
      >= 500 && < 600 => 'Server error. Please try again later.',
      _ => 'Request failed with status $statusCode.',
    };
  }

  /// Show a snackbar with error message
  static void showError(BuildContext context, Object error) {
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Show a success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show an info snackbar
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show a warning snackbar
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Log an error without showing notification
  static void logError(Object error, [StackTrace? stack]) {
    _logError(error, stack);
  }

  /// Log an info message
  static void logInfo(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ $message');
    }
  }

  /// Log a warning message
  static void logWarning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ $message');
    }
  }
}
