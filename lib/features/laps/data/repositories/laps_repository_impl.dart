import 'package:f1sync/shared/services/cache/cache_service.dart';
import 'package:f1sync/features/laps/data/datasources/laps_remote_data_source.dart';
import 'package:f1sync/features/laps/data/models/lap.dart';
import 'package:f1sync/features/laps/domain/repositories/laps_repository.dart';

/// Implementation of LapsRepository with caching
///
/// Uses Jolpica API for historical lap data from completed races.
class LapsRepositoryImpl implements LapsRepository {
  final LapsRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  LapsRepositoryImpl(
    this._remoteDataSource,
    this._cacheService,
  );

  @override
  Future<List<Lap>> getLaps({
    int? round,
    dynamic sessionKey,
    int? driverNumber,
    int? lapNumber,
    int? year,
  }) async {
    // Extract round from sessionKey if not provided directly
    final effectiveRound = round ?? (sessionKey != null ? (sessionKey as int) ~/ 100 : null);

    if (effectiveRound == null) {
      return [];
    }

    final cacheKey = 'laps_${year ?? 'current'}_${effectiveRound}_${driverNumber}_$lapNumber';

    return await _cacheService.getCachedList<Lap>(
      key: cacheKey,
      ttl: CacheTTL.long, // Historical data - cache for 7 days
      fetch: () => _remoteDataSource.getLaps(
        round: effectiveRound,
        driverNumber: driverNumber,
        lapNumber: lapNumber,
        year: year,
      ),
      fromJson: Lap.fromJson,
    );
  }

  @override
  Future<List<Lap>> getDriverLaps({
    required int driverNumber,
    required int round,
    int? year,
  }) async {
    final cacheKey = 'driver_laps_${year ?? 'current'}_${round}_$driverNumber';

    return await _cacheService.getCachedList<Lap>(
      key: cacheKey,
      ttl: CacheTTL.long, // Historical data - cache for 7 days
      fetch: () => _remoteDataSource.getDriverLaps(
        driverNumber: driverNumber,
        round: round,
        year: year,
      ),
      fromJson: Lap.fromJson,
    );
  }
}
