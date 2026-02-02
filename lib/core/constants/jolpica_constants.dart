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

  /// Short cache TTL for current season data (1 hour)
  static const Duration shortCacheTTL = Duration(hours: 1);

  /// Medium cache TTL for race data (1 day)
  static const Duration mediumCacheTTL = Duration(days: 1);

  /// Permanent cache for completed races (365 days)
  static const Duration permanentCacheTTL = Duration(days: 365);

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

  /// Common driver ID mappings (driver number -> Jolpica/Ergast ID)
  /// Updated for 2026 season
  static const Map<int, String> driverIdMap = {
    // Red Bull Racing
    3: 'max_verstappen',
    6: 'hadjar',
    // Ferrari
    16: 'leclerc',
    44: 'hamilton',
    // Mercedes
    63: 'russell',
    12: 'antonelli',
    // McLaren
    4: 'norris',
    81: 'piastri',
    // Aston Martin
    14: 'alonso',
    18: 'stroll',
    // Alpine
    10: 'gasly',
    43: 'colapinto',
    // Williams
    23: 'albon',
    55: 'sainz',
    // RB F1 Team
    30: 'lawson',
    39: 'lindblad',
    // Audi
    27: 'hulkenberg',
    5: 'bortoleto',
    // Haas
    31: 'ocon',
    87: 'bearman',
    // Cadillac F1 Team
    77: 'bottas',
    11: 'perez',
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
