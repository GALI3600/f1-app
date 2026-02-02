import 'package:f1sync/shared/services/providers.dart' show cacheServiceProvider;
import 'package:f1sync/core/network/providers.dart' as network_providers;
import 'package:f1sync/features/drivers/data/datasources/drivers_remote_data_source.dart';
import 'package:f1sync/features/drivers/data/repositories/drivers_repository_impl.dart';
import 'package:f1sync/features/drivers/domain/repositories/drivers_repository.dart';
import 'package:f1sync/features/laps/data/datasources/laps_remote_data_source.dart';
import 'package:f1sync/features/laps/data/repositories/laps_repository_impl.dart';
import 'package:f1sync/features/laps/domain/repositories/laps_repository.dart';
import 'package:f1sync/features/meetings/data/datasources/meetings_remote_data_source.dart';
import 'package:f1sync/features/meetings/data/repositories/meetings_repository_impl.dart';
import 'package:f1sync/features/meetings/domain/repositories/meetings_repository.dart';
import 'package:f1sync/features/sessions/data/datasources/sessions_remote_data_source.dart';
import 'package:f1sync/features/sessions/data/repositories/sessions_repository_impl.dart';
import 'package:f1sync/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:f1sync/features/session_results/data/datasources/session_results_remote_data_source.dart';
import 'package:f1sync/features/session_results/data/repositories/session_results_repository_impl.dart';
import 'package:f1sync/features/session_results/domain/repositories/session_results_repository.dart';
import 'package:f1sync/features/standings/data/datasources/standings_remote_data_source.dart';
import 'package:f1sync/features/standings/data/repositories/standings_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

// ========== Data Sources ==========
// All data sources now use Jolpica API

@riverpod
MeetingsRemoteDataSource meetingsRemoteDataSource(
  MeetingsRemoteDataSourceRef ref,
) {
  return MeetingsRemoteDataSource(ref.watch(network_providers.jolpicaApiClientProvider));
}

@riverpod
SessionsRemoteDataSource sessionsRemoteDataSource(
  SessionsRemoteDataSourceRef ref,
) {
  return SessionsRemoteDataSource(ref.watch(network_providers.jolpicaApiClientProvider));
}

@riverpod
DriversRemoteDataSource driversRemoteDataSource(
  DriversRemoteDataSourceRef ref,
) {
  return DriversRemoteDataSource(ref.watch(network_providers.jolpicaApiClientProvider));
}

@riverpod
LapsRemoteDataSource lapsRemoteDataSource(LapsRemoteDataSourceRef ref) {
  return LapsRemoteDataSource(ref.watch(network_providers.jolpicaApiClientProvider));
}

@riverpod
SessionResultsRemoteDataSource sessionResultsRemoteDataSource(
  SessionResultsRemoteDataSourceRef ref,
) {
  return SessionResultsRemoteDataSource(ref.watch(network_providers.jolpicaApiClientProvider));
}

@riverpod
StandingsRemoteDataSource standingsRemoteDataSource(
  StandingsRemoteDataSourceRef ref,
) {
  return StandingsRemoteDataSource(ref.watch(network_providers.jolpicaApiClientProvider));
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
SessionResultsRepository sessionResultsRepository(SessionResultsRepositoryRef ref) {
  return SessionResultsRepositoryImpl(
    ref.watch(sessionResultsRemoteDataSourceProvider),
  );
}

@riverpod
StandingsRepository standingsRepository(StandingsRepositoryRef ref) {
  return StandingsRepository(
    ref.watch(standingsRemoteDataSourceProvider),
    ref.watch(cacheServiceProvider),
  );
}
