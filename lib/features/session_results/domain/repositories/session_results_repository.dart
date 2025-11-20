import '../../data/models/session_result.dart';

/// Repository interface for session results data
abstract class SessionResultsRepository {
  /// Fetch session results for a given session
  Future<List<SessionResult>> getSessionResults({
    required int sessionKey,
    int? driverNumber,
    int? position,
  });
}
