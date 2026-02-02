import 'package:f1sync/shared/services/cache/cache_service.dart';
import 'package:f1sync/features/sessions/data/datasources/sessions_remote_data_source.dart';
import 'package:f1sync/features/sessions/data/models/session.dart';
import 'package:f1sync/features/sessions/domain/repositories/sessions_repository.dart';

/// Implementation of SessionsRepository with caching
///
/// Sessions are extracted from Jolpica race schedule data.
class SessionsRepositoryImpl implements SessionsRepository {
  final SessionsRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  SessionsRepositoryImpl(
    this._remoteDataSource,
    this._cacheService,
  );

  @override
  Future<List<Session>> getSessions({
    int? round,
    dynamic sessionKey,
    String? sessionType,
    int? year,
  }) async {
    final seasonYear = year ?? DateTime.now().year;
    final cacheKey = 'sessions_${seasonYear}_${round}_${sessionKey}_$sessionType';

    return await _cacheService.getCachedList<Session>(
      key: cacheKey,
      ttl: CacheTTL.long, // 7 days - schedule is stable
      fetch: () => _remoteDataSource.getSessions(
        meetingKey: round,
        sessionKey: sessionKey,
        sessionType: sessionType,
        year: seasonYear,
      ),
      fromJson: Session.fromJson,
    );
  }

  @override
  Future<Session?> getSessionByKey(int sessionKey, {int? year}) async {
    final seasonYear = year ?? DateTime.now().year;
    final cacheKey = 'session_${seasonYear}_$sessionKey';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.long,
      fetch: () => _remoteDataSource.getSessionByKey(sessionKey, year: seasonYear),
      fromJson: (json) => Session.fromJson(json),
    );
  }

  @override
  Future<Session?> getLatestSession({int? year}) async {
    final seasonYear = year ?? DateTime.now().year;
    final cacheKey = 'session_latest_$seasonYear';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.medium, // 1 hour - next session changes weekly
      fetch: () => _remoteDataSource.getLatestSession(year: seasonYear),
      fromJson: (json) => Session.fromJson(json),
    );
  }
}
