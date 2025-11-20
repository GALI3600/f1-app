import 'package:f1sync/shared/services/cache/cache_entry.dart';

/// In-memory cache with TTL and size limit
///
/// Fast, volatile cache layer for frequently accessed data.
///
/// Features:
/// - TTL-based expiration
/// - 50MB approximate size limit (based on entry count)
/// - LRU eviction when limit reached
/// - Automatic cleanup of expired entries
///
/// Cache strategy:
/// - Session data: 5 minutes
/// - Driver lists: 1 hour
/// - Frequent queries during active sessions
///
/// Usage:
/// ```dart
/// final cache = MemoryCache();
///
/// // Set data
/// cache.set('drivers_latest', driversList, Duration(hours: 1));
///
/// // Get data
/// final drivers = cache.get<List<Driver>>('drivers_latest');
///
/// // Clear all
/// cache.clear();
/// ```
class MemoryCache {
  /// Internal cache storage
  final Map<String, CacheEntry<dynamic>> _cache = {};

  /// Maximum number of entries (approximate 50MB limit)
  /// Assuming ~100KB per entry average = 500 entries
  static const int maxEntries = 500;

  /// Track access order for LRU eviction
  final List<String> _accessOrder = [];

  /// Get cached data by key
  ///
  /// Returns null if:
  /// - Key doesn't exist
  /// - Entry has expired (and removes it)
  ///
  /// Type parameter [T] should match the stored data type.
  T? get<T>(String key) {
    final entry = _cache[key];

    // Not found
    if (entry == null) return null;

    // Expired - remove and return null
    if (entry.isExpired) {
      delete(key);
      return null;
    }

    // Update access order for LRU
    _updateAccessOrder(key);

    return entry.data as T;
  }

  /// Store data in cache with TTL
  ///
  /// Parameters:
  /// - [key]: Unique cache key
  /// - [data]: Data to cache
  /// - [ttl]: Time to live duration
  ///
  /// If cache is full, removes least recently used entry.
  void set<T>(String key, T data, Duration ttl) {
    // Check size limit before adding
    if (_cache.length >= maxEntries && !_cache.containsKey(key)) {
      _evictLRU();
    }

    _cache[key] = CacheEntry.withTTL(
      data: data,
      ttl: ttl,
    );

    _updateAccessOrder(key);
  }

  /// Delete a specific entry
  ///
  /// Returns true if the key existed and was removed.
  bool delete(String key) {
    _accessOrder.remove(key);
    return _cache.remove(key) != null;
  }

  /// Clear all cached entries
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  /// Remove all expired entries
  ///
  /// Returns the number of entries removed.
  int removeExpired() {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      delete(key);
    }

    return expiredKeys.length;
  }

  /// Check if a key exists and is valid (not expired)
  bool contains(String key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      delete(key);
      return false;
    }

    return true;
  }

  /// Get the number of cached entries
  int get size => _cache.length;

  /// Get all cache keys
  List<String> get keys => _cache.keys.toList();

  /// Check if cache is empty
  bool get isEmpty => _cache.isEmpty;

  /// Check if cache is not empty
  bool get isNotEmpty => _cache.isNotEmpty;

  /// Update access order for LRU tracking
  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  /// Evict least recently used entry
  void _evictLRU() {
    if (_accessOrder.isEmpty) {
      // Fallback: remove first entry
      if (_cache.isNotEmpty) {
        _cache.remove(_cache.keys.first);
      }
      return;
    }

    final lruKey = _accessOrder.first;
    delete(lruKey);
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getStats() {
    return {
      'total_entries': _cache.length,
      'max_entries': maxEntries,
      'usage_percent': (_cache.length / maxEntries * 100).toStringAsFixed(1),
      'expired_count': _cache.values.where((e) => e.isExpired).length,
    };
  }

  /// Get entries by key prefix
  ///
  /// Useful for invalidating related cache entries.
  ///
  /// Example:
  /// ```dart
  /// // Clear all driver-related caches
  /// cache.deleteByPrefix('drivers_');
  /// ```
  List<String> getKeysByPrefix(String prefix) {
    return _cache.keys.where((key) => key.startsWith(prefix)).toList();
  }

  /// Delete entries by key prefix
  ///
  /// Returns the number of entries deleted.
  int deleteByPrefix(String prefix) {
    final keys = getKeysByPrefix(prefix);
    for (final key in keys) {
      delete(key);
    }
    return keys.length;
  }
}
