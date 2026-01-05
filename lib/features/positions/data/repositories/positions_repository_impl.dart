import 'package:f1sync/shared/services/cache/cache_service.dart';
import 'package:f1sync/features/positions/data/datasources/positions_remote_data_source.dart';
import 'package:f1sync/features/positions/data/models/position.dart';
import 'package:f1sync/features/positions/domain/repositories/positions_repository.dart';

/// Implementation of PositionsRepository with caching
class PositionsRepositoryImpl implements PositionsRepository {
  final PositionsRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  PositionsRepositoryImpl(
    this._remoteDataSource,
    this._cacheService,
  );

  @override
  Future<List<Position>> getPositions({
    dynamic sessionKey,
    int? driverNumber,
    int? position,
  }) async {
    final cacheKey = 'positions_${sessionKey}_${driverNumber}_$position';

    return await _cacheService.getCachedList<Position>(
      key: cacheKey,
      ttl: CacheTTL.short, // 5 minutes - positions change frequently
      fetch: () => _remoteDataSource.getPositions(
        sessionKey: sessionKey,
        driverNumber: driverNumber,
        position: position,
      ),
      fromJson: Position.fromJson,
    );
  }

  @override
  Future<List<Position>> getCurrentPositions({
    dynamic sessionKey,
  }) async {
    final cacheKey = 'current_positions_$sessionKey';

    return await _cacheService.getCachedList<Position>(
      key: cacheKey,
      ttl: CacheTTL.short,
      fetch: () => _remoteDataSource.getCurrentPositions(
        sessionKey: sessionKey,
      ),
      fromJson: Position.fromJson,
    );
  }
}
