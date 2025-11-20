import 'package:f1sync/core/constants/api_constants.dart';
import 'package:f1sync/core/network/api_client.dart';
import 'package:f1sync/features/laps/data/models/lap.dart';

/// Remote data source for laps
class LapsRemoteDataSource {
  final OpenF1ApiClient _apiClient;

  LapsRemoteDataSource(this._apiClient);

  /// Get laps from API with optional filters
  Future<List<Lap>> getLaps({
    dynamic sessionKey, // Can be int or 'latest'
    int? driverNumber,
    int? lapNumber,
  }) async {
    final queryParams = <String, dynamic>{};

    if (sessionKey != null) queryParams['session_key'] = sessionKey;
    if (driverNumber != null) queryParams['driver_number'] = driverNumber;
    if (lapNumber != null) queryParams['lap_number'] = lapNumber;

    return await _apiClient.getList<Lap>(
      endpoint: ApiConstants.laps,
      fromJson: Lap.fromJson,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Get laps for a specific driver in a session
  Future<List<Lap>> getDriverLaps({
    required int driverNumber,
    dynamic sessionKey, // Can be int or 'latest'
  }) async {
    return await getLaps(
      sessionKey: sessionKey ?? ApiConstants.latest,
      driverNumber: driverNumber,
    );
  }
}
