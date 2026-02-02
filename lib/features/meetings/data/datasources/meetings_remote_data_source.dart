import 'package:f1sync/core/network/jolpica_api_client.dart';
import 'package:f1sync/features/meetings/data/models/meeting.dart';
import 'package:logger/logger.dart';

/// Remote data source for meetings (Grand Prix weekends) using Jolpica API
class MeetingsRemoteDataSource {
  final JolpicaApiClient _jolpicaClient;
  final Logger _logger = Logger();

  MeetingsRemoteDataSource(this._jolpicaClient);

  /// Get meetings (races) from Jolpica API for a season
  ///
  /// [year] - Season year (defaults to current year)
  /// [round] - Specific round number (optional)
  Future<List<Meeting>> getMeetings({
    int? year,
    int? round,
    String? countryName,
  }) async {
    final season = year ?? DateTime.now().year;
    _logger.i('Fetching meetings from Jolpica for season: $season');

    final meetings = await _jolpicaClient.getRaces<Meeting>(
      fromJson: Meeting.fromJolpica,
      season: season,
    );

    // Filter by round if specified
    List<Meeting> filtered = meetings;
    if (round != null) {
      filtered = meetings.where((m) => m.meetingKey == round).toList();
    }

    // Filter by country if specified
    if (countryName != null) {
      filtered = filtered
          .where((m) =>
              m.countryName.toLowerCase().contains(countryName.toLowerCase()))
          .toList();
    }

    _logger.i('Fetched ${filtered.length} meetings from Jolpica');

    return filtered;
  }

  /// Get a single meeting by round number
  /// [year] - Season year (defaults to current year)
  Future<Meeting?> getMeetingByKey(int round, {int? year}) async {
    final seasonYear = year ?? DateTime.now().year;
    _logger.i('Fetching meeting round $round for $seasonYear from Jolpica');

    final meeting = await _jolpicaClient.getRace<Meeting>(
      fromJson: Meeting.fromJolpica,
      round: round,
      season: seasonYear,
    );

    if (meeting != null) {
      _logger.i('Meeting found: ${meeting.meetingName}');
    } else {
      _logger.w('Meeting round $round not found for $seasonYear');
    }

    return meeting;
  }

  /// Get the latest/upcoming meeting
  ///
  /// Returns the next scheduled race, or the most recent one if the season has ended.
  Future<Meeting?> getLatestMeeting() async {
    _logger.i('Fetching latest meeting from Jolpica');

    final currentYear = DateTime.now().year;
    final now = DateTime.now();

    // Fetch all races for current season
    final meetings = await getMeetings(year: currentYear);

    if (meetings.isEmpty) {
      _logger.w('No meetings found for $currentYear');
      return null;
    }

    // Find the next upcoming race
    Meeting? nextRace;
    Meeting? lastRace;

    for (final meeting in meetings) {
      if (meeting.dateStart.isAfter(now)) {
        if (nextRace == null || meeting.dateStart.isBefore(nextRace.dateStart)) {
          nextRace = meeting;
        }
      } else {
        if (lastRace == null || meeting.dateStart.isAfter(lastRace.dateStart)) {
          lastRace = meeting;
        }
      }
    }

    // Return next race if available, otherwise the last race
    final result = nextRace ?? lastRace;
    if (result != null) {
      _logger.i('Latest meeting: ${result.meetingName} (Round ${result.round})');
    }

    return result;
  }

  /// Get meetings for a specific year
  Future<List<Meeting>> getMeetingsForYear(int year) async {
    return getMeetings(year: year);
  }
}
