import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

/// Performance monitoring utility for tracking app performance
///
/// Provides tools to measure and log performance metrics like:
/// - API response times
/// - Cache hit rates
/// - Screen render times
/// - Memory usage
/// - Widget rebuild counts
///
/// Usage:
/// ```dart
/// // Measure operation time
/// final stopwatch = PerformanceMonitor.start('api_fetch_drivers');
/// await apiClient.getDrivers();
/// PerformanceMonitor.stop(stopwatch, 'api_fetch_drivers');
///
/// // Track cache hits/misses
/// PerformanceMonitor.trackCacheHit('drivers_list');
/// PerformanceMonitor.trackCacheMiss('drivers_list');
///
/// // Log performance summary
/// PerformanceMonitor.logSummary();
/// ```
class PerformanceMonitor {
  static final Logger _logger = Logger();
  static final Map<String, List<Duration>> _timings = {};
  static final Map<String, int> _cacheHits = {};
  static final Map<String, int> _cacheMisses = {};
  static final Map<String, int> _apiCalls = {};

  /// Start timing an operation
  ///
  /// Returns a Stopwatch that should be passed to [stop] when done.
  static Stopwatch start(String operation) {
    final stopwatch = Stopwatch()..start();
    if (kDebugMode) {
      _logger.d('⏱️ Started: $operation');
    }
    return stopwatch;
  }

  /// Stop timing an operation and log the duration
  ///
  /// [stopwatch] - The stopwatch returned from [start]
  /// [operation] - The operation name (should match the one from [start])
  /// [warnThreshold] - Optional threshold in milliseconds to warn if exceeded
  static void stop(
    Stopwatch stopwatch,
    String operation, {
    int? warnThreshold,
  }) {
    stopwatch.stop();
    final duration = stopwatch.elapsed;

    // Store timing
    _timings.putIfAbsent(operation, () => []);
    _timings[operation]!.add(duration);

    if (kDebugMode) {
      final ms = duration.inMilliseconds;
      final message = '⏱️ Completed: $operation (${ms}ms)';

      if (warnThreshold != null && ms > warnThreshold) {
        _logger.w('⚠️ $message - SLOW!');
      } else {
        _logger.d(message);
      }
    }
  }

  /// Measure the execution time of an async function
  ///
  /// Returns the result of the function along with timing it.
  ///
  /// Example:
  /// ```dart
  /// final drivers = await PerformanceMonitor.measure(
  ///   'fetch_drivers',
  ///   () => apiClient.getDrivers(),
  ///   warnThreshold: 2000, // 2 seconds
  /// );
  /// ```
  static Future<T> measure<T>(
    String operation,
    Future<T> Function() function, {
    int? warnThreshold,
  }) async {
    final stopwatch = start(operation);
    try {
      final result = await function();
      stop(stopwatch, operation, warnThreshold: warnThreshold);
      return result;
    } catch (e) {
      stop(stopwatch, operation);
      rethrow;
    }
  }

  /// Track a cache hit
  static void trackCacheHit(String cacheKey) {
    _cacheHits[cacheKey] = (_cacheHits[cacheKey] ?? 0) + 1;
    if (kDebugMode) {
      _logger.d('✅ Cache HIT: $cacheKey');
    }
  }

  /// Track a cache miss
  static void trackCacheMiss(String cacheKey) {
    _cacheMisses[cacheKey] = (_cacheMisses[cacheKey] ?? 0) + 1;
    if (kDebugMode) {
      _logger.d('❌ Cache MISS: $cacheKey');
    }
  }

  /// Track an API call
  static void trackApiCall(String endpoint) {
    _apiCalls[endpoint] = (_apiCalls[endpoint] ?? 0) + 1;
    if (kDebugMode) {
      _logger.d('🌐 API Call: $endpoint');
    }
  }

  /// Get cache hit rate for a specific key
  ///
  /// Returns a percentage (0-100) or null if no data.
  static double? getCacheHitRate(String cacheKey) {
    final hits = _cacheHits[cacheKey] ?? 0;
    final misses = _cacheMisses[cacheKey] ?? 0;
    final total = hits + misses;

    if (total == 0) return null;

    return (hits / total) * 100;
  }

