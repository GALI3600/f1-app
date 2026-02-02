import 'package:f1sync/core/network/jolpica_api_client.dart';
import 'package:f1sync/features/drivers/data/models/driver.dart';
import 'package:logger/logger.dart';

/// Remote data source for drivers using Jolpica API
class DriversRemoteDataSource {
  final JolpicaApiClient _jolpicaClient;
  final Logger _logger = Logger();

  DriversRemoteDataSource(this._jolpicaClient);

  /// Get drivers from Jolpica API for current season
  Future<List<Driver>> getDrivers({
    dynamic sessionKey, // Ignored - Jolpica uses season
    int? driverNumber,
    dynamic season = 'current',
  }) async {
    _logger.i('Fetching drivers from Jolpica for season: $season');

    // Use the simple getDrivers method (single API call)
    final drivers = await _jolpicaClient.getDrivers<Driver>(
      fromJson: Driver.fromJolpica,
      season: season,
    );

    // Filter by driver number if specified
    final filteredDrivers = driverNumber != null
        ? drivers.where((d) => d.driverNumber == driverNumber).toList()
        : drivers;

    _logger.i('Fetched ${filteredDrivers.length} drivers from Jolpica');
    for (final driver in filteredDrivers) {
      _logger.d('Driver: #${driver.driverNumber} ${driver.fullName} (${driver.teamName})');
    }

    return filteredDrivers;
  }

  /// Get a single driver by number
  Future<Driver?> getDriverByNumber({
    required int driverNumber,
    dynamic sessionKey, // Ignored - using Jolpica
    dynamic season = 'current',
  }) async {
    _logger.i('Fetching driver #$driverNumber from Jolpica');

    // Fetch all drivers with constructor info and filter
    final drivers = await getDrivers(
      driverNumber: driverNumber,
      season: season,
    );

    final driver = drivers.isNotEmpty ? drivers.first : null;

    if (driver != null) {
      _logger.i('Driver found: #${driver.driverNumber} ${driver.fullName} (${driver.teamName})');
    } else {
      _logger.w('Driver #$driverNumber not found');
    }

    return driver;
  }

  /// Get driver by Jolpica driver ID
  Future<Driver?> getDriverById(String driverId, {dynamic season = 'current'}) async {
    _logger.i('Fetching driver by ID: $driverId');

    // Use the single driver endpoint
    final driver = await _jolpicaClient.getDriver<Driver>(
      driverId: driverId,
      fromJson: Driver.fromJolpica,
    );

    if (driver != null) {
      _logger.i('Driver found: ${driver.fullName} (${driver.teamName})');
    } else {
      _logger.w('Driver $driverId not found');
    }

    return driver;
  }
}
