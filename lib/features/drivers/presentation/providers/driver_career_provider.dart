import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/jolpica_constants.dart';
import '../../../../shared/services/providers.dart';
import '../../data/datasources/driver_career_remote_data_source.dart';
import '../../data/models/driver_career.dart';
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
    _logger.i('[CareerProvider] Starting optimized fetch for $driverId');

    try {
      // First, get race history (may already be cached/loaded by UI)
      final raceHistoryAsync = ref.watch(driverRaceHistoryNotifierProvider(driverId: driverId));

      // Wait for race history to load
      final raceHistory = await raceHistoryAsync.when(
        data: (data) async => data,
        loading: () async {
          // If still loading, wait for it
          _logger.d('[CareerProvider] Waiting for race history to load...');
          return await ref.read(driverRaceHistoryNotifierProvider(driverId: driverId).future);
        },
        error: (e, _) async {
          _logger.w('[CareerProvider] Race history failed, will use legacy fetch: $e');
          return null;
        },
      );

      final dataSource = ref.watch(driverCareerRemoteDataSourceProvider);

      DriverCareer? career;

      if (raceHistory != null && raceHistory.isNotEmpty) {
        // Calculate stats from race history (no extra API calls!)
        final stats = DriverRaceStats.fromResults(raceHistory);
        _logger.i('[CareerProvider] Calculated from history: wins=${stats.wins}, podiums=${stats.podiums}, races=${stats.totalRaces}');

        // Use optimized method - only fetches poles, seasons, standings, championships
        career = await dataSource.getDriverCareerOptimized(
          driverId: driverId,
          wins: stats.wins,
          podiums: stats.podiums,
          totalRaces: stats.totalRaces,
        );
      } else {
        // Fallback: use legacy method if race history not available
        _logger.w('[CareerProvider] No race history, using legacy fetch');
        career = await dataSource.getDriverCareer(driverId);
      }

      if (career != null) {
        _logger.i('[CareerProvider] Career loaded: ${career.fullName} - ${career.wins} wins, ${career.championships} titles');
      } else {
        _logger.w('[CareerProvider] No career data found for $driverId');
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
