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

    // Debug: check cache persistence
    print('🗄️ DiskCache init: ${_box!.length} entries');

    // Clean up expired entries on init
    final removed = await removeExpired();
    print('🗄️ DiskCache after cleanup: ${_box!.length} entries (removed $removed expired)');
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
  /// Note: For complex types, use getWithDeserializer instead.
  Future<T?> get<T>(String key) async {
    _ensureInitialized();

    final entry = _box!.get(key);
    if (entry == null) return null;

    try {
      final jsonMap = Map<String, dynamic>.from(entry as Map);

      // Check expiration first
      final expiresAt = DateTime.parse(jsonMap['expiresAt'] as String);
      if (DateTime.now().isAfter(expiresAt)) {
        await delete(key);
        return null;
      }

      final rawData = jsonMap['data'];

      // Handle Map<String, dynamic> type specially
      // Hive stores maps as _Map<dynamic, dynamic> which can't be directly cast
      if (rawData is Map) {
        final convertedMap = _convertMap(rawData);
        return convertedMap as T;
      }

      // Handle List type — deep-convert Maps within Lists
      if (rawData is List) {
        final convertedList = _convertList(rawData);
        return convertedList as T;
      }

      return rawData as T;
    } catch (e) {
      // Corrupted data - delete and return null
      print('🔍 [DiskCache] Error reading key $key: $e');
      await delete(key);
      return null;
    }
  }

  /// Recursively convert Map to Map<String, dynamic>
  Map<String, dynamic> _convertMap(Map map) {
    return map.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _convertMap(value));
      } else if (value is List) {
        return MapEntry(key.toString(), _convertList(value));
      }
      return MapEntry(key.toString(), value);
    });
  }

  /// Recursively convert List items
  List<dynamic> _convertList(List list) {
    return list.map((item) {
      if (item is Map) {
        return _convertMap(item);
      } else if (item is List) {
        return _convertList(item);
      }
      return item;
    }).toList();
  }

  /// Get cached list data with properly typed deserializer
  ///
  /// Use this for List<E> types to avoid type casting issues.
  /// Returns a properly typed List<E> instead of List<dynamic>.
  Future<List<E>?> getListFromCache<E>(
    String key, {
    required E Function(Map<String, dynamic>) fromJson,
  }) async {
    _ensureInitialized();

    final entry = _box!.get(key);
    if (entry == null) {
      print('🔍 [DiskCache] Key not found: $key');
      return null;
    }

    try {
      print('🔍 [DiskCache] Reading list key: $key');
      final jsonMap = Map<String, dynamic>.from(entry as Map);

      // Check expiration
      final expiresAt = DateTime.parse(jsonMap['expiresAt'] as String);
      if (DateTime.now().isAfter(expiresAt)) {
        print('🔍 [DiskCache] Entry expired: $key');
        await delete(key);
        return null;
      }

      final rawData = jsonMap['data'];
      if (rawData is! List) {
        print('🔍 [DiskCache] Expected List but got ${rawData.runtimeType}');
        await delete(key);
        return null;
      }

      if (rawData.isNotEmpty && rawData.first is! Map) {
        print('🔍 [DiskCache] OLD FORMAT - first item is not Map, deleting: $key');
        await delete(key);
        return null;
      }

      // Build properly typed list using map<E>
      final List<E> result = rawData
          .map<E>((item) => fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      print('🔍 [DiskCache] List<$E> deserialized: ${result.length} items');
      return result;
    } catch (e) {
      print('🔍 [DiskCache] List deserialization error for $key: $e');
      await delete(key);
      return null;
    }
  }

  /// Get cached data with custom deserializer
  ///
  /// Use this for complex types (Freezed models, Lists of models).
  ///
  /// Parameters:
  /// - [fromJsonList]: Deserializer for list items (when T is List<X>)
  /// - [fromJson]: Deserializer for single object (when T is a single model)
  Future<T?> getWithDeserializer<T>(
    String key, {
    dynamic Function(Map<String, dynamic>)? fromJsonList,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    _ensureInitialized();

    final entry = _box!.get(key);
    if (entry == null) {
      print('🔍 [DiskCache] Key not found: $key');
      return null;
    }

    try {
      print('🔍 [DiskCache] Reading key: $key, entry type: ${entry.runtimeType}');
      final jsonMap = Map<String, dynamic>.from(entry as Map);

      // Check expiration first
      final expiresAt = DateTime.parse(jsonMap['expiresAt'] as String);
      if (DateTime.now().isAfter(expiresAt)) {
        print('🔍 [DiskCache] Entry expired: $key');
        await delete(key);
        return null;
      }

      final rawData = jsonMap['data'];
      print('🔍 [DiskCache] rawData type: ${rawData.runtimeType}, T: $T');

      // If no deserializer provided, try direct cast
      if (fromJsonList == null && fromJson == null) {
        print('🔍 [DiskCache] No deserializer, direct cast');
        return rawData as T;
      }

      // Handle List deserialization
      if (rawData is List && fromJsonList != null) {
        print('🔍 [DiskCache] List detected, length: ${rawData.length}');
        // Check if items are Maps (properly serialized)
        if (rawData.isNotEmpty) {
          print('🔍 [DiskCache] First item type: ${rawData.first.runtimeType}');
          if (rawData.first is! Map) {
            // Old format - delete and return null
            print('🔍 [DiskCache] OLD FORMAT - first item is not Map, deleting: $key');
            await delete(key);
            return null;
          }
        }
        try {
          // Build list with proper element types
          final List<dynamic> deserializedList = [];
          for (final item in rawData) {
            deserializedList.add(fromJsonList(Map<String, dynamic>.from(item as Map)));
          }
          print('🔍 [DiskCache] List deserialized successfully: ${deserializedList.length} items');
          // Return as dynamic to bypass List<dynamic> -> List<T> cast issue
          // The items are correctly typed, just the container type is dynamic
          return deserializedList as dynamic;
        } catch (listError) {
          print('🔍 [DiskCache] List deserialization FAILED: $listError');
          await delete(key);
          return null;
        }
      }

      // Handle single object deserialization
      if (rawData is Map && fromJson != null) {
        print('🔍 [DiskCache] Single object Map detected');
        return fromJson(Map<String, dynamic>.from(rawData));
      }

      // Handle nullable single object - rawData might be null
      if (rawData == null && fromJson != null) {
        print('🔍 [DiskCache] rawData is null with fromJson provided');
        return null;
      }

      // If data format doesn't match expected, it's old/corrupted - delete
      if (fromJsonList != null && rawData is! List) {
        print('🔍 [DiskCache] FORMAT MISMATCH - expected List but got ${rawData.runtimeType}, deleting: $key');
        await delete(key);
        return null;
      }
      if (fromJson != null && rawData is! Map) {
        print('🔍 [DiskCache] FORMAT MISMATCH - expected Map but got ${rawData.runtimeType}, deleting: $key');
        await delete(key);
        return null;
      }

      // Fallback: direct cast for primitives
      print('🔍 [DiskCache] Fallback direct cast');
      return rawData as T;
    } catch (e, stackTrace) {
      // Corrupted data - delete and return null
      print('🔍 [DiskCache] EXCEPTION for key $key: $e');
      print('🔍 [DiskCache] Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
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

    // Serialize data to JSON-compatible format
    final serializedData = _serializeForDisk(data);

    final cacheEntry = CacheEntry.withTTL(
      data: serializedData,
      ttl: ttl,
    );

    await _box!.put(key, cacheEntry.toJson());
  }

  /// Convert data to a format that Hive can store
  dynamic _serializeForDisk(dynamic data) {
    if (data == null) return null;

    // Primitive types - return as is
    if (data is String || data is num || data is bool) {
      return data;
    }

    // Handle Lists - convert each item
    if (data is List) {
      return data.map((item) => _serializeForDisk(item)).toList();
    }

    // Handle Maps
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), _serializeForDisk(v)));
    }

    // Handle objects with toJson() method (freezed models)
    try {
      final result = (data as dynamic).toJson();
      if (result is Map) {
        return _serializeForDisk(result);
      }
      return result;
    } catch (_) {
      // Object doesn't have toJson - try toString as last resort
      return data.toString();
    }
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
