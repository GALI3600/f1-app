import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers.dart';
import '../../data/models/driver.dart';
import 'driver_filter_provider.dart';

part 'drivers_list_provider.g.dart';

/// Provider for fetching drivers list with filtering and sorting
@riverpod
class DriversListNotifier extends _$DriversListNotifier {
  @override
  Future<List<Driver>> build({String sessionKey = 'latest'}) async {
    final repository = ref.watch(driversRepositoryProvider);

    try {
      final drivers = await repository.getDrivers(sessionKey: sessionKey);
      return drivers;
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh the drivers list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(driversRepositoryProvider);
      return await repository.getDrivers(sessionKey: 'latest');
    });
  }
}

/// Provider for filtered and sorted drivers
@riverpod
List<Driver> filteredDrivers(FilteredDriversRef ref) {
  final driversAsync = ref.watch(driversListNotifierProvider());
  final filterState = ref.watch(driverFilterNotifierProvider);

  return driversAsync.when(
    data: (drivers) {
      var filteredList = drivers;

      // Apply team filter
      if (filterState.selectedTeam != null) {
        filteredList = filteredList
            .where((driver) => driver.teamName == filterState.selectedTeam)
            .toList();
      }

      // Apply search query
      if (filterState.searchQuery.isNotEmpty) {
        final query = filterState.searchQuery.toLowerCase();
        filteredList = filteredList.where((driver) {
          return driver.fullName.toLowerCase().contains(query) ||
              driver.nameAcronym.toLowerCase().contains(query) ||
              driver.teamName.toLowerCase().contains(query) ||
              driver.driverNumber.toString().contains(query);
        }).toList();
      }

      // Apply sorting
      switch (filterState.sort) {
        case DriverSort.byNumber:
          filteredList.sort((a, b) => a.driverNumber.compareTo(b.driverNumber));
          break;
        case DriverSort.byName:
          filteredList.sort((a, b) => a.lastName.compareTo(b.lastName));
          break;
        case DriverSort.byTeam:
          filteredList.sort((a, b) {
            final teamCompare = a.teamName.compareTo(b.teamName);
            if (teamCompare != 0) return teamCompare;
            return a.driverNumber.compareTo(b.driverNumber);
          });
          break;
      }

      return filteredList;
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider for getting unique team names
@riverpod
List<String> teamNames(TeamNamesRef ref) {
  final driversAsync = ref.watch(driversListNotifierProvider());

  return driversAsync.when(
    data: (drivers) {
      final teams = drivers.map((driver) => driver.teamName).toSet().toList();
      teams.sort();
      return teams;
    },
    loading: () => [],
    error: (_, __) => [],
  );
}
