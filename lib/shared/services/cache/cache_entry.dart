/// A cache entry with expiration support
///
/// Wraps cached data with metadata for TTL-based cache invalidation.
///
/// Type parameter [T] represents the cached data type. For disk persistence,
/// T must be JSON-serializable.
///
/// Usage:
/// ```dart
/// // Create entry
/// final entry = CacheEntry(
///   data: myData,
///   expiresAt: DateTime.now().add(Duration(hours: 1)),
/// );
///
/// // Check expiration
/// if (entry.isExpired) {
///   // Fetch fresh data
/// }
/// ```
class CacheEntry<T> {
  /// The cached data
  final T data;

  /// Timestamp when this entry expires
  final DateTime expiresAt;

  /// Create a cache entry
  ///
  /// Parameters:
  /// - [data]: The data to cache
  /// - [expiresAt]: Expiration timestamp
  const CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  /// Check if this cache entry has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if this cache entry is still valid
  bool get isValid => !isExpired;

  /// Time remaining until expiration
  Duration get timeUntilExpiration {
    final now = DateTime.now();
    if (isExpired) return Duration.zero;
    return expiresAt.difference(now);
  }

  /// Convert to JSON (for disk storage)
  ///
  /// Note: [data] must be JSON-serializable (Map, List, String, num, bool, null)
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// Create from JSON (for disk storage)
  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry<T>(
      data: json['data'] as T,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  /// Create an entry with TTL duration
  ///
  /// Convenience factory that calculates expiration time from duration.
  ///
  /// ```dart
  /// final entry = CacheEntry.withTTL(
  ///   data: myData,
  ///   ttl: Duration(hours: 1),
  /// );
  /// ```
  factory CacheEntry.withTTL({
    required T data,
    required Duration ttl,
  }) {
    return CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  @override
  String toString() {
    return 'CacheEntry(data: $data, expiresAt: $expiresAt, isExpired: $isExpired)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CacheEntry<T> &&
        other.data == data &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode => Object.hash(data, expiresAt);
}
