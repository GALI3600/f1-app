import 'package:f1sync/core/network/jolpica_api_client.dart';
import 'package:f1sync/features/standings/data/models/driver_standing.dart';
import 'package:f1sync/features/standings/data/models/constructor_standing.dart';
import 'package:logger/logger.dart';

/// Remote data source for championship standings using Jolpica API
class StandingsRemoteDataSource {
  final JolpicaApiClient _jolpicaClient;
  final Logger _logger = Logger();

  StandingsRemoteDataSource(this._jolpicaClient);

  /// Get driver standings for a season
  ///
  /// [season] can be a year (e.g., 2026) or 'current'
  Future<List<DriverStanding>> getDriverStandings({
    dynamic season = 'current',
  }) async {
    _logger.i('Fetching driver standings from Jolpica for season: $season');

    final standings = await _jolpicaClient.getDriverStandings<DriverStanding>(
      fromJson: DriverStanding.fromJolpica,
      season: season,
    );

    _logger.i('Fetched ${standings.length} driver standings');
    return standings;
  }

  /// Get constructor standings for a season
  ///
  /// [season] can be a year (e.g., 2026) or 'current'
  Future<List<ConstructorStanding>> getConstructorStandings({
    dynamic season = 'current',
  }) async {
    _logger.i('Fetching constructor standings from Jolpica for season: $season');

    final standings = await _jolpicaClient.getConstructorStandings<ConstructorStanding>(
      fromJson: ConstructorStanding.fromJolpica,
      season: season,
    );

    _logger.i('Fetched ${standings.length} constructor standings');
    return standings;
  }
}
