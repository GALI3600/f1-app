import 'package:f1sync/core/cache/cache_service.dart';
import 'package:f1sync/core/network/api_client.dart';
import 'package:f1sync/features/drivers/data/datasources/drivers_remote_data_source.dart';
import 'package:f1sync/features/drivers/data/repositories/drivers_repository_impl.dart';
import 'package:f1sync/features/drivers/domain/repositories/drivers_repository.dart';
import 'package:f1sync/features/laps/data/datasources/laps_remote_data_source.dart';
import 'package:f1sync/features/laps/data/repositories/laps_repository_impl.dart';
import 'package:f1sync/features/laps/domain/repositories/laps_repository.dart';
import 'package:f1sync/features/meetings/data/datasources/meetings_remote_data_source.dart';
import 'package:f1sync/features/meetings/data/repositories/meetings_repository_impl.dart';
import 'package:f1sync/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:f1sync/features/positions/data/datasources/positions_remote_data_source.dart';
import 'package:f1sync/features/positions/data/repositories/positions_repository_impl.dart';
import 'package:f1sync/features/positions/domain/repositories/positions_repository.dart';
import 'package:f1sync/features/race_control/data/datasources/race_control_remote_data_source.dart';
import 'package:f1sync/features/race_control/data/repositories/race_control_repository_impl.dart';
import 'package:f1sync/features/race_control/domain/repositories/race_control_repository.dart';
import 'package:f1sync/features/sessions/data/datasources/sessions_remote_data_source.dart';
import 'package:f1sync/features/sessions/data/repositories/sessions_repository_impl.dart';
import 'package:f1sync/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:f1sync/features/stints/data/datasources/stints_remote_data_source.dart';
import 'package:f1sync/features/stints/data/repositories/stints_repository_impl.dart';
import 'package:f1sync/features/stints/domain/repositories/stints_repository.dart';
import 'package:f1sync/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:f1sync/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:f1sync/features/weather/domain/repositories/weather_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

// ========== Core Services ==========

/// API Client Provider
@riverpod
OpenF1ApiClient apiClient(ApiClientRef ref) {
  return OpenF1ApiClient();
}

/// Cache Service Provider
@riverpod
CacheService cacheService(CacheServiceRef ref) {
  final service = CacheService();
  // Initialize cache service
  service.init();
  return service;
}

// ========== Data Sources ==========

@riverpod
MeetingsRemoteDataSource meetingsRemoteDataSource(
  MeetingsRemoteDataSourceRef ref,
) {
  return MeetingsRemoteDataSource(ref.watch(apiClientProvider));
}

@riverpod
SessionsRemoteDataSource sessionsRemoteDataSource(
  SessionsRemoteDataSourceRef ref,
) {
  return SessionsRemoteDataSource(ref.watch(apiClientProvider));
}

@riverpod
DriversRemoteDataSource driversRemoteDataSource(
  DriversRemoteDataSourceRef ref,
) {
  return DriversRemoteDataSource(ref.watch(apiClientProvider));
}

@riverpod
LapsRemoteDataSource lapsRemoteDataSource(LapsRemoteDataSourceRef ref) {
  return LapsRemoteDataSource(ref.watch(apiClientProvider));
}

@riverpod
PositionsRemoteDataSource positionsRemoteDataSource(
  PositionsRemoteDataSourceRef ref,
) {
  return PositionsRemoteDataSource(ref.watch(apiClientProvider));
}

@riverpod
WeatherRemoteDataSource weatherRemoteDataSource(
  WeatherRemoteDataSourceRef ref,
) {
  return WeatherRemoteDataSource(ref.watch(apiClientProvider));
}

@riverpod
RaceControlRemoteDataSource raceControlRemoteDataSource(
  RaceControlRemoteDataSourceRef ref,
) {
  return RaceControlRemoteDataSource(ref.watch(apiClientProvider));
}

@riverpod
StintsRemoteDataSource stintsRemoteDataSource(StintsRemoteDataSourceRef ref) {
  return StintsRemoteDataSource(ref.watch(apiClientProvider));
}

// ========== Repositories ==========

@riverpod
MeetingsRepository meetingsRepository(MeetingsRepositoryRef ref) {
  return MeetingsRepositoryImpl(
    ref.watch(meetingsRemoteDataSourceProvider),
    ref.watch(cacheServiceProvider),
  );
}

@riverpod
SessionsRepository sessionsRepository(SessionsRepositoryRef ref) {
  return SessionsRepositoryImpl(
    ref.watch(sessionsRemoteDataSourceProvider),
    ref.watch(cacheServiceProvider),
  );
}

@riverpod
DriversRepository driversRepository(DriversRepositoryRef ref) {
  return DriversRepositoryImpl(
    ref.watch(driversRemoteDataSourceProvider),
    ref.watch(cacheServiceProvider),
  );
}

@riverpod
LapsRepository lapsRepository(LapsRepositoryRef ref) {
  return LapsRepositoryImpl(
    ref.watch(lapsRemoteDataSourceProvider),
    ref.watch(cacheServiceProvider),
  );
}

@riverpod
PositionsRepository positionsRepository(PositionsRepositoryRef ref) {
  return PositionsRepositoryImpl(
    ref.watch(positionsRemoteDataSourceProvider),
    ref.watch(cacheServiceProvider),
  );
}

@riverpod
WeatherRepository weatherRepository(WeatherRepositoryRef ref) {
  return WeatherRepositoryImpl(
    ref.watch(weatherRemoteDataSourceProvider),
    ref.watch(cacheServiceProvider),
  );
}

@riverpod
RaceControlRepository raceControlRepository(RaceControlRepositoryRef ref) {
  return RaceControlRepositoryImpl(
    ref.watch(raceControlRemoteDataSourceProvider),
    ref.watch(cacheServiceProvider),
  );
}

@riverpod
StintsRepository stintsRepository(StintsRepositoryRef ref) {
  return StintsRepositoryImpl(
    ref.watch(stintsRemoteDataSourceProvider),
    ref.watch(cacheServiceProvider),
  );
}
