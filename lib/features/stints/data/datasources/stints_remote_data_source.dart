import 'package:f1sync/core/constants/api_constants.dart';
import 'package:f1sync/core/network/api_client.dart';
import 'package:f1sync/features/stints/data/models/stint.dart';

/// Remote data source for tire stints
class StintsRemoteDataSource {
  final OpenF1ApiClient _apiClient;

  StintsRemoteDataSource(this._apiClient);

  /// Get stints from API with optional filters
  Future<List<Stint>> getStints({
    dynamic sessionKey, // Can be int or 'latest'
    int? driverNumber,
  }) async {
    final queryParams = <String, dynamic>{};

    if (sessionKey != null) queryParams['session_key'] = sessionKey;
    if (driverNumber != null) queryParams['driver_number'] = driverNumber;

    return await _apiClient.getList<Stint>(
      endpoint: ApiConstants.stints,
      fromJson: Stint.fromJson,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Get stints for a specific driver in a session
  Future<List<Stint>> getDriverStints({
    required int driverNumber,
    dynamic sessionKey, // Can be int or 'latest'
  }) async {
    return await getStints(
      sessionKey: sessionKey ?? ApiConstants.latest,
      driverNumber: driverNumber,
    );
  }
}
