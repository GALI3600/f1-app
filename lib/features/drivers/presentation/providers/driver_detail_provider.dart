import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../../core/providers.dart';
import '../../data/models/driver.dart';
import '../../../laps/data/models/lap.dart';

part 'driver_detail_provider.g.dart';

final _logger = Logger();

/// Aggregated driver detail data
///
/// Note: Stints and Positions have been removed as they are not available
/// in the Jolpica API (historical data only).
class DriverDetailData {
  final Driver driver;
  final List<Lap> laps;

  const DriverDetailData({
    required this.driver,
    required this.laps,
  });

  /// Get fastest lap (excludes laps with 0 or invalid duration)
  Lap? get fastestLap {
    if (laps.isEmpty) return null;
    final validLaps = laps.where((lap) => lap.lapDuration > 0).toList();
    if (validLaps.isEmpty) return null;
    return validLaps.reduce((a, b) =>
        a.lapDuration < b.lapDuration ? a : b);
  }

  /// Get average lap time (excludes pit out laps and laps with 0 duration)
  double get averageLapTime {
    if (laps.isEmpty) return 0.0;
    final validLaps = laps.where((lap) => !lap.isPitOutLap && lap.lapDuration > 0).toList();
    if (validLaps.isEmpty) return 0.0;

    final total = validLaps.fold<double>(
      0.0,
      (sum, lap) => sum + lap.lapDuration,
    );
    return total / validLaps.length;
  }

  /// Get total laps completed
  int get totalLaps => laps.length;

  /// Get best position during the race (from lap position data)
  int? get bestPosition {
    if (laps.isEmpty) return null;
    final positions = laps.where((l) => l.position != null).map((l) => l.position!).toList();
    if (positions.isEmpty) return null;
    return positions.reduce((a, b) => a < b ? a : b);
  }

  /// Get final position (from last lap)
  int? get finalPosition {
    if (laps.isEmpty) return null;
    final sortedLaps = List<Lap>.from(laps)
      ..sort((a, b) => b.lapNumber.compareTo(a.lapNumber));
    return sortedLaps.first.position;
  }
}

/// Provider for driver detail with aggregated data
@riverpod
class DriverDetailNotifier extends _$DriverDetailNotifier {
  @override
  Future<DriverDetailData> build({
    required String driverId,
    int? round,
  }) async {
    _logger.i('DriverDetailNotifier.build() called for driver $driverId, round: $round');

    final driversRepo = ref.watch(driversRepositoryProvider);
    final lapsRepo = ref.watch(lapsRepositoryProvider);

    try {
      _logger.d('Fetching driver and laps data...');

      // Fetch driver by ID
      final driver = await driversRepo.getDriverById(driverId: driverId);

      // Fetch laps if round is specified and driver has a valid number
      List<Lap> laps = [];
      if (round != null && driver != null && driver.driverNumber > 0) {
        laps = await lapsRepo.getDriverLaps(driverNumber: driver.driverNumber, round: round);
      }

      _logger.d('Data fetched successfully');
      _logger.d('driver: $driver');
      _logger.d('laps: ${laps.length} items');

      // If driver not found, create empty driver with data from assets
      final resolvedDriver = driver ?? Driver.empty(driverId);

      _logger.i('Creating DriverDetailData for ${resolvedDriver.fullName}');

      final detailData = DriverDetailData(
        driver: resolvedDriver,
        laps: laps,
      );

      _logger.i('DriverDetailData created successfully: '
          'laps=${detailData.laps.length}, '
          'fastestLap=${detailData.fastestLap?.lapDuration}, '
          'avgLapTime=${detailData.averageLapTime}');

      return detailData;
    } catch (e, stackTrace) {
      _logger.e('Error in DriverDetailNotifier.build(): $e');
      _logger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Refresh all driver detail data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(
          driverId: driverId,
          round: round,
        ));
  }
}

/// Provider for driver's lap times (sorted by lap number)
@riverpod
List<Lap> sortedLaps(SortedLapsRef ref, String driverId, {int? round}) {
  final detailAsync = ref.watch(driverDetailNotifierProvider(
    driverId: driverId,
    round: round,
  ));

  return detailAsync.when(
    data: (detail) {
      final laps = List<Lap>.from(detail.laps);
      laps.sort((a, b) => a.lapNumber.compareTo(b.lapNumber));
      return laps;
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for fastest lap in session
@riverpod
Lap? fastestLap(FastestLapRef ref, String driverId, {int? round}) {
  final detailAsync = ref.watch(driverDetailNotifierProvider(
    driverId: driverId,
    round: round,
  ));

  return detailAsync.when(
    data: (detail) => detail.fastestLap,
    loading: () => null,
    error: (_, __) => null,
  );
}
