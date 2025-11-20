import 'package:f1sync/shared/services/cache/cache_entry.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Persistent disk cache using Hive
///
/// Provides long-term storage for cached data that persists across app restarts.
///
/// Features:
/// - TTL-based expiration (7-365 days)
/// - JSON serialization for complex data types
/// - Async operations for non-blocking I/O
/// - Automatic cleanup of expired entries
///
/// Cache strategy:
/// - Historical GPs: 7 days
/// - Images: 30 days (via cached_network_image)
/// - Final results: 365 days (permanent)
///
/// Usage:
/// ```dart
/// final cache = DiskCache();
/// await cache.init();
///
/// // Set data
/// await cache.set('meeting_1234', meetingData, Duration(days: 7));
///
/// // Get data
/// final meeting = await cache.get<Meeting>('meeting_1234');
///
/// // Clear all
/// await cache.clear();
/// ```
class DiskCache {
  static const String _boxName = 'f1sync_cache';
  Box<dynamic>? _box;

  /// Initialize Hive and open cache box
  ///
  /// Must be called before using any other methods.
  /// Call this once during app initialization.
  Future<void> init() async {
    if (_box != null) return; // Already initialized

    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);

    // Clean up expired entries on init
    await removeExpired();
  }

  /// Ensure the cache is initialized
  void _ensureInitialized() {
    if (_box == null) {
      throw StateError(
        'DiskCache not initialized. Call init() before using cache.',
      );
    }
  }

  /// Get cached data by key
  ///
  /// Returns null if:
  /// - Key doesn't exist
  /// - Entry has expired (and removes it)
  ///
  /// Type parameter [T] should match the stored data type.
  Future<T?> get<T>(String key) async {
    _ensureInitialized();

    final entry = _box!.get(key);
    if (entry == null) return null;

    try {
      // Deserialize from JSON
      final cacheEntry = CacheEntry<T>.fromJson(
        Map<String, dynamic>.from(entry as Map),
      );

      // Check expiration
      if (cacheEntry.isExpired) {
        await delete(key);
        return null;
      }

      return cacheEntry.data;
    } catch (e) {
      // Corrupted data - delete and return null
      await delete(key);
      return null;
    }
  }

  /// Store data in cache with TTL
  ///
  /// Parameters:
  /// - [key]: Unique cache key
  /// - [data]: Data to cache (must be JSON-serializable)
  /// - [ttl]: Time to live duration
  ///
  /// The data is serialized to JSON before storage.
  Future<void> set<T>(String key, T data, Duration ttl) async {
    _ensureInitialized();

    final cacheEntry = CacheEntry.withTTL(
      data: data,
      ttl: ttl,
    );

    await _box!.put(key, cacheEntry.toJson());
  }

  /// Delete a specific entry
  ///
  /// Returns true if the key existed and was removed.
  Future<bool> delete(String key) async {
    _ensureInitialized();

    if (!_box!.containsKey(key)) return false;

    await _box!.delete(key);
    return true;
  }

  /// Clear all cached entries
  Future<void> clear() async {
    _ensureInitialized();
    await _box!.clear();
  }

  /// Remove all expired entries
  ///
  /// Returns the number of entries removed.
  ///
  /// This is called automatically on init but can be called
  /// manually for periodic cleanup.
  Future<int> removeExpired() async {
    _ensureInitialized();

    int removedCount = 0;
    final keys = _box!.keys.toList();

    for (final key in keys) {
      try {
        final entry = _box!.get(key);
        if (entry == null) continue;

        final cacheEntry = CacheEntry<dynamic>.fromJson(
          Map<String, dynamic>.from(entry as Map),
        );

        if (cacheEntry.isExpired) {
          await _box!.delete(key);
          removedCount++;
        }
      } catch (e) {
        // Corrupted entry - delete it
        await _box!.delete(key);
        removedCount++;
      }
    }

    return removedCount;
  }

  /// Check if a key exists and is valid (not expired)
  Future<bool> contains(String key) async {
    _ensureInitialized();

    final entry = _box!.get(key);
    if (entry == null) return false;

    try {
      final cacheEntry = CacheEntry<dynamic>.fromJson(
        Map<String, dynamic>.from(entry as Map),
      );

      if (cacheEntry.isExpired) {
        await delete(key);
        return false;
      }

      return true;
    } catch (e) {
      await delete(key);
      return false;
    }
  }

  /// Get the number of cached entries
  int get size {
    _ensureInitialized();
    return _box!.length;
  }

  /// Get all cache keys
  List<String> get keys {
    _ensureInitialized();
    return _box!.keys.cast<String>().toList();
  }

  /// Check if cache is empty
  bool get isEmpty {
    _ensureInitialized();
    return _box!.isEmpty;
  }

  /// Check if cache is not empty
  bool get isNotEmpty {
    _ensureInitialized();
    return _box!.isNotEmpty;
  }

  /// Get cache statistics for debugging
  Future<Map<String, dynamic>> getStats() async {
    _ensureInitialized();

    int expiredCount = 0;
    int totalSize = 0;

    for (final key in _box!.keys) {
      try {
        final entry = _box!.get(key);
        if (entry == null) continue;

        final cacheEntry = CacheEntry<dynamic>.fromJson(
          Map<String, dynamic>.from(entry as Map),
        );

        if (cacheEntry.isExpired) {
          expiredCount++;
        }

        // Approximate size (rough estimate)
        totalSize += entry.toString().length;
      } catch (e) {
        expiredCount++;
      }
    }

    return {
      'total_entries': _box!.length,
      'expired_count': expiredCount,
      'approximate_size_bytes': totalSize,
      'approximate_size_mb': (totalSize / 1024 / 1024).toStringAsFixed(2),
    };
  }

  /// Get entries by key prefix
  ///
  /// Useful for invalidating related cache entries.
  Future<List<String>> getKeysByPrefix(String prefix) async {
    _ensureInitialized();

    return _box!.keys
        .cast<String>()
        .where((key) => key.startsWith(prefix))
        .toList();
  }

  /// Delete entries by key prefix
  ///
  /// Returns the number of entries deleted.
  Future<int> deleteByPrefix(String prefix) async {
    final keys = await getKeysByPrefix(prefix);

    for (final key in keys) {
      await delete(key);
    }

    return keys.length;
  }

  /// Compact the Hive box to reclaim disk space
  ///
  /// Call this periodically (e.g., on app start) to optimize storage.
  Future<void> compact() async {
    _ensureInitialized();
    await _box!.compact();
  }

  /// Close the cache box
  ///
  /// Call this when the app is closing to ensure data is properly saved.
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }

  /// Check if cache is initialized
  bool get isInitialized => _box != null;
}
