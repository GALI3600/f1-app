import 'dart:collection';

/// Rate limiter to prevent exceeding API rate limits
///
/// Implements a sliding window rate limiter that tracks request timestamps
/// and enforces a maximum of 60 requests per minute.
///
/// Usage:
/// ```dart
/// final limiter = RateLimiter();
/// await limiter.waitIfNeeded(); // Blocks if limit reached
/// // Make API request
/// ```
class RateLimiter {
  /// Maximum number of requests allowed per minute
  static const int maxRequestsPerMinute = 60;

  /// Queue of timestamps for recent requests
  final Queue<DateTime> _requestTimestamps = Queue();

  /// Wait if the rate limit would be exceeded
  ///
  /// This method:
  /// 1. Removes timestamps older than 1 minute
  /// 2. Checks if we've hit the rate limit
  /// 3. If yes, waits until the oldest request expires
  /// 4. Records the current timestamp
  ///
  /// The method blocks execution until it's safe to make another request.
  Future<void> waitIfNeeded() async {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    // Remove timestamps older than 1 minute
    while (_requestTimestamps.isNotEmpty &&
        _requestTimestamps.first.isBefore(oneMinuteAgo)) {
      _requestTimestamps.removeFirst();
    }

    // If we've hit the limit, wait until the oldest request expires
    if (_requestTimestamps.length >= maxRequestsPerMinute) {
      final oldestRequest = _requestTimestamps.first;
      final waitTime = oldestRequest
          .add(const Duration(minutes: 1))
          .difference(now);

      if (waitTime.isPositive) {
        await Future.delayed(waitTime);
      }

      // Remove the oldest request after waiting
      _requestTimestamps.removeFirst();
    }

    // Record this request
    _requestTimestamps.add(now);
  }

  /// Get the number of requests made in the last minute
  int get requestCount {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    // Clean up old timestamps
    while (_requestTimestamps.isNotEmpty &&
        _requestTimestamps.first.isBefore(oneMinuteAgo)) {
      _requestTimestamps.removeFirst();
    }

    return _requestTimestamps.length;
  }

  /// Reset the rate limiter (useful for testing)
  void reset() {
    _requestTimestamps.clear();
  }
}
