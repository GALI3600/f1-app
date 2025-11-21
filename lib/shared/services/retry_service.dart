import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:f1sync/core/network/api_exception.dart';

/// Service for handling automatic retries with exponential backoff
///
/// Provides automatic retry logic for transient errors like network failures
/// and timeouts. Uses exponential backoff to avoid overwhelming the server.
///
/// Usage:
/// ```dart
/// final data = await RetryService.execute(
///   () => apiClient.fetchDrivers(),
///   maxAttempts: 3,
/// );
/// ```
class RetryService {
  RetryService._();

  /// Default maximum number of retry attempts
  static const int defaultMaxAttempts = 3;

  /// Default initial delay (1 second)
  static const Duration defaultInitialDelay = Duration(seconds: 1);

  /// Default maximum delay (10 seconds)
  static const Duration defaultMaxDelay = Duration(seconds: 10);

  /// Default backoff multiplier
  static const double defaultBackoffMultiplier = 2.0;

  /// Execute a function with automatic retry logic
  ///
  /// Retries the function if it throws a retryable exception (network errors, timeouts).
  /// Uses exponential backoff between retries.
  ///
  /// Parameters:
  /// - [fn]: The function to execute
  /// - [maxAttempts]: Maximum number of attempts (default: 3)
  /// - [initialDelay]: Initial delay between retries (default: 1s)
  /// - [maxDelay]: Maximum delay between retries (default: 10s)
  /// - [backoffMultiplier]: Multiplier for exponential backoff (default: 2.0)
  /// - [onRetry]: Optional callback when a retry occurs
  ///
  /// Returns the result of the function if successful.
  /// Throws the last exception if all retries fail.
  static Future<T> execute<T>(
    Future<T> Function() fn, {
    int maxAttempts = defaultMaxAttempts,
    Duration initialDelay = defaultInitialDelay,
    Duration maxDelay = defaultMaxDelay,
    double backoffMultiplier = defaultBackoffMultiplier,
    Function(int attempt, Object error)? onRetry,
  }) async {
    int attempt = 0;
    Duration currentDelay = initialDelay;
    Object? lastError;

    while (attempt < maxAttempts) {
      attempt++;

      try {
        return await fn();
      } catch (error) {
        lastError = error;

        // Check if error is retryable
        if (!_isRetryable(error)) {
          if (kDebugMode) {
            debugPrint('RetryService: Non-retryable error: $error');
          }
          rethrow;
        }

        // If this was the last attempt, throw the error
        if (attempt >= maxAttempts) {
          if (kDebugMode) {
            debugPrint(
                'RetryService: Max attempts ($maxAttempts) reached. Giving up.');
          }
          rethrow;
        }

        // Log retry
        if (kDebugMode) {
          debugPrint(
              'RetryService: Attempt $attempt/$maxAttempts failed: $error');
          debugPrint('RetryService: Retrying in ${currentDelay.inSeconds}s...');
        }

        // Call onRetry callback if provided
        onRetry?.call(attempt, error);

        // Wait before retrying
        await Future.delayed(currentDelay);

        // Calculate next delay with exponential backoff
        currentDelay = Duration(
          milliseconds:
              (currentDelay.inMilliseconds * backoffMultiplier).toInt(),
        );

        // Cap at max delay
        if (currentDelay > maxDelay) {
          currentDelay = maxDelay;
        }
      }
    }

    // This should never be reached, but just in case
    throw lastError ?? Exception('Retry failed with unknown error');
  }

  /// Execute a function with retry logic and return a fallback value on failure
  ///
  /// Similar to [execute], but returns a fallback value instead of throwing
  /// if all retries fail.
  static Future<T> executeWithFallback<T>(
    Future<T> Function() fn,
    T fallback, {
    int maxAttempts = defaultMaxAttempts,
    Duration initialDelay = defaultInitialDelay,
    Duration maxDelay = defaultMaxDelay,
    double backoffMultiplier = defaultBackoffMultiplier,
    Function(int attempt, Object error)? onRetry,
    Function(Object error)? onFallback,
  }) async {
    try {
      return await execute(
        fn,
        maxAttempts: maxAttempts,
        initialDelay: initialDelay,
        maxDelay: maxDelay,
        backoffMultiplier: backoffMultiplier,
        onRetry: onRetry,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('RetryService: All retries failed. Using fallback value.');
      }
      onFallback?.call(error);
      return fallback;
    }
  }

  /// Check if an error is retryable
  ///
  /// Returns true for transient errors like network failures and timeouts.
  /// Returns false for permanent errors like 404 or parsing errors.
  static bool _isRetryable(Object error) {
    // ApiException types
    if (error is ApiException) {
      return switch (error) {
        NetworkException() => true, // Network failures are retryable
        TimeoutException() => true, // Timeouts are retryable
        ServerException(:final statusCode) =>
          _isRetryableStatusCode(statusCode),
        ParseException() => false, // Parsing errors are not retryable
      };
    }

    // Dart timeout exceptions
    if (error is TimeoutException) {
      return true;
    }

    // Unknown errors are not retryable by default
    return false;
  }

  /// Check if an HTTP status code is retryable
  ///
  /// Returns true for:
  /// - 408 (Request Timeout)
  /// - 429 (Too Many Requests)
  /// - 500-599 (Server Errors)
  ///
  /// Returns false for:
  /// - 400-499 (Client Errors, except 408 and 429)
  static bool _isRetryableStatusCode(int statusCode) {
    return switch (statusCode) {
      408 => true, // Request Timeout
      429 => true, // Too Many Requests
      >= 500 && < 600 => true, // Server Errors
      _ => false,
    };
  }

  /// Create a retry policy for a specific use case
  ///
  /// Returns a function that wraps [execute] with predefined parameters.
  static Future<T> Function(Future<T> Function()) createPolicy<T>({
    int maxAttempts = defaultMaxAttempts,
    Duration initialDelay = defaultInitialDelay,
    Duration maxDelay = defaultMaxDelay,
    double backoffMultiplier = defaultBackoffMultiplier,
    Function(int attempt, Object error)? onRetry,
  }) {
    return (fn) => execute(
          fn,
          maxAttempts: maxAttempts,
          initialDelay: initialDelay,
          maxDelay: maxDelay,
          backoffMultiplier: backoffMultiplier,
          onRetry: onRetry,
        );
  }

  /// Aggressive retry policy for critical operations
  ///
  /// - 5 attempts
  /// - 500ms initial delay
  /// - 30s max delay
  static Future<T> executeAggressive<T>(
    Future<T> Function() fn, {
    Function(int attempt, Object error)? onRetry,
  }) {
    return execute(
      fn,
      maxAttempts: 5,
      initialDelay: const Duration(milliseconds: 500),
      maxDelay: const Duration(seconds: 30),
      onRetry: onRetry,
    );
  }

  /// Conservative retry policy for non-critical operations
  ///
  /// - 2 attempts
  /// - 2s initial delay
  /// - 5s max delay
  static Future<T> executeConservative<T>(
    Future<T> Function() fn, {
    Function(int attempt, Object error)? onRetry,
  }) {
    return execute(
      fn,
      maxAttempts: 2,
      initialDelay: const Duration(seconds: 2),
      maxDelay: const Duration(seconds: 5),
      onRetry: onRetry,
    );
  }
}
