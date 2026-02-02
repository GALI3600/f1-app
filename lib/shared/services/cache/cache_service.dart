import 'package:f1sync/shared/services/cache/disk_cache.dart';
import 'package:f1sync/shared/services/cache/memory_cache.dart';

/// TTL presets for different types of data
class CacheTTL {
  static const short = Duration(minutes: 5); // Live data
  static const medium = Duration(hours: 1); // Session data
  static const long = Duration(days: 7); // Historical data
  static const permanent = Duration(days: 365); // Results
}

/// Unified cache service with 3-layer strategy: Memory → Disk → Network
///
/// Provides a high-level API for caching that automatically manages both
/// memory and disk cache layers.
///
/// Cache flow:
/// 1. Check memory cache (fast)
/// 2. If miss, check disk cache (slower)
/// 3. If miss, fetch from network and populate both caches
///
/// Features:
/// - Transparent multi-layer caching
/// - Automatic cache population on fetch
/// - Type-safe generic methods
/// - Configurable TTLs per layer
/// - Bulk invalidation support
///
/// Usage:
/// ```dart
/// final cacheService = CacheService();
/// await cacheService.init();
///
/// // Get with auto-fetch
/// final drivers = await cacheService.getCached<List<Driver>>(
///   key: 'drivers_latest',
///   ttl: Duration(hours: 1),
///   fetch: () => apiClient.getDrivers(),
/// );
///
/// // Manual cache operations
/// await cacheService.set('key', data, Duration(hours: 1));
/// final data = await cacheService.get<MyData>('key');
/// await cacheService.invalidate('key');
/// ```
class CacheService {
  final MemoryCache _memoryCache;
  final DiskCache _diskCache;

  /// Create cache service with optional custom cache instances
  CacheService({
    MemoryCache? memoryCache,
    DiskCache? diskCache,
  })  : _memoryCache = memoryCache ?? MemoryCache(),
        _diskCache = diskCache ?? DiskCache();

  /// Initialize the cache service
  ///
  /// Must be called before using the service.
  /// Call this once during app initialization.
  Future<void> init() async {
    await _diskCache.init();
  }

