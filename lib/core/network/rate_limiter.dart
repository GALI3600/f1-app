import 'dart:async';
import 'dart:collection';

/// Rate limiter to prevent exceeding API rate limits
///
/// Uses a chain-of-futures pattern to ensure requests are serialized
/// and properly spaced. OpenF1 API allows max 2 requests/second.
///
/// Usage:
/// ```dart
/// final limiter = RateLimiter();
/// await limiter.waitIfNeeded(); // Blocks until it's safe to request
/// // Make API request
/// ```
class RateLimiter {
  /// Maximum number of requests allowed per minute
  static const int maxRequestsPerMinute = 60;

  /// Minimum delay between requests (1000ms = 1 req/sec max)
  /// Using 1000ms to ensure we never hit the 2 req/sec API limit
  static const Duration minRequestInterval = Duration(milliseconds: 1000);

  /// Chain of futures - each request waits for the previous one
  Future<void> _lock = Future.value();

  /// Last request timestamp for per-second limiting
  DateTime? _lastRequestTime;

  /// Queue of timestamps for per-minute limiting
  final Queue<DateTime> _requestTimestamps = Queue();

  /// Wait if the rate limit would be exceeded
  ///
  /// Uses a chain-of-futures pattern to serialize all requests:
  /// 1. Capture the current lock
  /// 2. Replace with a new lock (our completer)
  /// 3. Wait for previous lock
  /// 4. Wait for rate limit interval
  /// 5. Release our lock
  Future<void> waitIfNeeded() async {
    // Capture current lock and create our own
    final previousLock = _lock;
    final completer = Completer<void>();
    _lock = completer.future;

    try {
      // Wait for previous request to complete its rate limit check
      await previousLock;

      // Wait for minimum interval between requests
      if (_lastRequestTime != null) {
        final elapsed = DateTime.now().difference(_lastRequestTime!);
        if (elapsed < minRequestInterval) {
          final waitTime = minRequestInterval - elapsed;
          await Future.delayed(waitTime);
        }
      }

      // Also enforce per-minute limit
      await _enforceMinuteLimit();

      // Record this request
      final now = DateTime.now();
      _lastRequestTime = now;
      _requestTimestamps.add(now);
    } finally {
      // Always release our lock, even if there's an error
      completer.complete();
    }
  }

  /// Enforce the per-minute rate limit
  Future<void> _enforceMinuteLimit() async {
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

      if (waitTime.inMicroseconds > 0) {
        await Future.delayed(waitTime);
      }

      // Remove the oldest request after waiting
      _requestTimestamps.removeFirst();
    }
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
    _lock = Future.value();
    _lastRequestTime = null;
    _requestTimestamps.clear();
  }
}
