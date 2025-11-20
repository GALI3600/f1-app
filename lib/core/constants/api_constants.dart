/// OpenF1 API Constants
/// All 16 endpoints and configuration for the OpenF1 API
class ApiConstants {
  ApiConstants._();

  // ========== Base Configuration ==========

  /// Base URL for OpenF1 API
  static const String baseUrl = 'https://api.openf1.org/v1';

  /// Default timeout for API requests (30 seconds)
  static const int timeout = 30000; // milliseconds

  /// Client-side rate limit (60 requests per minute)
  static const int rateLimitPerMinute = 60;

  // ========== All 16 API Endpoints ==========

  /// Car telemetry data (~3.7 Hz frequency)
  /// Returns: brake, drs, n_gear, rpm, speed, throttle
  static const String carData = '/car_data';

  /// Driver information for each session
  /// Returns: driver details, team info, headshot URL
  static const String drivers = '/drivers';

  /// Gaps between drivers during races (~4s updates)
  /// Returns: gap_to_leader, interval
  static const String intervals = '/intervals';

  /// Lap times and sector information
  /// Returns: lap_duration, sector times, speeds
  static const String laps = '/laps';

  /// Car positions on track (~3.7 Hz frequency)
  /// Returns: x, y, z coordinates
  static const String location = '/location';

  /// Grand Prix weekend information
  /// Returns: meeting details, circuit info, dates
  static const String meetings = '/meetings';

  /// Overtaking events during races (Beta)
  /// Returns: overtaking driver, overtaken driver, position
  static const String overtakes = '/overtakes';

  /// Pit stop information
  /// Returns: pit_duration, lap_number
  static const String pit = '/pit';

  /// Driver positions throughout session
  /// Returns: position, date
  static const String position = '/position';

  /// Race control messages (flags, safety car, etc)
  /// Returns: category, flag, message, scope
  static const String raceControl = '/race_control';

  /// Session information (FP1, FP2, FP3, Qualifying, Race)
  /// Returns: session details, dates, circuit info
  static const String sessions = '/sessions';

  /// Final results of a session (Beta)
  /// Returns: position, dnf, dns, dsq, duration, gaps
  static const String sessionResult = '/session_result';

  /// Starting grid for races (Beta)
  /// Returns: grid position, driver, qualifying time
  static const String startingGrid = '/starting_grid';

  /// Tire stint information
  /// Returns: compound, stint_number, lap_start, lap_end
  static const String stints = '/stints';

  /// Team radio audio clips
  /// Returns: recording_url, date
  static const String teamRadio = '/team_radio';

  /// Weather conditions (~1 min updates)
  /// Returns: temperature, humidity, pressure, rainfall, wind
  static const String weather = '/weather';

  // ========== Cache TTL Strategies ==========

  /// Short cache TTL for live/frequently changing data (5 minutes)
  static const Duration shortCacheTTL = Duration(minutes: 5);

  /// Medium cache TTL for session data (1 hour)
  static const Duration mediumCacheTTL = Duration(hours: 1);

  /// Long cache TTL for historical data (7 days)
  static const Duration longCacheTTL = Duration(days: 7);

  /// Permanent cache for immutable data (365 days)
  static const Duration permanentCacheTTL = Duration(days: 365);

  // ========== Special Query Parameters ==========

  /// Use 'latest' for current/most recent meeting or session
  static const String latest = 'latest';

  /// Request CSV format instead of JSON
  static const String csvFormat = 'csv=true';

  // ========== Helper Methods ==========

  /// Get cache TTL based on endpoint
  static Duration getCacheTTL(String endpoint) {
    switch (endpoint) {
      // No cache - real-time data
      case carData:
      case location:
      case intervals:
        return Duration.zero;

      // Short cache - live session data
      case position:
      case weather:
      case raceControl:
      case overtakes:
      case pit:
        return shortCacheTTL;

      // Medium cache - session/current GP data
      case drivers:
      case sessions:
      case laps:
      case stints:
      case teamRadio:
        return mediumCacheTTL;

      // Long cache - historical data
      case meetings:
        return longCacheTTL;

      // Permanent cache - final results
      case sessionResult:
      case startingGrid:
        return permanentCacheTTL;

      default:
        return mediumCacheTTL;
    }
  }

  /// Check if endpoint should use polling for live updates
  static bool shouldPoll(String endpoint) {
    return [
      carData,
      location,
      intervals,
      position,
    ].contains(endpoint);
  }

  /// Get recommended polling interval for endpoint (in seconds)
  static int getPollingInterval(String endpoint) {
    switch (endpoint) {
      case carData:
      case location:
        return 3; // ~3.7 Hz ≈ 3 seconds
      case intervals:
      case position:
        return 4; // ~4 seconds
      case weather:
        return 60; // 1 minute
      default:
        return 10; // Default 10 seconds
    }
  }

  // ========== Endpoint Documentation ==========

  /// Get human-readable description of endpoint
  static String getEndpointDescription(String endpoint) {
    switch (endpoint) {
      case carData:
        return 'Car telemetry data (speed, RPM, gear, DRS, throttle, brake)';
      case drivers:
        return 'Driver information and team details';
      case intervals:
        return 'Time gaps between drivers during races';
      case laps:
        return 'Lap times and sector information';
      case location:
        return 'Car positions on track map';
      case meetings:
        return 'Grand Prix weekend information';
      case overtakes:
        return 'Overtaking events during races (Beta)';
      case pit:
        return 'Pit stop information';
      case position:
        return 'Driver position changes throughout session';
      case raceControl:
        return 'Race control messages and flags';
      case sessions:
        return 'Session information (FP, Qualifying, Race)';
      case sessionResult:
        return 'Final results of a session (Beta)';
      case startingGrid:
        return 'Starting grid for races (Beta)';
      case stints:
        return 'Tire stint strategy information';
      case teamRadio:
        return 'Team radio audio clips';
      case weather:
        return 'Weather conditions on track';
      default:
        return 'Unknown endpoint';
    }
  }
}
