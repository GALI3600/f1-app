import 'package:dio/dio.dart';
import 'package:f1sync/core/network/api_exception.dart';
import 'package:f1sync/core/network/rate_limiter.dart';

/// HTTP client for Jolpica F1 API (Ergast successor)
///
/// Features:
/// - Generic methods for type-safe responses
/// - Automatic retry with exponential backoff (3 attempts)
/// - Rate limiting (200 requests/hour)
/// - Handles Jolpica's MRData response format
///
/// Endpoints:
/// - Drivers: /{season}/drivers.json
/// - Races: /{season}.json
/// - Results: /{season}/{round}/results.json
/// - Qualifying: /{season}/{round}/qualifying.json
/// - Sprint: /{season}/{round}/sprint.json
/// - Laps: /{season}/{round}/laps.json
/// - Laps by driver: /{season}/{round}/drivers/{driverId}/laps.json
class JolpicaApiClient {
  final Dio _dio;
  final RateLimiter _rateLimiter;

  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(seconds: 2);

  JolpicaApiClient(
    this._dio, {
    RateLimiter? rateLimiter,
  }) : _rateLimiter = rateLimiter ?? RateLimiter();

  /// Fetch drivers for a specific season
  ///
  /// [season] can be a year (e.g., 2026) or 'current'
  Future<List<T>> getDrivers<T>({
    required T Function(Map<String, dynamic>) fromJson,
    dynamic season = 'current',
  }) async {
    await _rateLimiter.waitIfNeeded();

    return await _retryRequest(() async {
      try {
        final response = await _dio.get('/$season/drivers.json');

        if (response.data is Map<String, dynamic>) {
          final mrData = response.data['MRData'] as Map<String, dynamic>?;
          final driverTable = mrData?['DriverTable'] as Map<String, dynamic>?;
          final drivers = driverTable?['Drivers'] as List?;

          if (drivers != null) {
            return drivers
                .map((json) => fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }

        return [];
      } on DioException catch (e) {
        throw _handleError(e);
      } catch (e) {
        throw ParseException('Failed to parse Jolpica response: $e');
      }
    });
  }

  /// Fetch a single driver by ID
  Future<T?> getDriver<T>({
    required String driverId,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    await _rateLimiter.waitIfNeeded();

    return await _retryRequest(() async {
      try {
        final response = await _dio.get('/drivers/$driverId.json');

        if (response.data is Map<String, dynamic>) {
          final mrData = response.data['MRData'] as Map<String, dynamic>?;
          final driverTable = mrData?['DriverTable'] as Map<String, dynamic>?;
          final drivers = driverTable?['Drivers'] as List?;

          if (drivers != null && drivers.isNotEmpty) {
            return fromJson(drivers.first as Map<String, dynamic>);
          }
        }

        return null;
      } on DioException catch (e) {
        throw _handleError(e);
      } catch (e) {
        throw ParseException('Failed to parse Jolpica response: $e');
      }
    });
  }

  /// Generic GET request for Jolpica API
  Future<Map<String, dynamic>?> get(String path) async {
    await _rateLimiter.waitIfNeeded();

    return await _retryRequest(() async {
      try {
        final response = await _dio.get(path);

        if (response.data is Map<String, dynamic>) {
          return response.data['MRData'] as Map<String, dynamic>?;
        }

        return null;
      } on DioException catch (e) {
        throw _handleError(e);
      }
    });
  }

  /// Fetch races (meetings) for a specific season
  ///
  /// [season] can be a year (e.g., 2026) or 'current'
  Future<List<T>> getRaces<T>({
    required T Function(Map<String, dynamic>) fromJson,
    dynamic season = 'current',
  }) async {
    await _rateLimiter.waitIfNeeded();

    return await _retryRequest(() async {
      try {
        final response = await _dio.get('/$season.json');

        if (response.data is Map<String, dynamic>) {
          final mrData = response.data['MRData'] as Map<String, dynamic>?;
          final raceTable = mrData?['RaceTable'] as Map<String, dynamic>?;
          final races = raceTable?['Races'] as List?;

          if (races != null) {
            return races
                .map((json) => fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }

        return [];
      } on DioException catch (e) {
        throw _handleError(e);
      } catch (e) {
        throw ParseException('Failed to parse Jolpica races response: $e');
      }
    });
  }

  /// Fetch a single race by round
  Future<T?> getRace<T>({
    required T Function(Map<String, dynamic>) fromJson,
    required int round,
    dynamic season = 'current',
  }) async {
    await _rateLimiter.waitIfNeeded();

    return await _retryRequest(() async {
      try {
        final response = await _dio.get('/$season/$round.json');

        if (response.data is Map<String, dynamic>) {
          final mrData = response.data['MRData'] as Map<String, dynamic>?;
          final raceTable = mrData?['RaceTable'] as Map<String, dynamic>?;
          final races = raceTable?['Races'] as List?;

          if (races != null && races.isNotEmpty) {
            return fromJson(races.first as Map<String, dynamic>);
          }
        }

        return null;
      } on DioException catch (e) {
        throw _handleError(e);
      } catch (e) {
        throw ParseException('Failed to parse Jolpica race response: $e');
      }
    });
  }

  /// Fetch race results for a specific round
  ///
  /// [season] can be a year (e.g., 2026) or 'current'
  /// [round] is the race number in the season
  Future<List<T>> getResults<T>({
    required T Function(Map<String, dynamic>) fromJson,
    required int round,
    dynamic season = 'current',
  }) async {
    await _rateLimiter.waitIfNeeded();

    return await _retryRequest(() async {
      try {
        final response = await _dio.get('/$season/$round/results.json');

        if (response.data is Map<String, dynamic>) {
          final mrData = response.data['MRData'] as Map<String, dynamic>?;
          final raceTable = mrData?['RaceTable'] as Map<String, dynamic>?;
          final races = raceTable?['Races'] as List?;

          if (races != null && races.isNotEmpty) {
            final race = races.first as Map<String, dynamic>;
            final results = race['Results'] as List?;

            if (results != null) {
              return results
                  .map((json) => fromJson(json as Map<String, dynamic>))
                  .toList();
            }
          }
        }

        return [];
      } on DioException catch (e) {
        throw _handleError(e);
      } catch (e) {
        throw ParseException('Failed to parse Jolpica results response: $e');
      }
    });
  }

  /// Fetch qualifying results for a specific round
  Future<List<T>> getQualifying<T>({
    required T Function(Map<String, dynamic>) fromJson,
    required int round,
    dynamic season = 'current',
  }) async {
    await _rateLimiter.waitIfNeeded();

    return await _retryRequest(() async {
      try {
        final response = await _dio.get('/$season/$round/qualifying.json');

        if (response.data is Map<String, dynamic>) {
          final mrData = response.data['MRData'] as Map<String, dynamic>?;
          final raceTable = mrData?['RaceTable'] as Map<String, dynamic>?;
          final races = raceTable?['Races'] as List?;

          if (races != null && races.isNotEmpty) {
            final race = races.first as Map<String, dynamic>;
            final results = race['QualifyingResults'] as List?;

            if (results != null) {
              return results
                  .map((json) => fromJson(json as Map<String, dynamic>))
                  .toList();
            }
          }
        }

        return [];
      } on DioException catch (e) {
        throw _handleError(e);
      } catch (e) {
        throw ParseException('Failed to parse Jolpica qualifying response: $e');
      }
    });
  }

  /// Fetch sprint results for a specific round
  Future<List<T>> getSprint<T>({
    required T Function(Map<String, dynamic>) fromJson,
    required int round,
    dynamic season = 'current',
  }) async {
    await _rateLimiter.waitIfNeeded();

    return await _retryRequest(() async {
      try {
        final response = await _dio.get('/$season/$round/sprint.json');

        if (response.data is Map<String, dynamic>) {
          final mrData = response.data['MRData'] as Map<String, dynamic>?;
          final raceTable = mrData?['RaceTable'] as Map<String, dynamic>?;
          final races = raceTable?['Races'] as List?;

          if (races != null && races.isNotEmpty) {
            final race = races.first as Map<String, dynamic>;
            final results = race['SprintResults'] as List?;

            if (results != null) {
              return results
                  .map((json) => fromJson(json as Map<String, dynamic>))
                  .toList();
            }
          }
        }

        return [];
      } on DioException catch (e) {
        throw _handleError(e);
      } catch (e) {
        throw ParseException('Failed to parse Jolpica sprint response: $e');
      }
    });
  }

  /// Fetch lap times for a specific round
  ///
  /// Returns all laps for all drivers in the race
  Future<List<T>> getLaps<T>({
    required T Function(Map<String, dynamic>) fromJson,
    required int round,
    dynamic season = 'current',
    String? driverId,
    int? lapNumber,
  }) async {
    await _rateLimiter.waitIfNeeded();

    return await _retryRequest(() async {
      try {
        String path;
        if (driverId != null) {
          path = lapNumber != null
              ? '/$season/$round/drivers/$driverId/laps/$lapNumber.json'
              : '/$season/$round/drivers/$driverId/laps.json';
        } else {
          path = lapNumber != null
              ? '/$season/$round/laps/$lapNumber.json'
              : '/$season/$round/laps.json';
        }

        final response = await _dio.get(path);

        if (response.data is Map<String, dynamic>) {
          final mrData = response.data['MRData'] as Map<String, dynamic>?;
          final raceTable = mrData?['RaceTable'] as Map<String, dynamic>?;
          final races = raceTable?['Races'] as List?;

          if (races != null && races.isNotEmpty) {
            final race = races.first as Map<String, dynamic>;
            final laps = race['Laps'] as List?;

            if (laps != null) {
              final result = <T>[];
              for (final lap in laps) {
                final lapMap = lap as Map<String, dynamic>;
                final lapNum = int.tryParse(lapMap['number']?.toString() ?? '') ?? 0;
                final timings = lapMap['Timings'] as List?;

                if (timings != null) {
                  for (final timing in timings) {
                    final timingMap = timing as Map<String, dynamic>;
                    // Merge lap number into timing data
                    final enrichedTiming = {
                      ...timingMap,
                      'lapNumber': lapNum,
                      'round': round,
                      'season': season,
                    };
                    result.add(fromJson(enrichedTiming));
                  }
                }
              }
              return result;
            }
          }
        }

        return [];
      } on DioException catch (e) {
        throw _handleError(e);
      } catch (e) {
        throw ParseException('Failed to parse Jolpica laps response: $e');
      }
    });
  }

  /// Fetch all race results for a specific driver
  ///
  /// Returns the driver's complete race history with automatic pagination.
  /// Fetches all pages until all results are retrieved.
  /// [driverId] is the driver's ID (e.g., "max_verstappen")
  Future<List<Map<String, dynamic>>> getDriverResults({
    required String driverId,
  }) async {
    final allResults = <Map<String, dynamic>>[];
    int offset = 0;
    const int limit = 100;
    int? total;

    do {
      await _rateLimiter.waitIfNeeded();

      final pageResults = await _retryRequest(() async {
        try {
          final response = await _dio.get(
            '/drivers/$driverId/results.json',
            queryParameters: {
              'limit': limit,
              'offset': offset,
            },
          );

          if (response.data is Map<String, dynamic>) {
            final mrData = response.data['MRData'] as Map<String, dynamic>?;

            // Get total count on first request
            if (total == null && mrData != null) {
              total = int.tryParse(mrData['total']?.toString() ?? '0') ?? 0;
            }

            final raceTable = mrData?['RaceTable'] as Map<String, dynamic>?;
            final races = raceTable?['Races'] as List?;

            if (races != null) {
              final results = <Map<String, dynamic>>[];
              for (final race in races) {
                final raceMap = race as Map<String, dynamic>;
                final raceResults = raceMap['Results'] as List?;

                if (raceResults != null && raceResults.isNotEmpty) {
                  // Get the driver's result (should be only one per race)
                  final result = raceResults.first as Map<String, dynamic>;
                  // Merge race info into result
                  results.add({
                    ...result,
                    'season': raceMap['season'],
                    'round': raceMap['round'],
                    'raceName': raceMap['raceName'],
                    'date': raceMap['date'],
                    'Circuit': raceMap['Circuit'],
                  });
                }
              }
              return results;
            }
          }

          return <Map<String, dynamic>>[];
        } on DioException catch (e) {
          throw _handleError(e);
        } catch (e) {
          throw ParseException('Failed to parse Jolpica driver results response: $e');
        }
      });

      allResults.addAll(pageResults);
      offset += limit;

    } while (total != null && offset < total!);

    return allResults;
  }

  /// Fetch all sprint results for a driver with automatic pagination
  ///
  /// Returns the driver's complete sprint history.
  /// [driverId] is the driver's ID (e.g., "max_verstappen")
  Future<List<Map<String, dynamic>>> getDriverSprintResults({
    required String driverId,
  }) async {
    final allResults = <Map<String, dynamic>>[];
    int offset = 0;
    const int limit = 100;
    int? total;

    do {
      await _rateLimiter.waitIfNeeded();

      final pageResults = await _retryRequest(() async {
        try {
          final response = await _dio.get(
            '/drivers/$driverId/sprint.json',
            queryParameters: {
              'limit': limit,
              'offset': offset,
            },
          );

          if (response.data is Map<String, dynamic>) {
            final mrData = response.data['MRData'] as Map<String, dynamic>?;

            if (total == null && mrData != null) {
              total = int.tryParse(mrData['total']?.toString() ?? '0') ?? 0;
            }

            final raceTable = mrData?['RaceTable'] as Map<String, dynamic>?;
            final races = raceTable?['Races'] as List?;

            if (races != null) {
              final results = <Map<String, dynamic>>[];
              for (final race in races) {
                final raceMap = race as Map<String, dynamic>;
                final sprintResults = raceMap['SprintResults'] as List?;

                if (sprintResults != null && sprintResults.isNotEmpty) {
                  final result = sprintResults.first as Map<String, dynamic>;
                  results.add({
                    ...result,
                    'season': raceMap['season'],
                    'round': raceMap['round'],
                    'raceName': raceMap['raceName'],
                    'date': raceMap['date'],
                    'Circuit': raceMap['Circuit'],
                  });
                }
              }
              return results;
            }
          }

          return <Map<String, dynamic>>[];
        } on DioException catch (e) {
          throw _handleError(e);
        } catch (e) {
          throw ParseException('Failed to parse Jolpica driver sprint results response: $e');
        }
      });

      allResults.addAll(pageResults);
      offset += limit;

    } while (total != null && offset < total!);

    return allResults;
  }

  /// Fetch driver standings for a season
  ///
  /// [season] can be a year (e.g., 2026) or 'current'
  /// Returns drivers sorted by championship position
  Future<List<T>> getDriverStandings<T>({
    required T Function(Map<String, dynamic>) fromJson,
    dynamic season = 'current',
  }) async {
    await _rateLimiter.waitIfNeeded();

    return await _retryRequest(() async {
      try {
        final response = await _dio.get('/$season/driverStandings.json');

        if (response.data is Map<String, dynamic>) {
          final mrData = response.data['MRData'] as Map<String, dynamic>?;
          final standingsTable = mrData?['StandingsTable'] as Map<String, dynamic>?;
          final standingsLists = standingsTable?['StandingsLists'] as List?;

          if (standingsLists != null && standingsLists.isNotEmpty) {
            final standingsList = standingsLists.first as Map<String, dynamic>;
            final driverStandings = standingsList['DriverStandings'] as List?;

            if (driverStandings != null) {
              return driverStandings
                  .map((json) => fromJson(json as Map<String, dynamic>))
                  .toList();
            }
          }
        }

        return [];
      } on DioException catch (e) {
        throw _handleError(e);
      } catch (e) {
        throw ParseException('Failed to parse Jolpica driver standings response: $e');
      }
    });
  }

  /// Fetch constructor standings for a season
  ///
  /// [season] can be a year (e.g., 2026) or 'current'
  /// Returns constructors sorted by championship position
  Future<List<T>> getConstructorStandings<T>({
    required T Function(Map<String, dynamic>) fromJson,
    dynamic season = 'current',
  }) async {
    await _rateLimiter.waitIfNeeded();

    return await _retryRequest(() async {
      try {
        final response = await _dio.get('/$season/constructorStandings.json');

        if (response.data is Map<String, dynamic>) {
          final mrData = response.data['MRData'] as Map<String, dynamic>?;
          final standingsTable = mrData?['StandingsTable'] as Map<String, dynamic>?;
          final standingsLists = standingsTable?['StandingsLists'] as List?;

          if (standingsLists != null && standingsLists.isNotEmpty) {
            final standingsList = standingsLists.first as Map<String, dynamic>;
            final constructorStandings = standingsList['ConstructorStandings'] as List?;

            if (constructorStandings != null) {
              return constructorStandings
                  .map((json) => fromJson(json as Map<String, dynamic>))
                  .toList();
            }
          }
        }

        return [];
      } on DioException catch (e) {
        throw _handleError(e);
      } catch (e) {
        throw ParseException('Failed to parse Jolpica constructor standings response: $e');
      }
    });
  }

  Future<T> _retryRequest<T>(Future<T> Function() request) async {
    int attempts = 0;
    Duration delay = initialRetryDelay;

    while (true) {
      try {
        return await request();
      } on ApiException catch (e) {
        attempts++;

        final shouldRetry = _shouldRetryError(e) && attempts < maxRetries;

        if (!shouldRetry) {
          rethrow;
        }

        await Future.delayed(delay);
        delay *= 2;
      }
    }
  }

  bool _shouldRetryError(ApiException error) {
    return switch (error) {
      NetworkException() => true,
      TimeoutException() => true,
      ServerException(:final statusCode) => statusCode >= 500 || statusCode == 429,
      ParseException() => false,
    };
  }

  ApiException _handleError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutException(),
      DioExceptionType.connectionError =>
        NetworkException(error.message ?? 'Connection failed'),
      DioExceptionType.badResponse => ServerException(
          error.response?.statusCode ?? 500,
          error.response?.statusMessage ?? 'Server error',
        ),
      DioExceptionType.cancel => const NetworkException('Request cancelled'),
      DioExceptionType.unknown ||
      DioExceptionType.badCertificate =>
        NetworkException(error.message ?? 'Unknown error occurred'),
    };
  }
}
