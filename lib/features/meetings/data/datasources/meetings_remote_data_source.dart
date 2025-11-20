import 'package:f1sync/core/constants/api_constants.dart';
import 'package:f1sync/core/network/api_client.dart';
import 'package:f1sync/features/meetings/data/models/meeting.dart';

/// Remote data source for meetings (Grand Prix weekends)
class MeetingsRemoteDataSource {
  final OpenF1ApiClient _apiClient;

  MeetingsRemoteDataSource(this._apiClient);

  /// Get meetings from API with optional filters
  Future<List<Meeting>> getMeetings({
    int? year,
    dynamic meetingKey, // Can be int or 'latest'
    String? countryName,
  }) async {
    final queryParams = <String, dynamic>{};

    if (year != null) queryParams['year'] = year;
    if (meetingKey != null) queryParams['meeting_key'] = meetingKey;
    if (countryName != null) queryParams['country_name'] = countryName;

    return await _apiClient.getList<Meeting>(
      endpoint: ApiConstants.meetings,
      fromJson: Meeting.fromJson,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Get a single meeting by key
  Future<Meeting?> getMeetingByKey(int meetingKey) async {
    return await _apiClient.getSingle<Meeting>(
      endpoint: ApiConstants.meetings,
      fromJson: Meeting.fromJson,
      queryParams: {'meeting_key': meetingKey},
    );
  }

  /// Get the latest/current meeting
  Future<Meeting?> getLatestMeeting() async {
    return await _apiClient.getSingle<Meeting>(
      endpoint: ApiConstants.meetings,
      fromJson: Meeting.fromJson,
      queryParams: {'meeting_key': ApiConstants.latest},
    );
  }
}
