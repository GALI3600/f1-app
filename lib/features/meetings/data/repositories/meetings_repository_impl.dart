import 'package:f1sync/shared/services/cache/cache_service.dart';
import 'package:f1sync/features/meetings/data/datasources/meetings_remote_data_source.dart';
import 'package:f1sync/features/meetings/data/models/meeting.dart';
import 'package:f1sync/features/meetings/domain/repositories/meetings_repository.dart';

/// Implementation of MeetingsRepository with caching
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
    dynamic meetingKey,
    String? countryName,
  }) async {
    final cacheKey = 'meetings_${year}_${meetingKey}_$countryName';

    return await _cacheService.getCachedList<Meeting>(
      key: cacheKey,
      ttl: CacheTTL.long, // 7 days - historical data doesn't change often
      fetch: () => _remoteDataSource.getMeetings(
        year: year,
        meetingKey: meetingKey,
        countryName: countryName,
      ),
      fromJson: Meeting.fromJson,
    );
  }

  @override
  Future<Meeting?> getMeetingByKey(int meetingKey) async {
    final cacheKey = 'meeting_$meetingKey';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.long,
      fetch: () => _remoteDataSource.getMeetingByKey(meetingKey),
      fromJson: (json) => Meeting.fromJson(json),
    );
  }

  @override
  Future<Meeting?> getLatestMeeting() async {
    const cacheKey = 'meeting_latest';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.medium, // 1 hour - current GP changes weekly
      fetch: () => _remoteDataSource.getLatestMeeting(),
      fromJson: (json) => Meeting.fromJson(json),
    );
  }
}
