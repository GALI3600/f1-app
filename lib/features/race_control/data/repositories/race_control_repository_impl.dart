import 'package:f1sync/shared/services/cache/cache_service.dart';
import 'package:f1sync/features/race_control/data/datasources/race_control_remote_data_source.dart';
import 'package:f1sync/features/race_control/data/models/race_control.dart';
import 'package:f1sync/features/race_control/domain/repositories/race_control_repository.dart';

/// Implementation of RaceControlRepository with caching
class RaceControlRepositoryImpl implements RaceControlRepository {
  final RaceControlRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  RaceControlRepositoryImpl(
    this._remoteDataSource,
    this._cacheService,
  );

  @override
  Future<List<RaceControl>> getRaceControlMessages({
    dynamic sessionKey,
    String? category,
    String? flag,
  }) async {
    final cacheKey = 'race_control_${sessionKey}_${category}_$flag';

    return await _cacheService.getCachedList<RaceControl>(
      key: cacheKey,
      ttl: CacheTTL.medium, // 1 hour - messages are historical once created
      fetch: () => _remoteDataSource.getRaceControlMessages(
        sessionKey: sessionKey,
        category: category,
        flag: flag,
      ),
      fromJson: RaceControl.fromJson,
    );
  }
}
