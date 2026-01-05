import 'package:f1sync/shared/services/cache/cache_service.dart';
import 'package:f1sync/features/sessions/data/datasources/sessions_remote_data_source.dart';
import 'package:f1sync/features/sessions/data/models/session.dart';
import 'package:f1sync/features/sessions/domain/repositories/sessions_repository.dart';

/// Implementation of SessionsRepository with caching
class SessionsRepositoryImpl implements SessionsRepository {
  final SessionsRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  SessionsRepositoryImpl(
    this._remoteDataSource,
    this._cacheService,
  );

  @override
  Future<List<Session>> getSessions({
    dynamic meetingKey,
    dynamic sessionKey,
    String? sessionType,
  }) async {
    final cacheKey = 'sessions_${meetingKey}_${sessionKey}_$sessionType';

    return await _cacheService.getCachedList<Session>(
      key: cacheKey,
      ttl: CacheTTL.medium, // 1 hour - session schedule is stable
      fetch: () => _remoteDataSource.getSessions(
        meetingKey: meetingKey,
        sessionKey: sessionKey,
        sessionType: sessionType,
      ),
      fromJson: Session.fromJson,
    );
  }

  @override
  Future<Session?> getSessionByKey(int sessionKey) async {
    final cacheKey = 'session_$sessionKey';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.medium,
      fetch: () => _remoteDataSource.getSessionByKey(sessionKey),
      fromJson: (json) => Session.fromJson(json),
    );
  }

  @override
  Future<Session?> getLatestSession() async {
    const cacheKey = 'session_latest';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.short, // 5 minutes - current session changes frequently
      fetch: () => _remoteDataSource.getLatestSession(),
      fromJson: (json) => Session.fromJson(json),
    );
  }
}
