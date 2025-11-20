import 'package:f1sync/features/sessions/data/models/session.dart';

/// Repository interface for sessions (FP, Qualifying, Race, etc.)
abstract class SessionsRepository {
  /// Get list of sessions with optional filters
  ///
  /// [meetingKey] - Filter by meeting key or 'latest'
  /// [sessionKey] - Specific session key or 'latest'
  /// [sessionType] - Filter by session type (Practice, Qualifying, Race)
  Future<List<Session>> getSessions({
    dynamic meetingKey, // Can be int or 'latest'
    dynamic sessionKey, // Can be int or 'latest'
    String? sessionType,
  });

  /// Get a single session by key
  Future<Session?> getSessionByKey(int sessionKey);

  /// Get the latest/current session
  Future<Session?> getLatestSession();
}
