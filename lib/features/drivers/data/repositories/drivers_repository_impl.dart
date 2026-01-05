import 'package:f1sync/shared/services/cache/cache_service.dart';
import 'package:f1sync/features/drivers/data/datasources/drivers_remote_data_source.dart';
import 'package:f1sync/features/drivers/data/models/driver.dart';
import 'package:f1sync/features/drivers/domain/repositories/drivers_repository.dart';

/// Implementation of DriversRepository with caching
class DriversRepositoryImpl implements DriversRepository {
  final DriversRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  DriversRepositoryImpl(
    this._remoteDataSource,
    this._cacheService,
  );

  @override
  Future<List<Driver>> getDrivers({
    dynamic sessionKey,
    int? driverNumber,
  }) async {
    final cacheKey = 'drivers_${sessionKey}_$driverNumber';

    return await _cacheService.getCachedList<Driver>(
      key: cacheKey,
      ttl: CacheTTL.medium, // 1 hour - driver lineup changes rarely
      fetch: () => _remoteDataSource.getDrivers(
        sessionKey: sessionKey,
        driverNumber: driverNumber,
      ),
      fromJson: Driver.fromJson,
    );
  }

  @override
  Future<Driver?> getDriverByNumber({
    required int driverNumber,
    dynamic sessionKey,
  }) async {
    final cacheKey = 'driver_${driverNumber}_$sessionKey';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.medium,
      fetch: () => _remoteDataSource.getDriverByNumber(
        driverNumber: driverNumber,
        sessionKey: sessionKey,
      ),
      fromJson: (json) => Driver.fromJson(json),
    );
  }
}
