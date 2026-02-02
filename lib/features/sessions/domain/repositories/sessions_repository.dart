import 'package:f1sync/features/sessions/data/models/session.dart';

/// Repository interface for sessions (FP, Qualifying, Race, etc.)
///
/// Sessions are extracted from Jolpica race schedule data.
/// Session keys are computed as: round * 100 + sessionIndex
abstract class SessionsRepository {
  /// Get list of sessions with optional filters
  ///
  /// [round] - Filter by round number
  /// [sessionKey] - Specific session key (round * 100 + sessionIndex)
  /// [sessionType] - Filter by session type (Practice, Qualifying, Race, Sprint)
  /// [year] - Season year (defaults to current year)
  Future<List<Session>> getSessions({
    int? round,
    dynamic sessionKey,
    String? sessionType,
    int? year,
  });

  /// Get a single session by key
  /// [year] - Season year (defaults to current year)
  Future<Session?> getSessionByKey(int sessionKey, {int? year});

  /// Get the latest/upcoming session
  /// [year] - Season year (defaults to current year)
  Future<Session?> getLatestSession({int? year});
}
