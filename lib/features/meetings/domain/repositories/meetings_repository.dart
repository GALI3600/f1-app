import 'package:f1sync/features/meetings/data/models/meeting.dart';

/// Repository interface for meetings (Grand Prix weekends)
///
/// Uses Jolpica API for race schedule data. In Jolpica, meetings are
/// identified by round number within a season.
abstract class MeetingsRepository {
  /// Get list of meetings (races) with optional filters
  ///
  /// [year] - Season year (defaults to current year)
  /// [round] - Specific round number (optional)
  /// [countryName] - Filter by country name
  Future<List<Meeting>> getMeetings({
    int? year,
    int? round,
    String? countryName,
  });

  /// Get a single meeting by round number
  /// [year] - Season year (defaults to current year)
  Future<Meeting?> getMeetingByKey(int round, {int? year});

  /// Get the latest/upcoming meeting
  Future<Meeting?> getLatestMeeting();
}
