import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../../core/providers.dart';
import '../../data/models/driver.dart';
import '../../../laps/data/models/lap.dart';
import '../../../stints/data/models/stint.dart';
import '../../../positions/data/models/position.dart';

part 'driver_detail_provider.g.dart';

final _logger = Logger();

/// Aggregated driver detail data
class DriverDetailData {
  final Driver driver;
  final List<Lap> laps;
  final List<Stint> stints;
  final List<Position> positions;

  const DriverDetailData({
    required this.driver,
    required this.laps,
    required this.stints,
    required this.positions,
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

  /// Get number of pit stops (minimum 0)
  int get pitStops => stints.length > 1 ? stints.length - 1 : 0;

  /// Get current position (latest)
  int? get currentPosition {
    if (positions.isEmpty) return null;
    return positions.last.position;
  }

  /// Get position changes
  int get positionChanges {
    if (positions.length < 2) return 0;
    final startPos = positions.first.position;
    final endPos = positions.last.position;
    return startPos - endPos; // Positive = gained positions
  }
}

/// Provider for driver detail with aggregated data
@riverpod
class DriverDetailNotifier extends _$DriverDetailNotifier {
  @override
  Future<DriverDetailData> build({
    required int driverNumber,
    String sessionKey = 'latest',
  }) async {
    _logger.i('DriverDetailNotifier.build() called for driver #$driverNumber, sessionKey: $sessionKey');

    final driversRepo = ref.watch(driversRepositoryProvider);
    final lapsRepo = ref.watch(lapsRepositoryProvider);
    final stintsRepo = ref.watch(stintsRepositoryProvider);
    final positionsRepo = ref.watch(positionsRepositoryProvider);

    try {
      // First, try to get all data in parallel (works great with cache)
      // If we get rate limited, the repositories handle retries internally
      _logger.d('Fetching all data in parallel (cache-optimized)...');

      final results = await Future.wait([
        driversRepo.getDriverByNumber(
          driverNumber: driverNumber,
          sessionKey: sessionKey,
        ),
        lapsRepo.getLaps(
          sessionKey: sessionKey,
          driverNumber: driverNumber,
        ),
        stintsRepo.getStints(
          sessionKey: sessionKey,
          driverNumber: driverNumber,
        ),
        positionsRepo.getPositions(
          sessionKey: sessionKey,
          driverNumber: driverNumber,
        ),
      ]);

      final driver = results[0] as Driver?;
      final laps = results[1] as List<Lap>;
      final stints = results[2] as List<Stint>;
      final positions = results[3] as List<Position>;

      _logger.d('All data fetched successfully');
      _logger.d('driver: $driver');
      _logger.d('laps: ${laps.length} items');
      _logger.d('stints: ${stints.length} items');
      _logger.d('positions: ${positions.length} items');

      if (driver == null) {
        _logger.e('Driver #$driverNumber not found!');
        throw Exception('Driver not found');
      }

      _logger.i('Creating DriverDetailData for ${driver.fullName}');

      final detailData = DriverDetailData(
        driver: driver,
        laps: laps,
        stints: stints,
        positions: positions,
      );

      _logger.i('DriverDetailData created successfully: '
          'laps=${detailData.laps.length}, '
          'stints=${detailData.stints.length}, '
          'positions=${detailData.positions.length}, '
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
          driverNumber: driverNumber,
          sessionKey: sessionKey,
        ));
  }
}

/// Provider for driver's lap times (sorted by lap number)
@riverpod
List<Lap> sortedLaps(SortedLapsRef ref, int driverNumber) {
  final detailAsync = ref.watch(driverDetailNotifierProvider(
    driverNumber: driverNumber,
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
Lap? fastestLap(FastestLapRef ref, int driverNumber) {
  final detailAsync = ref.watch(driverDetailNotifierProvider(
    driverNumber: driverNumber,
  ));

  return detailAsync.when(
    data: (detail) => detail.fastestLap,
    loading: () => null,
    error: (_, __) => null,
  );
}
