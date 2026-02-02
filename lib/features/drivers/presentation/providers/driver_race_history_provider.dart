import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../../core/network/providers.dart';
import '../../data/models/driver_race_result.dart';

part 'driver_race_history_provider.g.dart';

final _logger = Logger();

/// Provider for driver's race history
///
/// Fetches all race results for a specific driver from Jolpica API
/// Results are sorted by date descending (most recent first)
@riverpod
class DriverRaceHistoryNotifier extends _$DriverRaceHistoryNotifier {
  @override
  Future<List<DriverRaceResult>> build({
    required String driverId,
  }) async {
    _logger.i('DriverRaceHistoryNotifier.build() for driver $driverId');

    final apiClient = ref.watch(jolpicaApiClientProvider);

    try {
      _logger.d('Fetching all race history for driver: $driverId');

      // API client handles pagination automatically
      final results = await apiClient.getDriverResults(driverId: driverId);

      final raceResults = results
          .map((json) => DriverRaceResult.fromJolpica(json))
          .toList();

      // Sort by date descending (most recent first)
      raceResults.sort((a, b) => b.date.compareTo(a.date));

      _logger.i('Loaded ${raceResults.length} total race results for $driverId');

      return raceResults;
    } catch (e, stackTrace) {
      _logger.e('Error fetching driver race history: $e');
      _logger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Refresh race history data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(driverId: driverId));
  }
}

/// Statistics derived from driver's race history
class DriverRaceStats {
  final int totalRaces;
  final int wins;
  final int podiums;
  final int pointsFinishes;
  final int dnfs;
  final double totalPoints;
  final int bestPosition;
  final int bestGridPosition;

  const DriverRaceStats({
    required this.totalRaces,
    required this.wins,
    required this.podiums,
    required this.pointsFinishes,
    required this.dnfs,
    required this.totalPoints,
    required this.bestPosition,
    required this.bestGridPosition,
  });

  factory DriverRaceStats.fromResults(List<DriverRaceResult> results) {
    if (results.isEmpty) {
      return const DriverRaceStats(
        totalRaces: 0,
        wins: 0,
        podiums: 0,
        pointsFinishes: 0,
        dnfs: 0,
        totalPoints: 0,
        bestPosition: 0,
        bestGridPosition: 0,
      );
    }

    final wins = results.where((r) => r.isWin).length;
    final podiums = results.where((r) => r.isPodium).length;
    final pointsFinishes = results.where((r) => r.isPointsFinish).length;
    final dnfs = results.where((r) => r.dnf).length;
    final totalPoints = results.fold<double>(0, (sum, r) => sum + r.points);
    final bestPosition = results.map((r) => r.position).reduce((a, b) => a < b ? a : b);
    final bestGridPosition = results.map((r) => r.gridPosition).where((g) => g > 0).fold(999, (a, b) => a < b ? a : b);

    return DriverRaceStats(
      totalRaces: results.length,
      wins: wins,
      podiums: podiums,
      pointsFinishes: pointsFinishes,
      dnfs: dnfs,
      totalPoints: totalPoints,
      bestPosition: bestPosition,
      bestGridPosition: bestGridPosition == 999 ? 0 : bestGridPosition,
    );
  }
}

/// Provider for driver race statistics derived from race history
@riverpod
DriverRaceStats driverRaceStats(DriverRaceStatsRef ref, String driverId) {
  final historyAsync = ref.watch(driverRaceHistoryNotifierProvider(
    driverId: driverId,
  ));

  return historyAsync.when(
    data: (results) => DriverRaceStats.fromResults(results),
    loading: () => const DriverRaceStats(
      totalRaces: 0,
      wins: 0,
      podiums: 0,
      pointsFinishes: 0,
      dnfs: 0,
      totalPoints: 0,
      bestPosition: 0,
      bestGridPosition: 0,
    ),
    error: (_, __) => const DriverRaceStats(
      totalRaces: 0,
      wins: 0,
      podiums: 0,
      pointsFinishes: 0,
      dnfs: 0,
      totalPoints: 0,
      bestPosition: 0,
      bestGridPosition: 0,
    ),
  );
}