  /// Get cached data with automatic fetch on miss
  ///
  /// This is the primary method for cache-aware data fetching.
  ///
  /// Flow:
  /// 1. Try memory cache
  /// 2. If miss, try disk cache (and populate memory)
  /// 3. If miss, call fetch function
  /// 4. Store result in both caches
  ///
  /// Parameters:
  /// - [key]: Unique cache key
  /// - [ttl]: Time to live duration
  /// - [fetch]: Function to fetch fresh data on cache miss
  /// - [diskTTL]: Optional different TTL for disk (defaults to [ttl])
  /// - [fromJsonList]: Function to deserialize a list item from JSON (for List<T>)
  /// - [fromJson]: Function to deserialize a single object from JSON
  ///
  /// Returns the cached or freshly fetched data.
  Future<T> getCached<T>({
    required String key,
    required Duration ttl,
    required Future<T> Function() fetch,
    Duration? diskTTL,
    dynamic Function(Map<String, dynamic>)? fromJsonList,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    // 1. Try memory cache
    final memoryData = _memoryCache.get<T>(key);
    if (memoryData != null) {
      print('✅ Cache HIT (memory): $key');
      return memoryData;
    }

    // 2. Try disk cache
    final diskData = await _diskCache.getWithDeserializer<T>(
      key,
      fromJsonList: fromJsonList,
      fromJson: fromJson,
    );
    if (diskData != null) {
      print('✅ Cache HIT (disk): $key');
      // Populate memory cache
      _memoryCache.set(key, diskData, ttl);
      return diskData;
    }

    // 3. Fetch fresh data
    print('❌ Cache MISS: $key');
    final freshData = await fetch();

    // 4. Store in both caches
    await setInBothCaches(key, freshData, ttl, diskTTL);

    return freshData;
  }

  /// Get cached list data with proper typing
  ///
  /// This method properly types list elements to avoid List<dynamic> issues.
  /// Use this instead of getCached when dealing with List<E> types.
  ///
  /// Parameters:
  /// - [key]: Unique cache key
  /// - [ttl]: Time to live duration
  /// - [fetch]: Function to fetch fresh data on cache miss
  /// - [fromJson]: Function to deserialize a single list element from JSON
  /// - [diskTTL]: Optional different TTL for disk (defaults to [ttl])
  Future<List<E>> getCachedList<E>({
    required String key,
    required Duration ttl,
    required Future<List<E>> Function() fetch,
    required E Function(Map<String, dynamic>) fromJson,
    Duration? diskTTL,
  }) async {
    // 1. Try memory cache
    final memoryData = _memoryCache.get<List<E>>(key);
    if (memoryData != null) {
      print('✅ Cache HIT (memory): $key');
      return memoryData;
    }

    // 2. Try disk cache with proper typing
    final diskData = await _diskCache.getListFromCache<E>(
      key,
      fromJson: fromJson,
    );
    if (diskData != null) {
      print('✅ Cache HIT (disk): $key');
      // Populate memory cache
      _memoryCache.set(key, diskData, ttl);
      return diskData;
    }

    // 3. Fetch fresh data
    print('❌ Cache MISS: $key');
    final freshData = await fetch();

    // 4. Store in both caches
    await setInBothCaches(key, freshData, ttl, diskTTL);

    return freshData;
  }

  /// Get data from cache only (no fetch on miss)
  ///
  /// Checks memory first, then disk.
  /// Returns null if not found in either cache.
  Future<T?> get<T>(String key) async {
    // Try memory first
    final memoryData = _memoryCache.get<T>(key);
    if (memoryData != null) {
      return memoryData;
    }

    // Try disk
    final diskData = await _diskCache.get<T>(key);
    if (diskData != null) {
      // Promote to memory cache
      // Use a default TTL since we don't know the original
      _memoryCache.set(key, diskData, const Duration(minutes: 5));
      return diskData;
    }

    return null;
  }

  /// Store data in both memory and disk caches
  ///
  /// Parameters:
  /// - [key]: Unique cache key
  /// - [data]: Data to cache
  /// - [memoryTTL]: TTL for memory cache
  /// - [diskTTL]: TTL for disk cache (defaults to [memoryTTL])
  Future<void> set<T>(
    String key,
    T data,
    Duration memoryTTL, [
    Duration? diskTTL,
  ]) async {
    await setInBothCaches(key, data, memoryTTL, diskTTL);
  }

  /// Internal method to set in both caches
  Future<void> setInBothCaches<T>(
    String key,
    T data,
    Duration memoryTTL,
    Duration? diskTTL,
  ) async {
    _memoryCache.set(key, data, memoryTTL);
    await _diskCache.set(key, data, diskTTL ?? memoryTTL);
  }

  /// Store data in memory cache only
  ///
  /// Useful for temporary data that shouldn't persist.
  void setInMemory<T>(String key, T data, Duration ttl) {
    _memoryCache.set(key, data, ttl);
  }

  /// Store data in disk cache only
  ///
  /// Useful for large data that shouldn't consume memory.
  Future<void> setOnDisk<T>(String key, T data, Duration ttl) async {
    await _diskCache.set(key, data, ttl);
  }

  /// Invalidate (remove) data from both caches
  ///
  /// Returns true if the key existed in at least one cache.
  Future<bool> invalidate(String key) async {
    final memoryDeleted = _memoryCache.delete(key);
    final diskDeleted = await _diskCache.delete(key);
    return memoryDeleted || diskDeleted;
  }

  /// Invalidate all entries with a given key prefix
  ///
  /// Useful for bulk invalidation of related data.
  ///
  /// Example:
  /// ```dart
  /// // Invalidate all driver-related caches
  /// await cacheService.invalidateByPrefix('drivers_');
  /// ```
  Future<int> invalidateByPrefix(String prefix) async {
    final memoryCount = _memoryCache.deleteByPrefix(prefix);
    final diskCount = await _diskCache.deleteByPrefix(prefix);
    return memoryCount + diskCount;
  }

  /// Clear all caches (both memory and disk)
  Future<void> clearAll() async {
    _memoryCache.clear();
    await _diskCache.clear();
  }

  /// Remove expired entries from both caches
  ///
  /// Returns total number of entries removed.
  Future<int> removeExpired() async {
    final memoryCount = _memoryCache.removeExpired();
    final diskCount = await _diskCache.removeExpired();
    return memoryCount + diskCount;
  }

  /// Check if a key exists in either cache
  Future<bool> contains(String key) async {
    return _memoryCache.contains(key) || await _diskCache.contains(key);
  }

  /// Get combined cache statistics
  Future<Map<String, dynamic>> getStats() async {
    final diskStats = await _diskCache.getStats();

    return {
      'memory': _memoryCache.getStats(),
      'disk': diskStats,
      'total_entries': _memoryCache.size + _diskCache.size,
    };
  }

  /// Compact disk cache to reclaim space
  Future<void> compact() async {
    await _diskCache.compact();
  }

  /// Close the cache service
  ///
  /// Call this when the app is closing.
  Future<void> close() async {
    await _diskCache.close();
  }

  /// Get direct access to memory cache (for advanced use)
  MemoryCache get memory => _memoryCache;

  /// Get direct access to disk cache (for advanced use)
  DiskCache get disk => _diskCache;
}
