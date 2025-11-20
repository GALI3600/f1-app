import 'package:f1sync/core/cache/cache_service.dart';
import 'package:f1sync/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:f1sync/features/weather/data/models/weather.dart';
import 'package:f1sync/features/weather/domain/repositories/weather_repository.dart';

/// Implementation of WeatherRepository with caching
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  WeatherRepositoryImpl(
    this._remoteDataSource,
    this._cacheService,
  );

  @override
  Future<List<Weather>> getWeather({
    dynamic sessionKey,
  }) async {
    final cacheKey = 'weather_$sessionKey';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.short, // 5 minutes - weather updates every minute
      fetch: () => _remoteDataSource.getWeather(
        sessionKey: sessionKey,
      ),
    );
  }

  @override
  Future<Weather?> getLatestWeather({
    dynamic sessionKey,
  }) async {
    final cacheKey = 'latest_weather_$sessionKey';

    return await _cacheService.getCached(
      key: cacheKey,
      ttl: CacheTTL.short,
      fetch: () => _remoteDataSource.getLatestWeather(
        sessionKey: sessionKey,
      ),
    );
  }
}
