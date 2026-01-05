import 'package:f1sync/core/constants/api_constants.dart';
import 'package:f1sync/core/network/api_client.dart';
import 'package:f1sync/features/drivers/data/models/driver.dart';
import 'package:logger/logger.dart';

/// Remote data source for drivers
class DriversRemoteDataSource {
  final OpenF1ApiClient _apiClient;
  final Logger _logger = Logger();

  DriversRemoteDataSource(this._apiClient);

  /// Get drivers from API with optional filters
  Future<List<Driver>> getDrivers({
    dynamic sessionKey, // Can be int or 'latest'
    int? driverNumber,
  }) async {
    final queryParams = <String, dynamic>{};

    if (sessionKey != null) queryParams['session_key'] = sessionKey;
    if (driverNumber != null) queryParams['driver_number'] = driverNumber;

    _logger.i('Fetching drivers with params: $queryParams');

    final drivers = await _apiClient.getList<Driver>(
      endpoint: ApiConstants.drivers,
      fromJson: Driver.fromJson,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    _logger.i('Fetched ${drivers.length} drivers');
    for (final driver in drivers) {
      _logger.d('Driver: #${driver.driverNumber} ${driver.fullName} (${driver.teamName})');
    }

    return drivers;
  }

  /// Get a single driver by number
  Future<Driver?> getDriverByNumber({
    required int driverNumber,
    dynamic sessionKey, // Can be int or 'latest'
  }) async {
    _logger.i('Fetching driver #$driverNumber with sessionKey: ${sessionKey ?? ApiConstants.latest}');

    final driver = await _apiClient.getSingle<Driver>(
      endpoint: ApiConstants.drivers,
      fromJson: Driver.fromJson,
      queryParams: {
        'driver_number': driverNumber,
        'session_key': sessionKey ?? ApiConstants.latest,
      },
    );

    if (driver != null) {
      _logger.i('Driver found: #${driver.driverNumber} ${driver.fullName}');
      _logger.d('Driver details: team=${driver.teamName}, teamColour=${driver.teamColour}, '
          'sessionKey=${driver.sessionKey}, meetingKey=${driver.meetingKey}');
    } else {
      _logger.w('Driver #$driverNumber not found');
    }

    return driver;
  }
}
