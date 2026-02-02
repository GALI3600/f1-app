import 'package:f1sync/shared/services/cache/cache_service.dart';
import 'package:f1sync/features/meetings/data/datasources/meetings_remote_data_source.dart';
import 'package:f1sync/features/meetings/data/models/meeting.dart';
import 'package:f1sync/features/meetings/domain/repositories/meetings_repository.dart';

/// Implementation of MeetingsRepository with caching
///
/// Uses Jolpica API for race schedule data.
class MeetingsRepositoryImpl implements MeetingsRepository {
  final MeetingsRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  MeetingsRepositoryImpl(
    this._remoteDataSource,
    this._cacheService,
  );

  @override
  Future<List<Meeting>> getMeetings({
    int? year,
    int? round,
    String? countryName,
  }) async {
    final effectiveYear = year ?? DateTime.now().year;
    final cacheKey = 'meetings_${effectiveYear}_${round}_$countryName';

    return await _cacheService.getCachedList<Meeting>(
      key: cacheKey,
      ttl: CacheTTL.long, // 7 days - schedule doesn't change often
      fetch: () => _remoteDataSource.getMeetings(
        year: effectiveYear,
        round: round,
        countryName: countryName,
      ),
      fromJson: Meeting.fromJson,
    );
  }

  @override
  Future<Meeting?> getMeetingByKey(int round, {int? year}) async {
    final effectiveYear = year ?? DateTime.now().year;
    final cacheKey = 'meeting_${effectiveYear}_$round';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.long,
      fetch: () => _remoteDataSource.getMeetingByKey(round, year: effectiveYear),
      fromJson: (json) => Meeting.fromJson(json),
    );
  }

  @override
  Future<Meeting?> getLatestMeeting() async {
    final year = DateTime.now().year;
    final cacheKey = 'meeting_latest_$year';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.medium, // 1 hour - current GP changes weekly
      fetch: () => _remoteDataSource.getLatestMeeting(),
      fromJson: (json) => Meeting.fromJson(json),
    );
  }
}
