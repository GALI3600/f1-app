/// F1Sync Application Constants
/// General app configuration and constant values
class AppConstants {
  AppConstants._();

  // ========== App Information ==========

  /// Application name
  static const String appName = 'F1Sync';

  /// Application version
  static const String appVersion = '1.0.0';

  /// Application build number
  static const int appBuildNumber = 1;

  /// Application package name (Android)
  static const String packageName = 'com.f1sync.app';

  /// Application bundle ID (iOS)
  static const String bundleId = 'com.f1sync.app';

  // ========== Developer Info ==========

  /// Developer/Company name
  static const String developerName = 'F1Sync Team';

  /// Support email
  static const String supportEmail = 'support@f1sync.app';

  /// Privacy policy URL
  static const String privacyPolicyUrl = 'https://f1sync.app/privacy';

  /// Terms of service URL
  static const String termsOfServiceUrl = 'https://f1sync.app/terms';

  // ========== Storage Keys ==========

  /// SharedPreferences key for theme mode
  static const String themeKey = 'theme_mode';

  /// SharedPreferences key for user preferences
  static const String preferencesKey = 'user_preferences';

  /// SharedPreferences key for favorite drivers
  static const String favoriteDriversKey = 'favorite_drivers';

  /// SharedPreferences key for favorite teams
  static const String favoriteTeamsKey = 'favorite_teams';

  /// SharedPreferences key for first launch
  static const String firstLaunchKey = 'first_launch';

  /// SharedPreferences key for last session key viewed
  static const String lastSessionKey = 'last_session_key';

  /// SharedPreferences key for notifications enabled
  static const String notificationsEnabledKey = 'notifications_enabled';

  // ========== Hive Box Names ==========

  /// Hive box for cached API responses
  static const String cacheBoxName = 'api_cache';

  /// Hive box for driver data
  static const String driversBoxName = 'drivers';

  /// Hive box for meetings data
  static const String meetingsBoxName = 'meetings';

  /// Hive box for sessions data
  static const String sessionsBoxName = 'sessions';

  /// Hive box for user favorites
  static const String favoritesBoxName = 'favorites';

  // ========== UI Constants ==========

  /// Default padding
  static const double defaultPadding = 16.0;

  /// Small padding
  static const double smallPadding = 8.0;

  /// Large padding
  static const double largePadding = 24.0;

  /// Default border radius
  static const double defaultBorderRadius = 12.0;

  /// Small border radius
  static const double smallBorderRadius = 8.0;

  /// Card elevation
  static const double cardElevation = 0.0;

  /// Default animation duration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  /// Fast animation duration
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  /// Slow animation duration
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // ========== Pagination ==========

  /// Default page size for paginated lists
  static const int defaultPageSize = 50;

  /// Maximum items to load at once
  static const int maxItemsPerLoad = 100;

  // ========== Images ==========

  /// Default placeholder image
  static const String placeholderImage = 'assets/images/placeholder.png';

  /// Default driver avatar placeholder
  static const String driverAvatarPlaceholder = 'assets/images/driver_placeholder.png';

  /// App logo
  static const String appLogo = 'assets/images/logo.png';

  // ========== Time Formats ==========

  /// Date format for display (e.g., "Nov 12, 2023")
  static const String displayDateFormat = 'MMM dd, yyyy';

  /// Date time format for display (e.g., "Nov 12, 2023 • 3:30 PM")
  static const String displayDateTimeFormat = 'MMM dd, yyyy • h:mm a';

  /// Time format for display (e.g., "3:30 PM")
  static const String displayTimeFormat = 'h:mm a';

  /// Lap time format (e.g., "1:23.456")
  static const String lapTimeFormat = 'm:ss.SSS';

  /// Gap time format (e.g., "+2.345")
  static const String gapTimeFormat = '+#.###';

  // ========== F1 Specific ==========

  /// Number of drivers in a typical F1 season
  static const int typicalDriverCount = 20;

  /// Number of teams in a typical F1 season
  static const int typicalTeamCount = 10;

  /// Number of races in a typical F1 season
  static const int typicalRaceCount = 23;

  /// Maximum speed expected (km/h) for gauges
  static const int maxSpeed = 380;

  /// Maximum RPM expected for gauges
  static const int maxRpm = 15000;

  /// Number of gears in F1 car (+ reverse)
  static const int numberOfGears = 8;

  /// Number of sectors per lap
  static const int sectorsPerLap = 3;

  // ========== Session Types ==========

  /// Practice session identifier
  static const String sessionTypePractice = 'Practice';

  /// Qualifying session identifier
  static const String sessionTypeQualifying = 'Qualifying';

  /// Race session identifier
  static const String sessionTypeRace = 'Race';

  /// Sprint session identifier
  static const String sessionTypeSprint = 'Sprint';

  // ========== Live Timing ==========

  /// Default polling interval for live timing (seconds)
  static const int liveTimingPollInterval = 4;

  /// Telemetry polling interval (seconds)
  static const int telemetryPollInterval = 3;

  /// Weather polling interval (seconds)
  static const int weatherPollInterval = 60;

  // ========== External Links ==========

  /// Jolpica F1 API documentation (Ergast successor)
  static const String jolpicaDocsUrl = 'https://github.com/jolpica/jolpica-f1';

  /// Official F1 website
  static const String officialF1Url = 'https://www.formula1.com';

  // ========== Feature Flags ==========

  /// Enable live timing feature
  static const bool enableLiveTiming = true;

  /// Enable team radio feature
  static const bool enableTeamRadio = true;

  /// Enable telemetry feature
  static const bool enableTelemetry = true;

  /// Enable notifications
  static const bool enableNotifications = false; // Phase 3

  /// Enable sharing
  static const bool enableSharing = true;

  // ========== Error Messages ==========

  /// Generic error message
  static const String genericError = 'Something went wrong. Please try again.';

  /// Network error message
  static const String networkError = 'No internet connection. Please check your network.';

  /// Timeout error message
  static const String timeoutError = 'Request timed out. Please try again.';

  /// Server error message
  static const String serverError = 'Server error. Please try again later.';

  /// No data error message
  static const String noDataError = 'No data available.';

  /// Cache error message
  static const String cacheError = 'Failed to load cached data.';
}

