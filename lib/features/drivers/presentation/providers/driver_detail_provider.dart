import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers.dart';
import '../../data/models/driver.dart';
import '../../../laps/data/models/lap.dart';
import '../../../stints/data/models/stint.dart';
import '../../../positions/data/models/position.dart';

part 'driver_detail_provider.g.dart';

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

  /// Get fastest lap
  Lap? get fastestLap {
    if (laps.isEmpty) return null;
    return laps.reduce((a, b) =>
        a.lapDuration < b.lapDuration ? a : b);
  }

  /// Get average lap time
  double get averageLapTime {
    if (laps.isEmpty) return 0.0;
    final validLaps = laps.where((lap) => !lap.isPitOutLap).toList();
    if (validLaps.isEmpty) return 0.0;

    final total = validLaps.fold<double>(
      0.0,
      (sum, lap) => sum + lap.lapDuration,
    );
    return total / validLaps.length;
  }

  /// Get total laps completed
  int get totalLaps => laps.length;

  /// Get number of pit stops
  int get pitStops => stints.length - 1;

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
    final driversRepo = ref.watch(driversRepositoryProvider);
    final lapsRepo = ref.watch(lapsRepositoryProvider);
    final stintsRepo = ref.watch(stintsRepositoryProvider);
    final positionsRepo = ref.watch(positionsRepositoryProvider);

    try {
      // Fetch all data in parallel
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
      if (driver == null) {
        throw Exception('Driver not found');
      }

      return DriverDetailData(
        driver: driver,
        laps: results[1] as List<Lap>,
        stints: results[2] as List<Stint>,
        positions: results[3] as List<Position>,
      );
    } catch (e) {
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
