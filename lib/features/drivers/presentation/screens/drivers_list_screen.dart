import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_text_styles.dart';
import '../../../../shared/widgets/f1_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/drivers_list_provider.dart';
import '../providers/driver_filter_provider.dart';
import '../widgets/driver_card.dart';

/// Screen displaying list of drivers with filtering and sorting
class DriversListScreen extends ConsumerStatefulWidget {
  const DriversListScreen({super.key});

  @override
  ConsumerState<DriversListScreen> createState() => _DriversListScreenState();
}

class _DriversListScreenState extends ConsumerState<DriversListScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(driversListNotifierProvider());
    final filteredDrivers = ref.watch(filteredDriversProvider);
    final filterState = ref.watch(driverFilterNotifierProvider);
    final teamNames = ref.watch(teamNamesProvider);

    return Scaffold(
      appBar: F1AppBar(
        title: 'Drivers',
        actions: [
          // View toggle button
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),

          // Filter menu button
          PopupMenuButton<DriverSort>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (sort) {
              ref.read(driverFilterNotifierProvider.notifier).setSort(sort);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: DriverSort.byNumber,
                child: Text('Sort by Number'),
              ),
              const PopupMenuItem(
                value: DriverSort.byName,
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: DriverSort.byTeam,
                child: Text('Sort by Team'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          _buildSearchAndFilterBar(filterState, teamNames),

          // Drivers list/grid
          Expanded(
            child: driversAsync.when(
              data: (_) {
                if (filteredDrivers.isEmpty) {
                  return F1EmptyStateWidget.noResults(
                    message: filterState.hasActiveFilters
                        ? 'No drivers match your filters'
                        : 'No drivers available',
                    onAction: filterState.hasActiveFilters
                        ? () {
                            ref
                                .read(driverFilterNotifierProvider.notifier)
                                .clearFilters();
                          }
                        : null,
                    actionText: 'Clear Filters',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(driversListNotifierProvider().notifier)
                        .refresh();
                  },
                  child: _isGridView
                      ? _buildGridView(filteredDrivers)
                      : _buildListView(filteredDrivers),
                );
              },
              loading: () => const LoadingWidget.custom(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: F1Colors.ciano,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading drivers...',
                        style: TextStyle(color: F1Colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              error: (error, stack) => ErrorMapper.mapToWidget(
                error,
                onRetry: () {
                  ref.invalidate(driversListNotifierProvider());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar(
    DriverFilterState filterState,
    List<String> teamNames,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        border: Border(
          bottom: BorderSide(
            color: F1Colors.ciano.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            onChanged: (value) {
              ref
                  .read(driverFilterNotifierProvider.notifier)
                  .setSearchQuery(value);
            },
            style: F1TextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Search drivers...',
              hintStyle: F1TextStyles.bodyMedium.copyWith(
                color: F1Colors.textSecondary,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: F1Colors.ciano,
              ),
              suffixIcon: filterState.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        ref
                            .read(driverFilterNotifierProvider.notifier)
                            .setSearchQuery('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: F1Colors.navyDeep,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: F1Colors.ciano.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: F1Colors.ciano.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: F1Colors.ciano,
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Team filter chips
          if (teamNames.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // "All" chip
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: filterState.selectedTeam == null,
                      onSelected: (selected) {
                        ref
                            .read(driverFilterNotifierProvider.notifier)
                            .setSelectedTeam(null);
                      },
                      selectedColor: F1Colors.ciano,
                      checkmarkColor: Colors.white,
                    ),
                  ),

                  // Team chips
                  ...teamNames.map((team) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(team),
                        selected: filterState.selectedTeam == team,
                        onSelected: (selected) {
                          ref
                              .read(driverFilterNotifierProvider.notifier)
                              .setSelectedTeam(selected ? team : null);
                        },
                        selectedColor: F1Colors.ciano,
                        checkmarkColor: Colors.white,
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGridView(List drivers) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        return DriverCard(
          driver: driver,
          onTap: () {
            context.push('/drivers/${driver.driverNumber}');
          },
        );
      },
    );
  }

  Widget _buildListView(List drivers) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        return DriverCardCompact(
          driver: driver,
          onTap: () {
            context.push('/drivers/${driver.driverNumber}');
          },
        );
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }
}
