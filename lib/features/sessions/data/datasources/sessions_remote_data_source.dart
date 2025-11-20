import 'package:f1sync/core/constants/api_constants.dart';
import 'package:f1sync/core/network/api_client.dart';
import 'package:f1sync/features/sessions/data/models/session.dart';

/// Remote data source for sessions (FP, Qualifying, Race, etc.)
class SessionsRemoteDataSource {
  final OpenF1ApiClient _apiClient;

  SessionsRemoteDataSource(this._apiClient);

  /// Get sessions from API with optional filters
  Future<List<Session>> getSessions({
    dynamic meetingKey, // Can be int or 'latest'
    dynamic sessionKey, // Can be int or 'latest'
    String? sessionType,
  }) async {
    final queryParams = <String, dynamic>{};

    if (meetingKey != null) queryParams['meeting_key'] = meetingKey;
    if (sessionKey != null) queryParams['session_key'] = sessionKey;
    if (sessionType != null) queryParams['session_type'] = sessionType;

    return await _apiClient.getList<Session>(
      endpoint: ApiConstants.sessions,
      fromJson: Session.fromJson,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Get a single session by key
  Future<Session?> getSessionByKey(int sessionKey) async {
    return await _apiClient.getSingle<Session>(
      endpoint: ApiConstants.sessions,
      fromJson: Session.fromJson,
      queryParams: {'session_key': sessionKey},
    );
  }

  /// Get the latest/current session
  Future<Session?> getLatestSession() async {
    return await _apiClient.getSingle<Session>(
      endpoint: ApiConstants.sessions,
      fromJson: Session.fromJson,
      queryParams: {'session_key': ApiConstants.latest},
    );
  }
}
