import 'package:f1sync/core/constants/jolpica_constants.dart';
import 'package:f1sync/core/network/jolpica_api_client.dart';
import 'package:f1sync/features/laps/data/models/lap.dart';
import 'package:logger/logger.dart';

/// Remote data source for laps using Jolpica API
class LapsRemoteDataSource {
  final JolpicaApiClient _jolpicaClient;
  final Logger _logger = Logger();

  LapsRemoteDataSource(this._jolpicaClient);

  /// Get laps from Jolpica API
  ///
  /// [round] - Race round number
  /// [driverId] - Jolpica driver ID (e.g., "max_verstappen")
  /// [driverNumber] - Driver number (will be converted to driverId)
  /// [lapNumber] - Specific lap number (optional)
  /// [year] - Season year (defaults to current year)
  Future<List<Lap>> getLaps({
    required int round,
    String? driverId,
    int? driverNumber,
    int? lapNumber,
    int? year,
  }) async {
    final season = year ?? DateTime.now().year;
    _logger.i('Fetching laps from Jolpica for round $round, season $season');

    // Convert driver number to driver ID if needed
    String? finalDriverId = driverId;
    if (finalDriverId == null && driverNumber != null) {
      finalDriverId = JolpicaConstants.getDriverId(driverNumber);
    }

    final laps = await _jolpicaClient.getLaps<Lap>(
      fromJson: Lap.fromJolpica,
      round: round,
      season: season,
      driverId: finalDriverId,
      lapNumber: lapNumber,
    );

    // Filter by driver number if specified and we couldn't convert to ID
    List<Lap> filtered = laps;
    if (driverNumber != null && finalDriverId == null) {
      filtered = laps.where((l) => l.driverNumber == driverNumber).toList();
    }

    _logger.i('Fetched ${filtered.length} laps from Jolpica');

    return filtered;
  }

  /// Get laps by session key
  ///
  /// Session key format: round * 100 + sessionIndex
  /// Only race sessions (sessionIndex = highest) have lap data in Jolpica
  Future<List<Lap>> getLapsBySessionKey({
    required int sessionKey,
    int? driverNumber,
    int? lapNumber,
  }) async {
    // Extract round from session key
    final round = sessionKey ~/ 100;

    return getLaps(
      round: round,
      driverNumber: driverNumber,
      lapNumber: lapNumber,
    );
  }

  /// Get laps for a specific driver in a race
  Future<List<Lap>> getDriverLaps({
    required int driverNumber,
    required int round,
    int? year,
  }) async {
    final driverId = JolpicaConstants.getDriverId(driverNumber);

    return getLaps(
      round: round,
      driverId: driverId,
      driverNumber: driverNumber,
      year: year,
    );
  }

  /// Get a specific lap for a driver
  Future<Lap?> getDriverLap({
    required int driverNumber,
    required int round,
    required int lapNumber,
    int? year,
  }) async {
    final laps = await getLaps(
      round: round,
      driverNumber: driverNumber,
      lapNumber: lapNumber,
      year: year,
    );

    return laps.isNotEmpty ? laps.first : null;
  }
}
