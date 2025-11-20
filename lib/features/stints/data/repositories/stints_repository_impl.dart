import 'package:f1sync/core/cache/cache_service.dart';
import 'package:f1sync/features/stints/data/datasources/stints_remote_data_source.dart';
import 'package:f1sync/features/stints/data/models/stint.dart';
import 'package:f1sync/features/stints/domain/repositories/stints_repository.dart';

/// Implementation of StintsRepository with caching
class StintsRepositoryImpl implements StintsRepository {
  final StintsRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  StintsRepositoryImpl(
    this._remoteDataSource,
    this._cacheService,
  );

  @override
  Future<List<Stint>> getStints({
    dynamic sessionKey,
    int? driverNumber,
  }) async {
    final cacheKey = 'stints_${sessionKey}_$driverNumber';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.medium, // 1 hour - stint strategy data
      fetch: () => _remoteDataSource.getStints(
        sessionKey: sessionKey,
        driverNumber: driverNumber,
      ),
    );
  }

  @override
  Future<List<Stint>> getDriverStints({
    required int driverNumber,
    dynamic sessionKey,
  }) async {
    final cacheKey = 'driver_stints_${driverNumber}_$sessionKey';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.medium,
      fetch: () => _remoteDataSource.getDriverStints(
        driverNumber: driverNumber,
        sessionKey: sessionKey,
      ),
    );
  }
}
