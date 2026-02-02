import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

/// Cache entry wrapper with expiration
class CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  CacheEntry(this.data, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'data': data,
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory CacheEntry.fromJson(Map<String, dynamic> json, T data) {
    return CacheEntry<T>(
      data,
      DateTime.parse(json['expiresAt'] as String),
    );
  }
}

/// TTL presets for different types of data
class CacheTTL {
  static const short = Duration(minutes: 5); // Live data
  static const medium = Duration(hours: 1); // Session data
  static const long = Duration(days: 7); // Historical data
  static const permanent = Duration(days: 365); // Results
}

/// Service for caching data with TTL (Time To Live)
///
/// Uses Hive for persistent storage and in-memory cache for performance
class CacheService {
  static const String _boxName = 'f1sync_cache';
  Box? _box;
  final Logger _logger = Logger();
  bool _isInitialized = false;
  bool _isDisposed = false;

  /// In-memory cache for faster access
  final Map<String, CacheEntry> _memoryCache = {};

  /// Check if the box is available for operations
  bool get _isBoxAvailable => _box != null && _box!.isOpen && !_isDisposed;

  /// Initialize the cache service
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();
      _box = await Hive.openBox(_boxName);
      _isInitialized = true;
      _logger.i('Cache service initialized');
    } catch (e) {
      _logger.e('Failed to initialize cache: $e');
      // Don't rethrow - allow app to work without disk cache
    }
  }

  /// Get cached data with automatic fallback to fetch function
  ///
  /// [key] - Unique cache key
  /// [ttl] - Time to live for the cache
  /// [fetch] - Function to fetch fresh data if cache is expired
  Future<T> getCached<T>({
    required String key,
    required Duration ttl,
    required Future<T> Function() fetch,
  }) async {
    // Try memory cache first
    final memoryCached = _getFromMemory<T>(key);
    if (memoryCached != null) {
      _logger.d('Cache HIT (memory): $key');
      return memoryCached;
    }

    // Try disk cache
    final diskCached = await _getFromDisk<T>(key);
    if (diskCached != null) {
      _logger.d('Cache HIT (disk): $key');
      // Store in memory for next time
      _memoryCache[key] = CacheEntry(diskCached, DateTime.now().add(ttl));
      return diskCached;
    }

    // Cache MISS - fetch fresh data
    _logger.d('Cache MISS: $key');
    final freshData = await fetch();

    // Store in both caches
    await _storeToDisk(key, freshData, ttl);
    _storeToMemory(key, freshData, ttl);

    return freshData;
  }

  /// Get data from memory cache
  T? _getFromMemory<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _memoryCache.remove(key);
      return null;
    }

    return entry.data as T;
  }

  /// Get data from disk cache
  Future<T?> _getFromDisk<T>(String key) async {
    if (!_isBoxAvailable) return null;

    try {
      final entry = _box!.get(key);
      if (entry == null) return null;

      // Check if entry is a Map with expiresAt
      if (entry is Map) {
        final expiresAt = DateTime.parse(entry['expiresAt'] as String);
        if (DateTime.now().isAfter(expiresAt)) {
          if (_isBoxAvailable) {
            await _box!.delete(key);
          }
          return null;
        }
        return entry['data'] as T;
      }

      return null;
    } catch (e) {
      _logger.e('Error reading from disk cache: $e');
      return null;
    }
  }

  /// Store data to memory cache
  void _storeToMemory<T>(String key, T data, Duration ttl) {
    _memoryCache[key] = CacheEntry(
      data,
      DateTime.now().add(ttl),
    );
  }

  /// Store data to disk cache
  Future<void> _storeToDisk<T>(String key, T data, Duration ttl) async {
    if (!_isBoxAvailable) return;

    try {
      // Convert data to JSON-serializable format
      final serializedData = _serializeForDisk(data);
      final entry = {
        'data': serializedData,
        'expiresAt': DateTime.now().add(ttl).toIso8601String(),
      };

      // Double-check box is still available before writing
      if (_isBoxAvailable) {
        await _box!.put(key, entry);
      }
    } catch (e) {
      _logger.e('Error writing to disk cache: $e');
    }
  }

  /// Convert data to a format that Hive can store
  dynamic _serializeForDisk(dynamic data) {
    if (data == null) return null;

    // Primitive types (String, int, double, bool) - return as is
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

  /// Clear all caches
  Future<void> clearAll() async {
    _memoryCache.clear();
    if (_isBoxAvailable) {
      await _box!.clear();
    }
    _logger.i('All caches cleared');
  }

  /// Clear expired entries from disk cache
  Future<void> clearExpired() async {
    if (!_isBoxAvailable) return;

    try {
      final now = DateTime.now();
      final keysToDelete = <String>[];

      for (var key in _box!.keys) {
        final entry = _box!.get(key);
        if (entry is Map) {
          final expiresAt = DateTime.parse(entry['expiresAt'] as String);
          if (now.isAfter(expiresAt)) {
            keysToDelete.add(key as String);
          }
        }
      }

      for (var key in keysToDelete) {
        if (_isBoxAvailable) {
          await _box!.delete(key);
        }
      }

      _logger.i('Cleared ${keysToDelete.length} expired entries');
    } catch (e) {
      _logger.e('Error clearing expired cache: $e');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'memory_entries': _memoryCache.length,
      'disk_entries': _isBoxAvailable ? _box!.length : 0,
    };
  }

  /// Dispose the cache service
  Future<void> dispose() async {
    _isDisposed = true;
    _memoryCache.clear();
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
    _box = null;
  }
}