  /// Get overall cache hit rate across all keys
  ///
  /// Returns a percentage (0-100) or null if no data.
  static double? getOverallCacheHitRate() {
    final totalHits = _cacheHits.values.fold<int>(0, (sum, v) => sum + v);
    final totalMisses = _cacheMisses.values.fold<int>(0, (sum, v) => sum + v);
    final total = totalHits + totalMisses;

    if (total == 0) return null;

    return (totalHits / total) * 100;
  }

  /// Get average duration for an operation
  static Duration? getAverageDuration(String operation) {
    final timings = _timings[operation];
    if (timings == null || timings.isEmpty) return null;

    final totalMs = timings.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );

    return Duration(milliseconds: totalMs ~/ timings.length);
  }

  /// Get statistics for an operation
  static Map<String, dynamic>? getOperationStats(String operation) {
    final timings = _timings[operation];
    if (timings == null || timings.isEmpty) return null;

    final durations = timings.map((d) => d.inMilliseconds).toList()..sort();

    return {
      'count': durations.length,
      'min_ms': durations.first,
      'max_ms': durations.last,
      'avg_ms': durations.reduce((a, b) => a + b) ~/ durations.length,
      'p50_ms': durations[durations.length ~/ 2],
      'p95_ms': durations[(durations.length * 0.95).floor()],
    };
  }

  /// Log a performance summary
  static void logSummary() {
    if (!kDebugMode) return;

    _logger.i('📊 ========== PERFORMANCE SUMMARY ==========');

    // API Calls
    if (_apiCalls.isNotEmpty) {
      _logger.i('🌐 API Calls:');
      _apiCalls.forEach((endpoint, count) {
        _logger.i('  • $endpoint: $count calls');
      });
    }

    // Cache Stats
    final hitRate = getOverallCacheHitRate();
    if (hitRate != null) {
      final totalHits = _cacheHits.values.fold<int>(0, (sum, v) => sum + v);
      final totalMisses =
          _cacheMisses.values.fold<int>(0, (sum, v) => sum + v);

      _logger.i('💾 Cache Performance:');
      _logger.i('  • Hit Rate: ${hitRate.toStringAsFixed(1)}%');
      _logger.i('  • Total Hits: $totalHits');
      _logger.i('  • Total Misses: $totalMisses');

      if (hitRate < 70) {
        _logger.w('  ⚠️ Cache hit rate below target (70%)');
      }
    }

    // Operation Timings
    if (_timings.isNotEmpty) {
      _logger.i('⏱️ Operation Timings:');
      _timings.forEach((operation, timings) {
        final stats = getOperationStats(operation);
        if (stats != null) {
          _logger.i('  • $operation:');
          _logger.i('    - Count: ${stats['count']}');
          _logger.i('    - Avg: ${stats['avg_ms']}ms');
          _logger.i('    - Min/Max: ${stats['min_ms']}ms / ${stats['max_ms']}ms');
          _logger.i('    - P95: ${stats['p95_ms']}ms');

          // Warn if average is slow for API calls
          if (operation.startsWith('api_') && stats['avg_ms'] > 2000) {
            _logger.w('    ⚠️ Average API response time > 2s');
          }
        }
      });
    }

    _logger.i('==========================================');
  }

  /// Reset all performance data
  static void reset() {
    _timings.clear();
    _cacheHits.clear();
    _cacheMisses.clear();
    _apiCalls.clear();
    if (kDebugMode) {
      _logger.i('🔄 Performance data reset');
    }
  }

  /// Get all performance data as JSON
  static Map<String, dynamic> toJson() {
    return {
      'timings': _timings.map(
        (key, value) => MapEntry(
          key,
          value.map((d) => d.inMilliseconds).toList(),
        ),
      ),
      'cache_hits': _cacheHits,
      'cache_misses': _cacheMisses,
      'api_calls': _apiCalls,
      'overall_cache_hit_rate': getOverallCacheHitRate(),
    };
  }
}

/// Widget wrapper for measuring widget build times
///
/// Usage:
/// ```dart
/// PerformanceMeasureWidget(
///   name: 'DriverCard',
///   child: DriverCard(driver: driver),
/// )
/// ```
class PerformanceMeasureWidget extends StatelessWidget {
  final String name;
  final Widget child;

  const PerformanceMeasureWidget({
    required this.name,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      final stopwatch = PerformanceMonitor.start('build_$name');
      // Build the widget
      final result = child;
      PerformanceMonitor.stop(stopwatch, 'build_$name', warnThreshold: 16);
      return result;
    }
    return child;
  }
}
