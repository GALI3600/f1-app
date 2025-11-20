import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'driver_filter_provider.g.dart';

/// Enum for driver filtering options
enum DriverFilter {
  all,
  byTeam,
}

/// Enum for driver sorting options
enum DriverSort {
  byNumber,
  byName,
  byTeam,
}

/// State class for driver filters
class DriverFilterState {
  final DriverFilter filter;
  final DriverSort sort;
  final String? selectedTeam;
  final String searchQuery;

  const DriverFilterState({
    this.filter = DriverFilter.all,
    this.sort = DriverSort.byNumber,
    this.selectedTeam,
    this.searchQuery = '',
  });

  DriverFilterState copyWith({
    DriverFilter? filter,
    DriverSort? sort,
    String? selectedTeam,
    String? searchQuery,
  }) {
    return DriverFilterState(
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      selectedTeam: selectedTeam ?? this.selectedTeam,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters =>
      filter != DriverFilter.all ||
      selectedTeam != null ||
      searchQuery.isNotEmpty;
}

/// Provider for managing driver filter state
@riverpod
class DriverFilterNotifier extends _$DriverFilterNotifier {
  @override
  DriverFilterState build() {
    return const DriverFilterState();
  }

  /// Set filter type
  void setFilter(DriverFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Set sorting option
  void setSort(DriverSort sort) {
    state = state.copyWith(sort: sort);
  }

  /// Set selected team for filtering
  void setSelectedTeam(String? team) {
    state = state.copyWith(
      selectedTeam: team,
      filter: team != null ? DriverFilter.byTeam : DriverFilter.all,
    );
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear all filters
  void clearFilters() {
    state = const DriverFilterState();
  }
}
