import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/jolpica_constants.dart';
import '../models/driver_career.dart';

/// Remote data source for driver career statistics from Jolpica API
/// Optimized to use only 8 API requests instead of 20+
class DriverCareerRemoteDataSource {
  final Dio _dio;
  final Logger _logger = Logger();

  DriverCareerRemoteDataSource(this._dio);

  /// Delay between API calls to avoid rate limiting
  static const _requestDelay = Duration(milliseconds: 250);

  /// Fetch complete career stats for a driver (optimized: 8 requests)
  Future<DriverCareer?> getDriverCareer(String driverId) async {
    try {
      _logger.i('=== CAREER STATS FETCH START (Optimized) ===');
      _logger.i('Fetching career stats for driver: $driverId');

      final stopwatch = Stopwatch()..start();

      // 1. Driver info (1 request)
      final driverInfo = await _fetchDriverInfo(driverId);
      if (driverInfo == null) {
        _logger.w('Driver info not found, aborting fetch');
        return null;
      }

      // 2. Wins (1 request)
      await Future.delayed(_requestDelay);
      final wins = await _fetchDriverWins(driverId);

      // 3. Total races + seasons (1 request - reuse data)
      await Future.delayed(_requestDelay);
      final racesData = await _fetchDriverRacesData(driverId);
      final totalRaces = racesData['total'] as int;
      final seasons = racesData['seasons'] as int;

      // 4. Poles (1 request)
      await Future.delayed(_requestDelay);
      final poles = await _fetchDriverPoles(driverId);

      // 5-7. Podiums P1+P2+P3 (3 requests)
      await Future.delayed(_requestDelay);
      final podiums = await _fetchDriverPodiums(driverId);

      // 8. Current year standings only (1 request)
      await Future.delayed(_requestDelay);
      final currentStanding = await _fetchCurrentYearStanding(driverId);

      // Get championship data from constants (0 requests!)
      final championshipYears = JolpicaConstants.getChampionshipYears(driverId);

      _logger.d('Fetch completed in ${stopwatch.elapsedMilliseconds}ms (8 requests)');

      final career = DriverCareer.fromJolpicaJson(
        driverInfo: driverInfo,
        wins: wins,
        podiums: podiums,
        poles: poles,
        totalRaces: totalRaces,
        seasons: seasons,
        championshipYears: championshipYears,
        currentPosition: currentStanding?['position'] as int?,
        currentPoints: currentStanding?['points'] as double?,
      );

      stopwatch.stop();
      _logger.i('=== CAREER STATS FETCH COMPLETE ===');
      _logger.i('Driver: ${career.fullName}');
      _logger.i('Stats: ${career.wins} wins, ${career.poles} poles, ${career.podiums} podiums');
      _logger.i('Championships: ${career.championships} (years: ${career.championshipYears?.join(", ") ?? "none"})');
      _logger.i('Seasons: ${career.seasons}, Total races: ${career.totalRaces}');
      _logger.i('Total fetch time: ${stopwatch.elapsedMilliseconds}ms');

      return career;
    } catch (e, stackTrace) {
      _logger.e('=== CAREER STATS FETCH ERROR ===');
      _logger.e('Error fetching career stats for $driverId: $e');
      _logger.e('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Fetch driver basic info
  Future<Map<String, dynamic>?> _fetchDriverInfo(String driverId) async {
    final url = JolpicaConstants.driverUrl(driverId);
    _logger.d('[DriverInfo] Fetching: $url');
    try {
      final response = await _dio.get(url);
      _logger.d('[DriverInfo] Response status: ${response.statusCode}');

      final data = response.data as Map<String, dynamic>;
      final drivers = data['MRData']?['DriverTable']?['Drivers'] as List?;

      if (drivers != null && drivers.isNotEmpty) {
        final driver = drivers[0] as Map<String, dynamic>;
        _logger.d('[DriverInfo] Found: ${driver['givenName']} ${driver['familyName']}');
        return driver;
      }
      _logger.w('[DriverInfo] No driver found in response');
      return null;
    } catch (e) {
      _logger.e('[DriverInfo] Failed: $e');
      return null;
    }
  }

  /// Fetch driver wins count
  Future<int> _fetchDriverWins(String driverId) async {
    final url = JolpicaConstants.driverWinsUrl(driverId);
    _logger.d('[Wins] Fetching: $url');
    try {
      final response = await _dio.get(
        url,
        queryParameters: {'limit': 1},
      );

      final data = response.data as Map<String, dynamic>;
      final total = data['MRData']?['total'];
      final wins = int.tryParse(total?.toString() ?? '0') ?? 0;
      _logger.d('[Wins] Total wins: $wins');
      return wins;
    } catch (e) {
      _logger.e('[Wins] Failed: $e');
      return 0;
    }
  }

  /// Fetch driver podiums count (positions 1, 2, 3)
  Future<int> _fetchDriverPodiums(String driverId) async {
    _logger.d('[Podiums] Fetching P1, P2, P3 counts sequentially...');
    try {
      // Fetch P1, P2, P3 sequentially to avoid rate limiting
      final p1 = await _fetchPositionCount(driverId, 1);
      await Future.delayed(_requestDelay);
      final p2 = await _fetchPositionCount(driverId, 2);
      await Future.delayed(_requestDelay);
      final p3 = await _fetchPositionCount(driverId, 3);

      final podiums = p1 + p2 + p3;
      _logger.d('[Podiums] P1=$p1, P2=$p2, P3=$p3, Total=$podiums');
      return podiums;
    } catch (e) {
      _logger.e('[Podiums] Failed: $e');
      return 0;
    }
  }

  /// Fetch count of finishes in a specific position
  Future<int> _fetchPositionCount(String driverId, int position) async {
    final url = '${JolpicaConstants.baseUrl}/drivers/$driverId/results/$position.json';
    try {
      final response = await _dio.get(
        url,
        queryParameters: {'limit': 1},
      );

      final data = response.data as Map<String, dynamic>;
      final total = data['MRData']?['total'];
      return int.tryParse(total?.toString() ?? '0') ?? 0;
    } catch (e) {
      _logger.w('[Position P$position] Failed: $e');
      return 0;
    }
  }

  /// Fetch driver pole positions count
  Future<int> _fetchDriverPoles(String driverId) async {
    final url = JolpicaConstants.driverPolesUrl(driverId);
    _logger.d('[Poles] Fetching: $url');
    try {
      final response = await _dio.get(
        url,
        queryParameters: {'limit': 1},
      );

      final data = response.data as Map<String, dynamic>;
      final total = data['MRData']?['total'];
      final poles = int.tryParse(total?.toString() ?? '0') ?? 0;
      _logger.d('[Poles] Total poles: $poles');
      return poles;
    } catch (e) {
      _logger.e('[Poles] Failed: $e');
      return 0;
    }
  }

  /// Fetch total races and calculate seasons from first/last race years
  Future<Map<String, dynamic>> _fetchDriverRacesData(String driverId) async {
    final url = JolpicaConstants.driverResultsUrl(driverId);
    _logger.d('[RacesData] Fetching: $url');
    try {
      // Get first race to find first season
      final firstResponse = await _dio.get(
        url,
        queryParameters: {'limit': 1, 'offset': 0},
      );

      final data = firstResponse.data as Map<String, dynamic>;
      final total = int.tryParse(data['MRData']?['total']?.toString() ?? '0') ?? 0;
      final races = data['MRData']?['RaceTable']?['Races'] as List?;

      int seasons = 0;
      if (races != null && races.isNotEmpty) {
        final firstYear = int.tryParse(races[0]['season']?.toString() ?? '') ?? DateTime.now().year;
        final currentYear = DateTime.now().year;
        seasons = currentYear - firstYear + 1;
        _logger.d('[RacesData] First season: $firstYear, Seasons: $seasons');
      }

      _logger.d('[RacesData] Total races: $total, Seasons: $seasons');
      return {'total': total, 'seasons': seasons};
    } catch (e) {
      _logger.e('[RacesData] Failed: $e');
      return {'total': 0, 'seasons': 0};
    }
  }

  /// Fetch current year standings only (1 request instead of N)
  Future<Map<String, dynamic>?> _fetchCurrentYearStanding(String driverId) async {
    final currentYear = DateTime.now().year;
    final url = '${JolpicaConstants.baseUrl}/$currentYear/driverstandings.json';
    _logger.d('[CurrentStanding] Fetching: $url');

    try {
      final response = await _dio.get(url);
      final data = response.data as Map<String, dynamic>;
      final standingsLists = data['MRData']?['StandingsTable']?['StandingsLists'] as List?;

      if (standingsLists == null || standingsLists.isEmpty) {
        return null;
      }

      final standings = standingsLists[0] as Map<String, dynamic>;
      final driverStandings = standings['DriverStandings'] as List?;

      if (driverStandings == null) return null;

      // Find this driver in the standings
      for (final ds in driverStandings) {
        final driver = ds['Driver'] as Map<String, dynamic>?;
        if (driver != null && driver['driverId'] == driverId) {
          final position = int.tryParse(ds['position']?.toString() ?? '');
          final points = double.tryParse(ds['points']?.toString() ?? '');
          _logger.d('[CurrentStanding] P$position with $points pts');
          return {'position': position, 'points': points};
        }
      }

      return null;
    } catch (e) {
      _logger.w('[CurrentStanding] Failed: $e');
      return null;
    }
  }

  /// Get driver ID from driver number
  String? getDriverIdFromNumber(int driverNumber) {
    return JolpicaConstants.getDriverId(driverNumber);
  }
}
