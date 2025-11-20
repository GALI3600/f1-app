import 'package:shared_preferences/shared_preferences.dart';

/// Persistent key-value storage service using SharedPreferences
///
/// Provides a simple, type-safe API for storing user preferences and app state.
///
/// Supported types:
/// - String
/// - int
/// - double
/// - bool
/// - List<String>
///
/// Common use cases:
/// - User preferences (theme, language)
/// - App settings (notifications, units)
/// - Last selected session/driver
/// - Onboarding status
///
/// Usage:
/// ```dart
/// final storage = StorageService();
/// await storage.init();
///
/// // Store values
/// await storage.setString('theme', 'dark');
/// await storage.setBool('notifications_enabled', true);
///
/// // Retrieve values
/// final theme = storage.getString('theme') ?? 'light';
/// final notificationsEnabled = storage.getBool('notifications_enabled') ?? false;
///
/// // Remove values
/// await storage.remove('theme');
/// ```
class StorageService {
  SharedPreferences? _prefs;

  /// Initialize the storage service
  ///
  /// Must be called before using any other methods.
  /// Call this once during app initialization.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Ensure the service is initialized
  void _ensureInitialized() {
    if (_prefs == null) {
      throw StateError(
        'StorageService not initialized. Call init() before using storage.',
      );
    }
  }

  // ========== String Methods ==========

  /// Store a string value
  Future<bool> setString(String key, String value) async {
    _ensureInitialized();
    return await _prefs!.setString(key, value);
  }

  /// Get a string value
  String? getString(String key) {
    _ensureInitialized();
    return _prefs!.getString(key);
  }

  // ========== Int Methods ==========

  /// Store an integer value
  Future<bool> setInt(String key, int value) async {
    _ensureInitialized();
    return await _prefs!.setInt(key, value);
  }

  /// Get an integer value
  int? getInt(String key) {
    _ensureInitialized();
    return _prefs!.getInt(key);
  }

  // ========== Double Methods ==========

  /// Store a double value
  Future<bool> setDouble(String key, double value) async {
    _ensureInitialized();
    return await _prefs!.setDouble(key, value);
  }

  /// Get a double value
  double? getDouble(String key) {
    _ensureInitialized();
    return _prefs!.getDouble(key);
  }

  // ========== Bool Methods ==========

  /// Store a boolean value
  Future<bool> setBool(String key, bool value) async {
    _ensureInitialized();
    return await _prefs!.setBool(key, value);
  }

  /// Get a boolean value
  bool? getBool(String key) {
    _ensureInitialized();
    return _prefs!.getBool(key);
  }

  // ========== String List Methods ==========

  /// Store a list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    _ensureInitialized();
    return await _prefs!.setStringList(key, value);
  }

  /// Get a list of strings
  List<String>? getStringList(String key) {
    _ensureInitialized();
    return _prefs!.getStringList(key);
  }

  // ========== General Methods ==========

  /// Check if a key exists
  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  /// Remove a key-value pair
  Future<bool> remove(String key) async {
    _ensureInitialized();
    return await _prefs!.remove(key);
  }

  /// Clear all stored data
  Future<bool> clear() async {
    _ensureInitialized();
    return await _prefs!.clear();
  }

  /// Get all keys
  Set<String> getKeys() {
    _ensureInitialized();
    return _prefs!.getKeys();
  }

  /// Reload values from disk (useful if modified externally)
  Future<void> reload() async {
    _ensureInitialized();
    await _prefs!.reload();
  }

  /// Check if storage is initialized
  bool get isInitialized => _prefs != null;
}

/// Common storage keys used throughout the app
class StorageKeys {
  StorageKeys._();

  // ========== User Preferences ==========

  /// Selected theme mode: 'light', 'dark', 'system'
  static const String themeMode = 'theme_mode';

  /// Enable notifications
  static const String notificationsEnabled = 'notifications_enabled';

  /// Temperature unit: 'celsius', 'fahrenheit'
  static const String temperatureUnit = 'temperature_unit';

  /// Speed unit: 'kmh', 'mph'
  static const String speedUnit = 'speed_unit';

  /// Language code: 'en', 'pt', etc.
  static const String languageCode = 'language_code';

  // ========== App State ==========

  /// Last viewed session key
  static const String lastSessionKey = 'last_session_key';

  /// Last viewed meeting key
  static const String lastMeetingKey = 'last_meeting_key';

  /// Favorite driver numbers (comma-separated)
  static const String favoriteDrivers = 'favorite_drivers';

  /// Favorite team IDs (comma-separated)
  static const String favoriteTeams = 'favorite_teams';

  // ========== Onboarding ==========

  /// Has completed onboarding
  static const String onboardingCompleted = 'onboarding_completed';

  /// Has seen feature introduction
  static const String featureIntroSeen = 'feature_intro_seen';

  // ========== Cache Control ==========

  /// Last cache cleanup timestamp
  static const String lastCacheCleanup = 'last_cache_cleanup';

  /// Cache size limit in MB
  static const String cacheSizeLimit = 'cache_size_limit';

  // ========== API ==========

  /// API retry count preference
  static const String apiRetryCount = 'api_retry_count';

  /// Auto-refresh enabled for live timing
  static const String autoRefreshEnabled = 'auto_refresh_enabled';

  /// Polling interval in seconds
  static const String pollingInterval = 'polling_interval';
}
