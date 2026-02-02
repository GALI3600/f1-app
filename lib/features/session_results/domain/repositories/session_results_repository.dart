import '../../data/models/session_result.dart';

/// Repository interface for session results data
abstract class SessionResultsRepository {
  /// Fetch session results for a given session
  /// [sessionType] - Type of session (Practice, Qualifying, Sprint, Race)
  /// [year] - Season year (defaults to current year)
  Future<List<SessionResult>> getSessionResults({
    required int sessionKey,
    String? sessionType,
    int? driverNumber,
    int? position,
    int? year,
  });
}
