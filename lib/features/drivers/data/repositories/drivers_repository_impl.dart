import 'package:f1sync/shared/services/cache/cache_service.dart';
import 'package:f1sync/features/drivers/data/datasources/drivers_remote_data_source.dart';
import 'package:f1sync/features/drivers/data/models/driver.dart';
import 'package:f1sync/features/drivers/domain/repositories/drivers_repository.dart';

/// Implementation of DriversRepository with caching
///
/// Uses Jolpica API for driver data.
class DriversRepositoryImpl implements DriversRepository {
  final DriversRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  DriversRepositoryImpl(
    this._remoteDataSource,
    this._cacheService,
  );

  @override
  Future<List<Driver>> getDrivers({
    dynamic season,
    int? driverNumber,
  }) async {
    final effectiveSeason = season ?? 'current';
    final cacheKey = 'drivers_jolpica_v3_${effectiveSeason}_${driverNumber ?? 'all'}';

    return await _cacheService.getCachedList<Driver>(
      key: cacheKey,
      ttl: CacheTTL.long, // 7 days - Jolpica data is stable
      fetch: () => _remoteDataSource.getDrivers(
        season: effectiveSeason,
        driverNumber: driverNumber,
      ),
      fromJson: Driver.fromJson,
    );
  }

  @override
  Future<Driver?> getDriverByNumber({
    required int driverNumber,
    dynamic season,
  }) async {
    final effectiveSeason = season ?? 'current';
    final cacheKey = 'driver_jolpica_v3_${effectiveSeason}_$driverNumber';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.long, // 7 days - Jolpica data is stable
      fetch: () => _remoteDataSource.getDriverByNumber(
        driverNumber: driverNumber,
        season: effectiveSeason,
      ),
      fromJson: (json) => Driver.fromJson(json),
    );
  }

  @override
  Future<Driver?> getDriverById({
    required String driverId,
    dynamic season,
  }) async {
    final effectiveSeason = season ?? 'current';
    final cacheKey = 'driver_jolpica_v3_${effectiveSeason}_id_$driverId';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.long, // 7 days - Jolpica data is stable
      fetch: () => _remoteDataSource.getDriverById(
        driverId,
        season: effectiveSeason,
      ),
      fromJson: (json) => Driver.fromJson(json),
    );
  }
}
