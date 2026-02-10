import 'package:f1sync/features/standings/data/datasources/standings_remote_data_source.dart';
import 'package:f1sync/features/standings/data/models/driver_standing.dart';
import 'package:f1sync/features/standings/data/models/constructor_standing.dart';
import 'package:f1sync/shared/services/cache/cache_service.dart';

/// Repository for championship standings
class StandingsRepository {
  final StandingsRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  StandingsRepository(this._remoteDataSource, this._cacheService);

  /// Get driver standings for a season
  ///
  /// Results are cached for 1 hour (standings update after each race)
  Future<List<DriverStanding>> getDriverStandings({
    dynamic season = 'current',
  }) async {
    final cacheKey = 'driver_standings_$season';

    return await _cacheService.getCachedList<DriverStanding>(
      key: cacheKey,
      ttl: CacheTTL.medium,
      fetch: () => _remoteDataSource.getDriverStandings(season: season),
      fromJson: DriverStanding.fromJson,
    );
  }

  /// Get constructor standings for a season
  ///
  /// Results are cached for 1 hour
  Future<List<ConstructorStanding>> getConstructorStandings({
    dynamic season = 'current',
  }) async {
    final cacheKey = 'constructor_standings_$season';

    return await _cacheService.getCachedList<ConstructorStanding>(
      key: cacheKey,
      ttl: CacheTTL.medium,
      fetch: () => _remoteDataSource.getConstructorStandings(season: season),
      fromJson: ConstructorStanding.fromJson,
    );
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
