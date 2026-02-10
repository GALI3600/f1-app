import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/jolpica_constants.dart';
import '../models/driver_career.dart';

/// Remote data source for driver career statistics from Jolpica API
/// Optimized: Only fetches data that can't be calculated from race history
class DriverCareerRemoteDataSource {
  final Dio _dio;
  final Logger _logger = Logger();

  DriverCareerRemoteDataSource(this._dio);

  /// Delay between API calls to avoid rate limiting
  /// Queue already serializes requests; this is extra safety margin
  static const _requestDelay = Duration(milliseconds: 300);

  /// Max retries for 429 errors
  static const _maxRetries = 3;

  /// Global queue to serialize all API requests and avoid 429 floods
  static final _requestQueue = _RequestQueue();

  /// Make a request with retry logic for 429 errors, serialized via global queue
  Future<Response<dynamic>> _requestWithRetry(String url, {Map<String, dynamic>? queryParameters}) async {
    return _requestQueue.enqueue(() async {
      for (int attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          return await _dio.get(url, queryParameters: queryParameters);
        } on DioException catch (e) {
          if (e.response?.statusCode == 429 && attempt < _maxRetries - 1) {
            final waitTime = Duration(seconds: 3 * (attempt + 1));
            _logger.w('[RateLimit] 429 received, waiting ${waitTime.inSeconds}s before retry ${attempt + 1}/$_maxRetries');
            await Future.delayed(waitTime);
          } else {
            rethrow;
          }
        }
      }
      throw Exception('Max retries exceeded');
    });
  }

  /// Fetch career stats that can't be calculated from race history
  /// Only fetches: driver info, poles, seasons, standings, championships
  /// Wins, podiums, totalRaces should be passed from race history
  Future<DriverCareer?> getDriverCareerOptimized({
    required String driverId,
    required int wins,
    required int podiums,
    required int totalRaces,
  }) async {
    try {
      _logger.i('=== CAREER STATS FETCH (Optimized) ===');
      _logger.i('Fetching for driver: $driverId (wins=$wins, podiums=$podiums, races=$totalRaces from history)');

      final stopwatch = Stopwatch()..start();

      // 1. Driver info (1 request)
      final driverInfo = await _fetchDriverInfo(driverId);
      if (driverInfo == null) {
        _logger.w('Driver info not found, aborting fetch');
        return null;
      }

      // 2. Seasons list (1 request) - needed for championships check
      await Future.delayed(_requestDelay);
      final seasonsData = await _fetchSeasons(driverId);
      final seasons = seasonsData['seasons'] as int;
      final activeYears = seasonsData['activeYears'] as List<int>;

      // 3. Poles (1 request) - can't get from race results
      await Future.delayed(_requestDelay);
      final poles = await _fetchDriverPoles(driverId);

      // 4. Current year standings (1 request)
      await Future.delayed(_requestDelay);
      final currentStanding = await _fetchCurrentYearStanding(driverId);

      // 5. Championship years (2-3 requests for recent years only)
      await Future.delayed(_requestDelay);
      final championshipYears = await _fetchChampionshipYears(driverId, activeYears);

      _logger.d('Fetch completed in ${stopwatch.elapsedMilliseconds}ms (~5-7 requests)');

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
      _logger.i('=== CAREER STATS COMPLETE ===');
      _logger.i('Driver: ${career.fullName}');
      _logger.i('Stats: ${career.wins} wins, ${career.poles} poles, ${career.podiums} podiums');
      _logger.i('Championships: ${career.championships}');
      _logger.i('Total time: ${stopwatch.elapsedMilliseconds}ms');

      return career;
    } catch (e, stackTrace) {
      _logger.e('Error fetching career stats for $driverId: $e');
      _logger.e('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Legacy method - fetches everything (for backwards compatibility)
  Future<DriverCareer?> getDriverCareer(String driverId) async {
    // Fetch wins and podiums the old way if race history not available
    final wins = await _fetchDriverWins(driverId);
    await Future.delayed(_requestDelay);
    final podiums = await _fetchDriverPodiums(driverId);
    await Future.delayed(_requestDelay);
    final totalRaces = await _fetchTotalRaces(driverId);

    return getDriverCareerOptimized(
      driverId: driverId,
      wins: wins,
      podiums: podiums,
      totalRaces: totalRaces,
    );
  }

  /// Fetch driver basic info
  Future<Map<String, dynamic>?> _fetchDriverInfo(String driverId) async {
    final url = JolpicaConstants.driverUrl(driverId);
    _logger.d('[DriverInfo] Fetching: $url');
    try {
      final response = await _requestWithRetry(url);
      final data = response.data as Map<String, dynamic>;
      final drivers = data['MRData']?['DriverTable']?['Drivers'] as List?;

      if (drivers != null && drivers.isNotEmpty) {
        return drivers[0] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _logger.e('[DriverInfo] Failed: $e');
      return null;
    }
  }

  /// Fetch seasons data
  Future<Map<String, dynamic>> _fetchSeasons(String driverId) async {
    final url = '${JolpicaConstants.baseUrl}/drivers/$driverId/seasons.json';
    _logger.d('[Seasons] Fetching: $url');
    try {
      final response = await _requestWithRetry(url, queryParameters: {'limit': 100});
      final data = response.data as Map<String, dynamic>;
      final seasonsList = data['MRData']?['SeasonTable']?['Seasons'] as List? ?? [];

      final activeYears = <int>[];
      for (final season in seasonsList) {
        final year = int.tryParse(season['season']?.toString() ?? '');
        if (year != null) activeYears.add(year);
      }
      activeYears.sort();

      return {'seasons': activeYears.length, 'activeYears': activeYears};
    } catch (e) {
      _logger.e('[Seasons] Failed: $e');
      return {'seasons': 0, 'activeYears': <int>[]};
    }
  }

  /// Fetch driver pole positions (can't be calculated from race results)
  Future<int> _fetchDriverPoles(String driverId) async {
    final url = '${JolpicaConstants.baseUrl}/drivers/$driverId/qualifying.json';
    _logger.d('[Poles] Fetching: $url');
    try {
      final response = await _requestWithRetry(url, queryParameters: {'limit': 500});
      final data = response.data as Map<String, dynamic>;
      final races = data['MRData']?['RaceTable']?['Races'] as List? ?? [];

      int poles = 0;
      for (final race in races) {
        final qualifyingResults = race['QualifyingResults'] as List? ?? [];
        if (qualifyingResults.isNotEmpty) {
          final position = qualifyingResults[0]['position']?.toString();
          if (position == '1') poles++;
        }
      }

      _logger.d('[Poles] Total: $poles');
      return poles;
    } catch (e) {
      _logger.e('[Poles] Failed: $e');
      return 0;
    }
  }

  /// Fetch current year standings
  Future<Map<String, dynamic>?> _fetchCurrentYearStanding(String driverId) async {
    final currentYear = DateTime.now().year;
    final url = '${JolpicaConstants.baseUrl}/$currentYear/driverstandings.json';
    _logger.d('[Standings] Fetching: $url');

    try {
      final response = await _requestWithRetry(url);
      final data = response.data as Map<String, dynamic>;
      final standingsLists = data['MRData']?['StandingsTable']?['StandingsLists'] as List?;

      if (standingsLists == null || standingsLists.isEmpty) return null;

      final driverStandings = standingsLists[0]['DriverStandings'] as List?;
      if (driverStandings == null) return null;

      for (final ds in driverStandings) {
        if (ds['Driver']?['driverId'] == driverId) {
          return {
            'position': int.tryParse(ds['position']?.toString() ?? ''),
            'points': double.tryParse(ds['points']?.toString() ?? ''),
          };
        }
      }
      return null;
    } catch (e) {
      _logger.w('[Standings] Failed: $e');
      return null;
    }
  }

  /// Fetch championship years (hybrid: hardcoded + recent from API)
  Future<List<int>> _fetchChampionshipYears(String driverId, List<int> activeYears) async {
    final championshipYears = <int>[
      ...?JolpicaConstants.getChampionshipYears(driverId),
    ];

    final currentYear = DateTime.now().year;
    final recentYears = activeYears.where((y) => y >= currentYear - 2).toList();
    final yearsToCheck = recentYears.where((y) => !championshipYears.contains(y)).toList();

    if (yearsToCheck.isEmpty) {
      return championshipYears..sort();
    }

    _logger.d('[Championships] Checking recent years: $yearsToCheck');

    for (final year in yearsToCheck) {
      try {
        final url = '${JolpicaConstants.baseUrl}/$year/driverStandings/1.json';
        final response = await _requestWithRetry(url);
        final data = response.data as Map<String, dynamic>;
        final standingsLists = data['MRData']?['StandingsTable']?['StandingsLists'] as List?;

        if (standingsLists != null && standingsLists.isNotEmpty) {
          final driverStandings = standingsLists[0]['DriverStandings'] as List?;
          if (driverStandings != null && driverStandings.isNotEmpty) {
            final championDriverId = driverStandings[0]['Driver']?['driverId'];
            if (championDriverId == driverId) {
              championshipYears.add(year);
              _logger.d('[Championships] Found: $year');
            }
          }
        }
        await Future.delayed(_requestDelay);
      } catch (e) {
        _logger.w('[Championships] Error checking $year: $e');
      }
    }

    return championshipYears..sort();
  }

  // Legacy methods for backwards compatibility
  Future<int> _fetchDriverWins(String driverId) async {
    final url = JolpicaConstants.driverWinsUrl(driverId);
    try {
      final response = await _requestWithRetry(url, queryParameters: {'limit': 1});
      final total = response.data['MRData']?['total'];
      return int.tryParse(total?.toString() ?? '0') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _fetchDriverPodiums(String driverId) async {
    try {
      final p1 = await _fetchPositionCount(driverId, 1);
      await Future.delayed(_requestDelay);
      final p2 = await _fetchPositionCount(driverId, 2);
      await Future.delayed(_requestDelay);
      final p3 = await _fetchPositionCount(driverId, 3);
      return p1 + p2 + p3;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _fetchPositionCount(String driverId, int position) async {
    final url = '${JolpicaConstants.baseUrl}/drivers/$driverId/results/$position.json';
    try {
      final response = await _requestWithRetry(url, queryParameters: {'limit': 1});
      final total = response.data['MRData']?['total'];
      return int.tryParse(total?.toString() ?? '0') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _fetchTotalRaces(String driverId) async {
    final url = JolpicaConstants.driverResultsUrl(driverId);
    try {
      final response = await _requestWithRetry(url, queryParameters: {'limit': 1});
      final total = response.data['MRData']?['total'];
      return int.tryParse(total?.toString() ?? '0') ?? 0;
    } catch (e) {
      return 0;
    }
  }
}

/// Simple FIFO queue that serializes async operations to prevent concurrent API floods
class _RequestQueue {
  Future<void> _last = Future.value();

  Future<T> enqueue<T>(Future<T> Function() task) {
    final completer = Completer<T>();
    final previous = _last;
    _last = completer.future.catchError((_) {});

    () async {
      await previous;
      try {
        final result = await task();
        completer.complete(result);
      } catch (e, s) {
        completer.completeError(e, s);
      }
    }();

    return completer.future;
  }
}
