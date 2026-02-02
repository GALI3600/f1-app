import 'package:f1sync/features/standings/data/datasources/standings_remote_data_source.dart';
import 'package:f1sync/features/standings/data/models/driver_standing.dart';
import 'package:f1sync/features/standings/data/models/constructor_standing.dart';
import 'package:f1sync/shared/services/cache/cache_service.dart';
import 'package:logger/logger.dart';

/// Repository for championship standings
class StandingsRepository {
  final StandingsRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;
  final Logger _logger = Logger();

  StandingsRepository(this._remoteDataSource, this._cacheService);

  /// Get driver standings for a season
  ///
  /// Results are cached for 1 hour (standings update after each race)
  Future<List<DriverStanding>> getDriverStandings({
    dynamic season = 'current',
  }) async {
    final cacheKey = 'driver_standings_$season';

    // Try cache first
    final cached = await _cacheService.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      _logger.d('Driver standings cache hit for $season');
      return cached
          .map((e) => DriverStanding.fromJolpica(e as Map<String, dynamic>))
          .toList();
    }

    _logger.d('Driver standings cache miss for $season, fetching from API');
    final standings = await _remoteDataSource.getDriverStandings(season: season);

    // Cache for 1 hour
    await _cacheService.set(
      cacheKey,
      standings.map((s) => s.toJson()).toList(),
      CacheTTL.medium,
    );

    return standings;
  }

  /// Get constructor standings for a season
  ///
  /// Results are cached for 1 hour
  Future<List<ConstructorStanding>> getConstructorStandings({
    dynamic season = 'current',
  }) async {
    final cacheKey = 'constructor_standings_$season';

    // Try cache first
    final cached = await _cacheService.get<List<dynamic>>(cacheKey);
    if (cached != null) {
      _logger.d('Constructor standings cache hit for $season');
      return cached
          .map((e) => ConstructorStanding.fromJolpica(e as Map<String, dynamic>))
          .toList();
    }

    _logger.d('Constructor standings cache miss for $season, fetching from API');
    final standings = await _remoteDataSource.getConstructorStandings(season: season);

    // Cache for 1 hour
    await _cacheService.set(
      cacheKey,
      standings.map((s) => s.toJson()).toList(),
      CacheTTL.medium,
    );

    return standings;
  }

  /// Get the championship leader (P1 driver)
  Future<DriverStanding?> getChampionshipLeader({
    dynamic season = 'current',
  }) async {
    final standings = await getDriverStandings(season: season);
    return standings.isNotEmpty ? standings.first : null;
  }

  /// Get the leading constructor (P1 team)
  Future<ConstructorStanding?> getLeadingConstructor({
    dynamic season = 'current',
  }) async {
    final standings = await getConstructorStandings(season: season);
    return standings.isNotEmpty ? standings.first : null;
  }
}
