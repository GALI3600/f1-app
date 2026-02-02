import 'package:f1sync/core/providers.dart';
import 'package:f1sync/features/drivers/data/models/driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_drivers_provider.g.dart';

/// Provider for the current season drivers
///
/// Fetches all drivers for the current season from Jolpica API.
/// Returns a sorted list of drivers (by team name, then driver number).
///
/// Cache: 7 days (handled by repository layer with CacheTTL.long)
/// Auto-refresh: Can be triggered manually via refresh()
@riverpod
class CurrentDrivers extends _$CurrentDrivers {
  @override
  Future<List<Driver>> build() async {
    final repo = ref.watch(driversRepositoryProvider);

    // Fetch all drivers for the current season
    final drivers = await repo.getDrivers(season: 'current');

    // Sort by team name, then by driver number
    drivers.sort((a, b) {
      final teamCompare = a.teamName.compareTo(b.teamName);
      if (teamCompare != 0) return teamCompare;
      return a.driverNumber.compareTo(b.driverNumber);
    });

    return drivers;
  }

  /// Refresh the drivers data
  /// Forces a cache bypass and fetches fresh data from the API
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
