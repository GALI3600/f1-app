import 'package:f1sync/core/network/jolpica_api_client.dart';
import 'package:f1sync/features/meetings/data/models/meeting.dart';
import 'package:f1sync/features/sessions/data/models/session.dart';
import 'package:logger/logger.dart';

/// Remote data source for sessions (FP, Qualifying, Race, etc.) using Jolpica API
///
/// In Jolpica, sessions are embedded within Race objects. This data source
/// extracts sessions from the race schedule data.
class SessionsRemoteDataSource {
  final JolpicaApiClient _jolpicaClient;
  final Logger _logger = Logger();

  SessionsRemoteDataSource(this._jolpicaClient);

  /// Get sessions from Jolpica API
  ///
  /// Sessions are extracted from race schedule data.
  /// [meetingKey] - Round number (optional)
  /// [sessionKey] - Session key (round * 100 + sessionIndex)
  /// [sessionType] - Filter by session type (optional)
  /// [year] - Season year (defaults to current year)
  Future<List<Session>> getSessions({
    dynamic meetingKey,
    dynamic sessionKey,
    String? sessionType,
    int? year,
  }) async {
    final seasonYear = year ?? DateTime.now().year;
    _logger.i('Fetching sessions from Jolpica for season: $seasonYear');

    // Fetch all races to get session schedules
    final meetings = await _jolpicaClient.getRaces<Meeting>(
      fromJson: Meeting.fromJolpica,
      season: seasonYear,
    );

    // Extract all sessions from meetings
    List<Session> allSessions = [];
    for (final meeting in meetings) {
      allSessions.addAll(meeting.sessions);
    }

    // Filter by meeting key (round)
    if (meetingKey != null) {
      final round = meetingKey is int ? meetingKey : int.tryParse(meetingKey.toString());
      if (round != null) {
        allSessions = allSessions.where((s) => s.meetingKey == round).toList();
      }
    }

    // Filter by session key
    if (sessionKey != null) {
      final key = sessionKey is int ? sessionKey : int.tryParse(sessionKey.toString());
      if (key != null) {
        allSessions = allSessions.where((s) => s.sessionKey == key).toList();
      }
    }

    // Filter by session type
    if (sessionType != null) {
      allSessions = allSessions
          .where((s) => s.sessionType.toLowerCase() == sessionType.toLowerCase())
          .toList();
    }

    _logger.i('Found ${allSessions.length} sessions');

    return allSessions;
  }

  /// Get a single session by key
  ///
  /// Session key format: round * 100 + sessionIndex
  /// [year] - Season year (defaults to current year)
  Future<Session?> getSessionByKey(int sessionKey, {int? year}) async {
    _logger.i('Fetching session $sessionKey from Jolpica');

    // Extract round from session key
    final round = sessionKey ~/ 100;
    final seasonYear = year ?? DateTime.now().year;

    // Fetch the specific race
    final meeting = await _jolpicaClient.getRace<Meeting>(
      fromJson: Meeting.fromJolpica,
      round: round,
      season: seasonYear,
    );

    if (meeting == null) {
      _logger.w('Meeting for session $sessionKey not found');
      return null;
    }

    // Find the session in the meeting
    final session = meeting.sessions.cast<Session?>().firstWhere(
      (s) => s!.sessionKey == sessionKey,
      orElse: () => null,
    );

    if (session != null) {
      _logger.i('Session found: ${session.sessionName}');
    } else {
      _logger.w('Session $sessionKey not found in meeting');
    }

    return session;
  }

  /// Get the latest/current session
  ///
  /// Returns the next scheduled session, or the most recent completed session.
  /// [year] - Season year (defaults to current year)
  Future<Session?> getLatestSession({int? year}) async {
    _logger.i('Fetching latest session from Jolpica');

    final seasonYear = year ?? DateTime.now().year;
    final now = DateTime.now();

    // Fetch all races
    final meetings = await _jolpicaClient.getRaces<Meeting>(
      fromJson: Meeting.fromJolpica,
      season: seasonYear,
    );

    if (meetings.isEmpty) {
      _logger.w('No meetings found for $seasonYear');
      return null;
    }

    // Collect all sessions
    final allSessions = meetings.expand((m) => m.sessions).toList();

    // Sort by date
    allSessions.sort((a, b) => a.dateStart.compareTo(b.dateStart));

    // Find the next upcoming session
    Session? nextSession;
    Session? lastSession;

    for (final session in allSessions) {
      if (session.dateStart.isAfter(now)) {
        nextSession = session;
        break;
      }
      lastSession = session;
    }

    // Return next session if available, otherwise the last session
    final result = nextSession ?? lastSession;
    if (result != null) {
      _logger.i('Latest session: ${result.sessionName} (Round ${result.round})');
    }

    return result;
  }

  /// Get sessions for a specific meeting/round
  /// [year] - Season year (defaults to current year)
  Future<List<Session>> getSessionsForMeeting(int round, {int? year}) async {
    return getSessions(meetingKey: round, year: year);
  }
}
