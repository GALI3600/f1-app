/// Jolpica F1 API Constants
/// Provides historical F1 data including career statistics
/// API Docs: https://github.com/jolpica/jolpica-f1
class JolpicaConstants {
  JolpicaConstants._();

  // ========== Base Configuration ==========

  /// Base URL for Jolpica API
  static const String baseUrl = 'https://api.jolpi.ca/ergast/f1';

  /// Default timeout for API requests (30 seconds)
  static const int timeout = 30000;

  /// Rate limit (200 requests per hour)
  static const int rateLimitPerHour = 200;

  // ========== Endpoints ==========

  /// All seasons
  static const String seasons = '/seasons';

  /// All circuits
  static const String circuits = '/circuits';

  /// Drivers (use with year or driverId)
  static const String drivers = '/drivers';

  /// Constructors/Teams
  static const String constructors = '/constructors';

  /// Race results
  static const String results = '/results';

  /// Sprint results
  static const String sprint = '/sprint';

  /// Qualifying results
  static const String qualifying = '/qualifying';

  /// Pit stops
  static const String pitstops = '/pitstops';

  /// Lap times
  static const String laps = '/laps';

  /// Driver standings
  static const String driverStandings = '/driverstandings';

  /// Constructor standings
  static const String constructorStandings = '/constructorstandings';

  /// Race status codes
  static const String status = '/status';

  // ========== Cache Configuration ==========

  /// Long cache for historical data (7 days)
  static const Duration cacheTTL = Duration(days: 7);

  // ========== Helper Methods ==========

  /// Build URL for driver info
  static String driverUrl(String driverId) => '$baseUrl/drivers/$driverId.json';

  /// Build URL for driver's race wins
  static String driverWinsUrl(String driverId) =>
      '$baseUrl/drivers/$driverId/results/1.json';

  /// Build URL for driver's pole positions
  static String driverPolesUrl(String driverId) =>
      '$baseUrl/drivers/$driverId/qualifying/1.json';

  /// Build URL for driver's podiums (top 3)
  static String driverPodiumsUrl(String driverId, int position) =>
      '$baseUrl/drivers/$driverId/results/$position.json';

  /// Build URL for a specific year's driver standings
  static String yearStandingsUrl(int year) =>
      '$baseUrl/$year/driverstandings.json';

  /// Build URL for driver's all results
  static String driverResultsUrl(String driverId) =>
      '$baseUrl/drivers/$driverId/results.json';

  /// Build URL for current season standings
  static String currentStandingsUrl(int year) =>
      '$baseUrl/$year/driverstandings.json';

  /// Convert driver name to Jolpica driver ID format
  /// e.g., "Max Verstappen" -> "max_verstappen"
  static String toDriverId(String fullName) {
    return fullName.toLowerCase().replaceAll(' ', '_');
  }

  /// Common driver ID mappings (OpenF1 number -> Jolpica/Ergast ID)
  /// Note: Jolpica uses last name format, not full_name format
  static const Map<int, String> driverIdMap = {
    1: 'max_verstappen',
    4: 'norris',
    10: 'gasly',
    11: 'perez',
    14: 'alonso',
    16: 'leclerc',
    18: 'stroll',
    20: 'kevin_magnussen',
    22: 'tsunoda',
    23: 'albon',
    24: 'zhou',
    27: 'hulkenberg',
    31: 'ocon',
    44: 'hamilton',
    55: 'sainz',
    63: 'russell',
    77: 'bottas',
    81: 'piastri',
    // 2025 rookies
    6: 'hadjar',
    12: 'antonelli',
    30: 'lawson',
    43: 'colapinto',
    61: 'doohan',
    87: 'bearman',
  };

  /// Get Jolpica driver ID from driver number
  static String? getDriverId(int driverNumber) => driverIdMap[driverNumber];

  // ========== Championship Data (Historical - doesn't change) ==========

  /// World Championship years by driver ID
  /// This avoids fetching standings for every year of a driver's career
  static const Map<String, List<int>> championshipYears = {
    'hamilton': [2008, 2014, 2015, 2017, 2018, 2019, 2020],
    'max_verstappen': [2021, 2022, 2023, 2024],
    'vettel': [2010, 2011, 2012, 2013],
    'alonso': [2005, 2006],
    'raikkonen': [2007],
    'button': [2009],
    'rosberg': [2016],
    'schumacher': [1994, 1995, 2000, 2001, 2002, 2003, 2004],
    'hakkinen': [1998, 1999],
    'hill': [1996],
    'villeneuve': [1997],
  };

  /// Get championship years for a driver
  static List<int>? getChampionshipYears(String driverId) =>
      championshipYears[driverId];

  /// Get championship count for a driver
  static int getChampionshipCount(String driverId) =>
      championshipYears[driverId]?.length ?? 0;
}
