import 'package:f1sync/core/cache/cache_service.dart';
import 'package:f1sync/features/laps/data/datasources/laps_remote_data_source.dart';
import 'package:f1sync/features/laps/data/models/lap.dart';
import 'package:f1sync/features/laps/domain/repositories/laps_repository.dart';

/// Implementation of LapsRepository with caching
class LapsRepositoryImpl implements LapsRepository {
  final LapsRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  LapsRepositoryImpl(
    this._remoteDataSource,
    this._cacheService,
  );

  @override
  Future<List<Lap>> getLaps({
    dynamic sessionKey,
    int? driverNumber,
    int? lapNumber,
  }) async {
    final cacheKey = 'laps_${sessionKey}_${driverNumber}_$lapNumber';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.short, // 5 minutes - laps update frequently during session
      fetch: () => _remoteDataSource.getLaps(
        sessionKey: sessionKey,
        driverNumber: driverNumber,
        lapNumber: lapNumber,
      ),
    );
  }

  @override
  Future<List<Lap>> getDriverLaps({
    required int driverNumber,
    dynamic sessionKey,
  }) async {
    final cacheKey = 'driver_laps_${driverNumber}_$sessionKey';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.short,
      fetch: () => _remoteDataSource.getDriverLaps(
        driverNumber: driverNumber,
        sessionKey: sessionKey,
      ),
    );
  }
}
