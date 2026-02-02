import 'package:f1sync/core/network/jolpica_api_client.dart';
import 'package:logger/logger.dart';
import '../models/session_result.dart';

/// Remote data source for session results using Jolpica API
class SessionResultsRemoteDataSource {
  final JolpicaApiClient _jolpicaClient;
  final Logger _logger = Logger();

  SessionResultsRemoteDataSource(this._jolpicaClient);

  /// Fetch session results from Jolpica API
  ///
  /// [sessionKey] - Session key (round * 100 + sessionIndex)
  /// [sessionType] - Type of session (Practice, Qualifying, Sprint, Race, etc.)
  /// [year] - Season year (defaults to current year)
  ///
  /// Results availability by session type:
  /// - Practice: No results available in Jolpica
  /// - Qualifying/Sprint Qualifying: Grid positions and times
  /// - Sprint: Race-style results
  /// - Race: Full results with positions and times
  Future<List<SessionResult>> getSessionResults({
    required int sessionKey,
    String? sessionType,
    int? driverNumber,
    int? position,
    int? year,
  }) async {
    final round = sessionKey ~/ 100;
    final seasonYear = year ?? DateTime.now().year;

    _logger.i('Fetching results for $sessionType (round $round, year $seasonYear)');

    List<SessionResult> results;

    // Fetch results based on session type
    switch (sessionType?.toLowerCase()) {
      case 'practice':
        // Practice sessions don't have results in Jolpica
        _logger.i('Practice sessions have no results data');
        return [];

      case 'qualifying':
      case 'sprint qualifying':
        results = await getQualifyingResults(round: round, year: seasonYear);
        break;

      case 'sprint':
        results = await getSprintResults(round: round, year: seasonYear);
        break;

      case 'race':
      default:
        results = await _getRaceResults(round, seasonYear);
        break;
    }

    // Filter by driver number if specified
    if (driverNumber != null) {
      results = results.where((r) => r.driverNumber == driverNumber).toList();
    }

    // Filter by position if specified
    if (position != null) {
      results = results.where((r) => r.position <= position).toList();
    }

    _logger.i('Found ${results.length} results');

    return results;
  }

  /// Get race results for a specific round
  Future<List<SessionResult>> _getRaceResults(int round, int year) async {
    return _jolpicaClient.getResults<SessionResult>(
      fromJson: (json) => SessionResult.fromJolpica(json, round),
      round: round,
      season: year,
    );
  }

  /// Get qualifying results for a specific round
  Future<List<SessionResult>> getQualifyingResults({
    required int round,
    int? year,
  }) async {
    final season = year ?? DateTime.now().year;
    _logger.i('Fetching qualifying results for round $round, season $season');

    final results = await _jolpicaClient.getQualifying<SessionResult>(
      fromJson: (json) => _parseQualifyingResult(json, round),
      round: round,
      season: season,
    );

    // Calculate gaps from P1's time
    if (results.isNotEmpty) {
      // Sort by position to find P1
      results.sort((a, b) => a.position.compareTo(b.position));
      final p1Time = results.first.duration;

      if (p1Time > 0) {
        // Update gaps for all drivers
        return results.map((r) {
          if (r.position == 1 || r.duration == 0) {
            return r;
          }
          final gap = r.duration - p1Time;
          return r.copyWith(gapToLeader: gap);
        }).toList();
      }
    }

    return results;
  }

  /// Get sprint results for a specific round
  Future<List<SessionResult>> getSprintResults({
    required int round,
    int? year,
  }) async {
    final season = year ?? DateTime.now().year;
    _logger.i('Fetching sprint results for round $round, season $season');

    return _jolpicaClient.getSprint<SessionResult>(
      fromJson: (json) => SessionResult.fromJolpica(json, round),
      round: round,
      season: season,
    );
  }

  /// Parse qualifying result from Jolpica format
  SessionResult _parseQualifyingResult(Map<String, dynamic> json, int round) {
    final driver = json['Driver'] as Map<String, dynamic>? ?? {};
    final constructor = json['Constructor'] as Map<String, dynamic>? ?? {};

    final driverId = driver['driverId'] as String? ?? '';
    final position = int.tryParse(json['position']?.toString() ?? '') ?? 0;

    // Get driver number from API response (permanentNumber)
    final driverNumber = int.tryParse(driver['permanentNumber']?.toString() ?? '') ?? 0;

    // Parse qualifying times
    final q1 = json['Q1'] as String?;
    final q2 = json['Q2'] as String?;
    final q3 = json['Q3'] as String?;

    // Use the best qualifying time as duration
    String? bestTime = q3 ?? q2 ?? q1;
    double duration = 0;
    if (bestTime != null) {
      duration = _parseQualifyingTime(bestTime);
    }

    return SessionResult(
      driverNumber: driverNumber,
      position: position,
      duration: duration,
      sessionKey: round * 100 + 6, // Qualifying session index
      meetingKey: round,
      driverId: driverId,
      teamName: constructor['name'] as String?,
    );
  }

  /// Parse qualifying time string to seconds
  double _parseQualifyingTime(String timeStr) {
    if (timeStr.isEmpty) return 0;

    try {
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        final minutes = int.parse(parts[0]);
        final seconds = double.parse(parts[1]);
        return minutes * 60 + seconds;
      } else {
        return double.parse(timeStr);
      }
    } catch (e) {
      return 0;
    }
  }

}
