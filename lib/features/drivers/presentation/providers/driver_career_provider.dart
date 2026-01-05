import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/jolpica_constants.dart';
import '../../../../shared/services/providers.dart';
import '../../data/datasources/driver_career_remote_data_source.dart';
import '../../data/models/driver_career.dart';
import '../../data/repositories/driver_career_repository_impl.dart';
import '../../domain/repositories/driver_career_repository.dart';

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

/// Provider for driver career stats by driver number
@riverpod
class DriverCareerNotifier extends _$DriverCareerNotifier {
  @override
  Future<DriverCareer?> build({required int driverNumber}) async {
    _logger.i('[CareerProvider] Starting fetch for driver #$driverNumber');

    try {
      final repository = ref.watch(driverCareerRepositoryProvider);
      _logger.i('[CareerProvider] Got repository, calling getDriverCareerByNumber');

      final career = await repository.getDriverCareerByNumber(driverNumber);

      if (career != null) {
        _logger.i('[CareerProvider] Career loaded: ${career.fullName} - '
            '${career.wins} wins, ${career.championships} titles');
      } else {
        _logger.w('[CareerProvider] No career data found for driver #$driverNumber');
      }

      return career;
    } catch (e, stack) {
      _logger.e('[CareerProvider] Error fetching career for #$driverNumber: $e');
      _logger.e('[CareerProvider] Stack: $stack');
      return null;
    }
  }

  /// Refresh career data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(driverNumber: driverNumber));
  }
}
