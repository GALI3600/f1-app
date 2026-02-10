import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/jolpica_constants.dart';
import '../../../../shared/services/providers.dart';
import '../../data/datasources/driver_career_remote_data_source.dart';
import '../../data/models/driver_career.dart';
import '../../data/models/driver_race_result.dart';
import '../../data/repositories/driver_career_repository_impl.dart';
import '../../domain/repositories/driver_career_repository.dart';
import 'driver_race_history_provider.dart';

part 'driver_career_provider.g.dart';

final _logger = Logger();

/// Dio instance for Jolpica API
@riverpod
Dio jolpicaDio(JolpicaDioRef ref) {
  return Dio(BaseOptions(
    baseUrl: JolpicaConstants.baseUrl,
    connectTimeout: Duration(milliseconds: JolpicaConstants.timeout),
    receiveTimeout: Duration(milliseconds: JolpicaConstants.timeout),
    headers: {
      'Accept': 'application/json',
    },
  ));
}

/// Data source for driver career
@riverpod
DriverCareerRemoteDataSource driverCareerRemoteDataSource(
  DriverCareerRemoteDataSourceRef ref,
) {
  return DriverCareerRemoteDataSource(ref.watch(jolpicaDioProvider));
}

/// Repository for driver career with caching
@riverpod
DriverCareerRepository driverCareerRepository(DriverCareerRepositoryRef ref) {
  return DriverCareerRepositoryImpl(
    ref.watch(driverCareerRemoteDataSourceProvider),
    ref.watch(cacheServiceProvider),
  );
}

/// Provider for driver career stats by driver ID
/// Optimized: Uses race history to calculate wins/podiums/totalRaces
/// Only fetches from API: poles, seasons, standings, championships
@riverpod
class DriverCareerNotifier extends _$DriverCareerNotifier {
  @override
  Future<DriverCareer?> build({required String driverId}) async {
    _logger.i('[CareerProvider] Starting fetch for $driverId');

    try {
      final repository = ref.read(driverCareerRepositoryProvider);

      // Try optimized path: use race history to skip wins/podiums/races API calls
      List<DriverRaceResult>? raceHistory;
      try {
        raceHistory = await ref.read(
          driverRaceHistoryNotifierProvider(driverId: driverId).future,
        );
      } catch (e) {
        _logger.w('[CareerProvider] Race history unavailable: $e');
      }

      DriverCareer? career;

      if (raceHistory != null && raceHistory.isNotEmpty) {
        // Optimized: calculate stats from history → only ~5 API calls
        final stats = DriverRaceStats.fromResults(raceHistory);
        _logger.i('[CareerProvider] Using optimized path: wins=${stats.wins}, podiums=${stats.podiums}, races=${stats.totalRaces}');
        career = await repository.getDriverCareerOptimized(
          driverId,
          wins: stats.wins,
          podiums: stats.podiums,
          totalRaces: stats.totalRaces,
        );
      } else {
        // Fallback: legacy path (~12 API calls)
        _logger.w('[CareerProvider] No race history, using legacy path');
        career = await repository.getDriverCareer(driverId);
      }

      if (career != null) {
        _logger.i('[CareerProvider] Career loaded: ${career.fullName} - ${career.wins} wins, ${career.championships} titles');
      }

      return career;
    } catch (e, stack) {
      _logger.e('[CareerProvider] Error: $e');
      _logger.e('[CareerProvider] Stack: $stack');
      return null;
    }
  }

  /// Refresh career data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(driverId: driverId));
  }
}
