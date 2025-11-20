import 'package:f1sync/core/providers.dart';
import 'package:f1sync/features/drivers/data/models/driver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_drivers_provider.g.dart';

/// Provider for the current season drivers
///
/// Fetches all drivers for the latest session using the 'latest' key.
/// Returns a sorted list of drivers (by team name, then driver number).
///
/// Cache: 1 hour (handled by repository layer with CacheTTL.medium)
/// Auto-refresh: Can be triggered manually via refresh()
@riverpod
class CurrentDrivers extends _$CurrentDrivers {
  @override
  Future<List<Driver>> build() async {
    final repo = ref.watch(driversRepositoryProvider);

    // Fetch all drivers for the latest session
    final drivers = await repo.getDrivers(sessionKey: 'latest');

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
