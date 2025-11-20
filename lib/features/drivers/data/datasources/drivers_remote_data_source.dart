import 'package:f1sync/core/constants/api_constants.dart';
import 'package:f1sync/core/network/api_client.dart';
import 'package:f1sync/features/drivers/data/models/driver.dart';

/// Remote data source for drivers
class DriversRemoteDataSource {
  final OpenF1ApiClient _apiClient;

  DriversRemoteDataSource(this._apiClient);

  /// Get drivers from API with optional filters
  Future<List<Driver>> getDrivers({
    dynamic sessionKey, // Can be int or 'latest'
    int? driverNumber,
  }) async {
    final queryParams = <String, dynamic>{};

    if (sessionKey != null) queryParams['session_key'] = sessionKey;
    if (driverNumber != null) queryParams['driver_number'] = driverNumber;

    return await _apiClient.getList<Driver>(
      endpoint: ApiConstants.drivers,
      fromJson: Driver.fromJson,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Get a single driver by number
  Future<Driver?> getDriverByNumber({
    required int driverNumber,
    dynamic sessionKey, // Can be int or 'latest'
  }) async {
    return await _apiClient.getSingle<Driver>(
      endpoint: ApiConstants.drivers,
      fromJson: Driver.fromJson,
      queryParams: {
        'driver_number': driverNumber,
        'session_key': sessionKey ?? ApiConstants.latest,
      },
    );
  }
}
