import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../../../core/network/providers.dart';
import '../../../../shared/services/cache/cache_service.dart';
import '../../../../shared/services/providers.dart';
import '../../data/models/driver_race_result.dart';

part 'driver_race_history_provider.g.dart';

final _logger = Logger();

/// Cache key prefix for driver race history
const _raceHistoryCachePrefix = 'driver_race_history_';

/// Provider for driver's race history
///
/// Fetches all race results for a specific driver from Jolpica API
/// Results are cached for 7 days (historical data rarely changes)
/// Results are sorted by date descending (most recent first)
@riverpod
class DriverRaceHistoryNotifier extends _$DriverRaceHistoryNotifier {
  @override
  Future<List<DriverRaceResult>> build({
    required String driverId,
  }) async {
    _logger.i('DriverRaceHistoryNotifier.build() for driver $driverId');

    final cacheService = ref.read(cacheServiceProvider);
    final apiClient = ref.watch(jolpicaApiClientProvider);
    final cacheKey = '$_raceHistoryCachePrefix$driverId';

    try {
      final raceResults = await cacheService.getCachedList<DriverRaceResult>(
        key: cacheKey,
        ttl: CacheTTL.long,
        fromJson: DriverRaceResult.fromJson,
        fetch: () async {
          _logger.d('Fetching all race + sprint history for driver: $driverId');

          // Fetch race and sprint results in parallel
          final futures = await Future.wait([
            apiClient.getDriverResults(driverId: driverId),
            apiClient.getDriverSprintResults(driverId: driverId),
          ]);

          final raceJsons = futures[0];
          final sprintJsons = futures[1];

          final parsed = <DriverRaceResult>[
            ...raceJsons.map((json) => DriverRaceResult.fromJolpica(json)),
            ...sprintJsons.map((json) => DriverRaceResult.fromJolpicaSprint(json)),
          ];

          parsed.sort((a, b) => b.date.compareTo(a.date));
          _logger.i('Loaded ${raceJsons.length} races + ${sprintJsons.length} sprints for $driverId');
          return parsed;
        },
      );

      return raceResults;
    } catch (e, stackTrace) {
      _logger.e('Error fetching driver race history: $e');
      _logger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Refresh race history data (invalidates cache)
  Future<void> refresh() async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.invalidate('$_raceHistoryCachePrefix$driverId');
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

    // Only count main races for wins/podiums/totalRaces (not sprints)
    final races = results.where((r) => !r.isSprint).toList();
    final wins = races.where((r) => r.isWin).length;
    final podiums = races.where((r) => r.isPodium).length;
    final pointsFinishes = results.where((r) => r.isPointsFinish).length;
    final dnfs = races.where((r) => r.dnf).length;
    // Total points includes both race and sprint points
    final totalPoints = results.fold<double>(0, (sum, r) => sum + r.points);
    final bestPosition = races.where((r) => r.position > 0).map((r) => r.position).fold(999, (a, b) => a < b ? a : b);
    final bestGridPosition = races.map((r) => r.gridPosition).where((g) => g > 0).fold(999, (a, b) => a < b ? a : b);

    return DriverRaceStats(
      totalRaces: races.length,
      wins: wins,
      podiums: podiums,
      pointsFinishes: pointsFinishes,
      dnfs: dnfs,
      totalPoints: totalPoints,
      bestPosition: bestPosition == 999 ? 0 : bestPosition,
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
