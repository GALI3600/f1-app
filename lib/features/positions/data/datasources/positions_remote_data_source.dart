import 'package:f1sync/core/constants/api_constants.dart';
import 'package:f1sync/core/network/api_client.dart';
import 'package:f1sync/features/positions/data/models/position.dart';

/// Remote data source for positions
class PositionsRemoteDataSource {
  final OpenF1ApiClient _apiClient;

  PositionsRemoteDataSource(this._apiClient);

  /// Get positions from API with optional filters
  Future<List<Position>> getPositions({
    dynamic sessionKey, // Can be int or 'latest'
    int? driverNumber,
    int? position,
  }) async {
    final queryParams = <String, dynamic>{};

    if (sessionKey != null) queryParams['session_key'] = sessionKey;
    if (driverNumber != null) queryParams['driver_number'] = driverNumber;
    if (position != null) queryParams['position'] = position;

    return await _apiClient.getList<Position>(
      endpoint: ApiConstants.position,
      fromJson: Position.fromJson,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Get current positions for a session
  Future<List<Position>> getCurrentPositions({
    dynamic sessionKey, // Can be int or 'latest'
  }) async {
    return await getPositions(
      sessionKey: sessionKey ?? ApiConstants.latest,
    );
  }
}
