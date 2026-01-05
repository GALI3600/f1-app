import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/f1_colors.dart';
import '../../../../core/theme/f1_text_styles.dart';
import '../../../../shared/widgets/f1_app_bar.dart';
import '../../../../core/theme/f1_gradients.dart';
import '../../../../shared/widgets/f1_loading.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/drivers_list_provider.dart';
import '../providers/driver_filter_provider.dart';
import '../providers/driver_detail_provider.dart';
import '../widgets/driver_card.dart';
import '../widgets/driver_detail_panel.dart';

/// Screen displaying list of drivers with filtering and sorting
class DriversListScreen extends ConsumerStatefulWidget {
  const DriversListScreen({super.key});

  @override
  ConsumerState<DriversListScreen> createState() => _DriversListScreenState();
}

class _DriversListScreenState extends ConsumerState<DriversListScreen> {
  bool _isGridView = true;
  int? _selectedDriverNumber;

  Color _getTeamColor(String? teamColour) {
    if (teamColour == null) return F1Colors.navy;
    try {
      final hex = teamColour.startsWith('#') ? teamColour : '#$teamColour';
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (_) {
      return F1Colors.navy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(driversListNotifierProvider());
    final filteredDrivers = ref.watch(filteredDriversProvider);
    final filterState = ref.watch(driverFilterNotifierProvider);
    final teamNames = ref.watch(teamNamesProvider);

    // Get selected driver's team color for AppBar corner (only after data loads)
    Color? appBarCornerColorLeft;
    if (_selectedDriverNumber != null) {
      final detailAsync = ref.watch(driverDetailNotifierProvider(
        driverNumber: _selectedDriverNumber!,
      ));
      appBarCornerColorLeft = detailAsync.whenOrNull(
        data: (detail) => _getTeamColor(detail.driver.teamColour),
      );
    }

    return Scaffold(
      appBar: F1AppBar(
        title: 'Drivers',
        gradient: F1Gradients.main,
        cornerBackgroundColor: F1Colors.navy,
        cornerBackgroundColorLeft: appBarCornerColorLeft,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
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
      body: _buildBody(driversAsync, filteredDrivers, filterState, teamNames),
    );
  }

  Widget _buildBody(
    AsyncValue driversAsync,
    List filteredDrivers,
    DriverFilterState filterState,
    List<String> teamNames,
  ) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Master-detail layout for landscape tablets
    if (isLandscape && _selectedDriverNumber != null) {
      return Row(
        children: [
          // Detail panel on the left
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: DriverDetailPanel(
              key: ValueKey(_selectedDriverNumber),
              driverNumber: _selectedDriverNumber!,
              onClose: () {
                setState(() {
                  _selectedDriverNumber = null;
                });
              },
            ),
          ),

          // Divider
          Container(
            width: 1,
            color: F1Colors.ciano.withValues(alpha: 0.3),
          ),

          // Drivers grid on the right
          Expanded(
            child: Column(
              children: [
                _buildSearchAndFilterBar(filterState, teamNames),
                Expanded(
                  child: _buildDriversContent(
                    driversAsync,
                    filteredDrivers,
                    filterState,
                    isLandscapeWithPanel: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Standard layout
    return Column(
      children: [
        _buildSearchAndFilterBar(filterState, teamNames),
        Expanded(
          child: _buildDriversContent(
            driversAsync,
            filteredDrivers,
            filterState,
            isLandscapeWithPanel: false,
          ),
        ),
      ],
    );
  }

  Widget _buildDriversContent(
    AsyncValue driversAsync,
    List filteredDrivers,
    DriverFilterState filterState, {
    bool isLandscapeWithPanel = false,
  }) {
    return driversAsync.when(
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
              ? _buildGridView(
                  filteredDrivers,
                  hasActiveFilters: filterState.hasActiveFilters,
                  isLandscapeWithPanel: isLandscapeWithPanel,
                )
              : _buildListView(filteredDrivers),
        );
      },
      loading: () => const Center(
        child: F1LoadingWidget(
          size: 50,
          color: F1Colors.ciano,
          message: 'Loading drivers...',
        ),
      ),
      error: (error, stack) => ErrorMapper.mapToWidget(
        error,
        onRetry: () {
          ref.invalidate(driversListNotifierProvider());
        },
      ),
    );
  }

  Widget _buildSearchAndFilterBar(
    DriverFilterState filterState,
    List<String> teamNames,
  ) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Compact horizontal layout for landscape
    if (isLandscape) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: F1Colors.navy,
          border: Border(
            bottom: BorderSide(
              color: F1Colors.ciano.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Compact search field
            SizedBox(
              width: 200,
              height: 40,
              child: TextField(
                onChanged: (value) {
                  ref
                      .read(driverFilterNotifierProvider.notifier)
                      .setSearchQuery(value);
                },
                style: F1TextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: F1TextStyles.bodySmall.copyWith(
                    color: F1Colors.textSecondary,
                  ),
                  prefixIcon: const Icon(Icons.search, color: F1Colors.ciano, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  filled: true,
                  fillColor: F1Colors.navyDeep,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Team filter chips - horizontal scrollable
            if (teamNames.isNotEmpty)
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCompactChip('All', filterState.selectedTeam == null, () {
                        ref.read(driverFilterNotifierProvider.notifier).setSelectedTeam(null);
                      }),
                      ...teamNames.map((team) => _buildCompactChip(
                        team,
                        filterState.selectedTeam == team,
                        () {
                          ref.read(driverFilterNotifierProvider.notifier)
                              .setSelectedTeam(filterState.selectedTeam == team ? null : team);
                        },
                      )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Portrait layout - vertical
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: F1Colors.navy,
        border: Border(
          bottom: BorderSide(
            color: F1Colors.ciano.withValues(alpha: 0.3),
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
                  color: F1Colors.ciano.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: F1Colors.ciano.withValues(alpha: 0.3),
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

  Widget _buildCompactChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? F1Colors.ciano : F1Colors.navyDeep,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? F1Colors.ciano : F1Colors.ciano.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: F1TextStyles.bodySmall.copyWith(
              color: selected ? Colors.white : F1Colors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(
    List drivers, {
    bool hasActiveFilters = false,
    bool isLandscapeWithPanel = false,
  }) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenSize = MediaQuery.of(context).size;

    // Adjust for panel width when panel is open
    final availableWidth = isLandscapeWithPanel
        ? screenSize.width * 0.65 - 1 // 65% minus divider
        : screenSize.width;

    final crossAxisCount = _getCrossAxisCount(context, isLandscapeWithPanel: isLandscapeWithPanel);

    // Calculate aspect ratio dynamically in landscape to fit all 22 drivers (2026 season)
    double aspectRatio;
    double spacing;
    double padding;

    // Total slots for 2026 season (11 teams x 2 drivers = 22)
    const int totalSlots2026 = 22;

    if (isLandscape) {
      // Calculate available space for grid
      // AppBar ~56 + compact filter bar ~56 + padding
      const appBarHeight = 56.0;
      const filterBarHeight = 56.0;
      final availableHeight = screenSize.height - appBarHeight - filterBarHeight - 12;
      final gridWidth = availableWidth - 12;

      // Adjust rows when panel is open
      final rowCount = isLandscapeWithPanel ? 4 : 5;
      spacing = 4.0;
      padding = 6.0;

      final cardHeight = (availableHeight - (spacing * (rowCount - 1)) - (padding * 2)) / rowCount;
      final cardWidth = (gridWidth - (spacing * (crossAxisCount - 1)) - (padding * 2)) / crossAxisCount;

      aspectRatio = cardWidth / cardHeight;
    } else {
      aspectRatio = 0.75;
      spacing = 16.0;
      padding = 16.0;
    }

    // In landscape without panel, show placeholders only when no filters are active
    final showPlaceholders = isLandscape && !isLandscapeWithPanel && !hasActiveFilters && drivers.length < totalSlots2026;
    final itemCount = showPlaceholders ? totalSlots2026 : drivers.length;

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      physics: isLandscape && !isLandscapeWithPanel
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Show placeholder for slots beyond actual drivers
        if (index >= drivers.length) {
          return _buildPlaceholderCard(isLandscape);
        }

        final driver = drivers[index];
        final isSelected = _selectedDriverNumber == driver.driverNumber;

        return DriverCard(
          driver: driver,
          isLandscapeCompact: isLandscape,
          isSelected: isSelected,
          onTap: () {
            if (isLandscape) {
              // In landscape, open detail panel
              setState(() {
                _selectedDriverNumber = driver.driverNumber;
              });
            } else {
              // In portrait, navigate to detail screen
              context.push('/drivers/${driver.driverNumber}');
            }
          },
        );
      },
    );
  }

  Widget _buildPlaceholderCard(bool isLandscapeCompact) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isLandscapeCompact ? 10 : 16),
        color: F1Colors.navy.withValues(alpha: 0.5),
        border: Border.all(
          color: F1Colors.ciano.withValues(alpha: 0.2),
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: F1Colors.ciano.withValues(alpha: 0.3),
              size: isLandscapeCompact ? 24 : 32,
            ),
            const SizedBox(height: 4),
            Text(
              '2026',
              style: F1TextStyles.bodySmall.copyWith(
                color: F1Colors.ciano.withValues(alpha: 0.3),
                fontSize: isLandscapeCompact ? 10 : 12,
              ),
            ),
          ],
        ),
      ),
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

  int _getCrossAxisCount(BuildContext context, {bool isLandscapeWithPanel = false}) {
    final width = MediaQuery.of(context).size.width;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      // When panel is open, use fewer columns
      if (isLandscapeWithPanel) {
        return 4; // 4 columns when panel is open
      }
      // 5 columns = 5 rows for 22 drivers
      return 5;
    }

    // Portrait mode
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }
}
