import 'package:f1sync/core/constants/api_constants.dart';
import 'package:f1sync/core/network/api_client.dart';
import 'package:f1sync/features/race_control/data/models/race_control.dart';

/// Remote data source for race control messages
class RaceControlRemoteDataSource {
  final OpenF1ApiClient _apiClient;

  RaceControlRemoteDataSource(this._apiClient);

  /// Get race control messages from API with optional filters
  Future<List<RaceControl>> getRaceControlMessages({
    dynamic sessionKey, // Can be int or 'latest'
    String? category,
    String? flag,
  }) async {
    final queryParams = <String, dynamic>{};

    if (sessionKey != null) queryParams['session_key'] = sessionKey;
    if (category != null) queryParams['category'] = category;
    if (flag != null) queryParams['flag'] = flag;

    return await _apiClient.getList<RaceControl>(
      endpoint: ApiConstants.raceControl,
      fromJson: RaceControl.fromJson,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }
}
