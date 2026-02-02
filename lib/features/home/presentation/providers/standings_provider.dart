import 'package:f1sync/core/providers.dart';
import 'package:f1sync/features/standings/data/models/driver_standing.dart';
import 'package:f1sync/features/standings/data/models/constructor_standing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'standings_provider.g.dart';

/// Combined standings data for the home screen
class StandingsData {
  final DriverStanding? championshipLeader;
  final ConstructorStanding? leadingConstructor;
  final int totalDrivers;
  final int totalConstructors;

  const StandingsData({
    this.championshipLeader,
    this.leadingConstructor,
    this.totalDrivers = 0,
    this.totalConstructors = 0,
  });
}

/// Provider for current season standings
///
/// Fetches both driver and constructor standings from Jolpica API.
/// Cache: 1 hour (standings update after each race)
@riverpod
class CurrentStandings extends _$CurrentStandings {
  @override
  Future<StandingsData> build() async {
    final repo = ref.watch(standingsRepositoryProvider);

    // Fetch both standings in parallel
    final results = await Future.wait([
      repo.getDriverStandings(),
      repo.getConstructorStandings(),
    ]);

    final driverStandings = results[0] as List<DriverStanding>;
    final constructorStandings = results[1] as List<ConstructorStanding>;

    return StandingsData(
      championshipLeader: driverStandings.isNotEmpty ? driverStandings.first : null,
      leadingConstructor: constructorStandings.isNotEmpty ? constructorStandings.first : null,
      totalDrivers: driverStandings.length,
      totalConstructors: constructorStandings.length,
    );
  }

  /// Refresh standings data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider for full driver standings list
@riverpod
Future<List<DriverStanding>> driverStandings(DriverStandingsRef ref) async {
  final repo = ref.watch(standingsRepositoryProvider);
  return repo.getDriverStandings();
}

/// Provider for full constructor standings list
@riverpod
Future<List<ConstructorStanding>> constructorStandings(ConstructorStandingsRef ref) async {
  final repo = ref.watch(standingsRepositoryProvider);
  return repo.getConstructorStandings();
}
