import 'package:f1sync/features/meetings/data/models/meeting.dart';

/// Repository interface for meetings (Grand Prix weekends)
abstract class MeetingsRepository {
  /// Get list of meetings with optional filters
  ///
  /// [year] - Filter by year
  /// [meetingKey] - Specific meeting key or 'latest'
  /// [countryName] - Filter by country name
  Future<List<Meeting>> getMeetings({
    int? year,
    dynamic meetingKey, // Can be int or 'latest'
    String? countryName,
  });

  /// Get a single meeting by key
  Future<Meeting?> getMeetingByKey(int meetingKey);

  /// Get the latest/current meeting
  Future<Meeting?> getLatestMeeting();
}
